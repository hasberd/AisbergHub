--=== AisbergHub UI (Main/Game/Visual/AntiAFK/Settings + Player ESP + Collect Block Essence) ===--

if getgenv and getgenv().AisbergHubLoaded then
    return
end
if getgenv then
    getgenv().AisbergHubLoaded = true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local lp = Players.LocalPlayer

--================= PLAYER ESP =================--

local playerESPEnabled = false

local function clearPlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("Aisberg_PlayerESP")
            if h then h:Destroy() end
        end
    end
end

local function applyPlayerESP()
    clearPlayerESP()
    if not playerESPEnabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "Aisberg_PlayerESP"

            if plr == lp then
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
            elseif lp:IsFriendsWith(plr.UserId) then
                highlight.FillColor = Color3.fromRGB(255, 255, 255)
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
            end

            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = plr.Character
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if playerESPEnabled then
            task.wait(1)
            applyPlayerESP()
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        local h = plr.Character:FindFirstChild("Aisberg_PlayerESP")
        if h then h:Destroy() end
    end
end)

local function togglePlayerESP()
    playerESPEnabled = not playerESPEnabled
    if playerESPEnabled then
        applyPlayerESP()
    else
        clearPlayerESP()
    end
end

--================= Collect Block Essence (BlockEssence = Model) =================--

local collectingEssence = false

local function getHRP()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- возвращает таблицу { part = PrimaryPart, prompt = ProximityPrompt } для всех BlockEssence
local function findEssenceTargets()
    local list = {}

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "BlockEssence" then
            local primary = model:FindFirstChild("Primary")
            if not (primary and primary:IsA("BasePart")) then
                if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
                    primary = model.PrimaryPart
                else
                    for _, child in ipairs(model:GetDescendants()) do
                        if child:IsA("BasePart") then
                            primary = child
                            break
                        end
                    end
                end
            end

            local prompt = model:FindFirstChildOfClass("ProximityPrompt")
                or model:FindFirstChildWhichIsA("ProximityPrompt", true)

            if primary and prompt then
                table.insert(list, {
                    part = primary,
                    prompt = prompt
                })
            end
        end
    end

    return list
end

local function collectBlockEssence()
    if collectingEssence then return end
    collectingEssence = true

    local hrp = getHRP()
    if not hrp then
        collectingEssence = false
        return
    end

    local targets = findEssenceTargets()
    print("BlockEssence targets found:", #targets)

    for _, t in ipairs(targets) do
        if not collectingEssence then break end
        local part = t.part
        local prompt = t.prompt

        if part and part.Parent and prompt and prompt.Parent then
            hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.2)

            for i = 1, 5 do
                if not collectingEssence then break end
                pcall(function()
                    fireproximityprompt(prompt, 1)
                end)
                task.wait(0.25)
            end
        end
    end

    collectingEssence = false
end

--================= GUI BASE =================--

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local f
