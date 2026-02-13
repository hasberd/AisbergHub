--=== AisbergHub (Visual only: ESP + Aimbot, универсальный под риги) ===--

if getgenv and getgenv().AisbergHubLoaded then
    return
end
if getgenv then
    getgenv().AisbergHubLoaded = true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--================= ESP =================--

local playerESPEnabled = false

local function clearPlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("Aisberg_PlayerESP")
            if h then h:Destroy() end
        end
    end
end

local function isEnemy(plr)
    if plr == lp then return false end
    if lp.Team ~= nil and plr.Team ~= nil then
        return lp.Team ~= plr.Team
    end
    return true
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
            elseif isEnemy(plr) then
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
            else
                highlight.FillColor = Color3.fromRGB(0, 0, 255)
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

--================= AIMBOT (универсальный root‑lock + FOV) =================--

local aimbotEnabled = false
local aimbotHoldKey = Enum.UserInputType.MouseButton2 -- ПКМ
local aimbotSmoothing = 0 -- 0 = instant lock
local aimbotFOV = 220 -- радиус FOV в пикселях

-- если игра типа Hypershot, можно оставить true для чуть большего FOV
local hypershotMode = true
local hypershotFOV = 260

local function getAimPart(char)
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    -- 1) RootPart, который Roblox считает главным телом[web:361]
    local root = humanoid.RootPart
    if root and root:IsA("BasePart") then
        return root
    end

    -- 2) Популярные части для разных ригов
    local candidates = {
        "HumanoidRootPart",
        "UpperTorso",
        "LowerTorso",
        "Torso",
        "Head"
    }

    for _, name in ipairs(candidates) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            return p
        end
    end

    -- 3) Любой BasePart в модели, если ничего не нашли
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end

    return nil
end

local function getClosestEnemyToCrosshair(maxFov)
    local mouseLocation = UserInputService:GetMouseLocation()
    local limit = maxFov or (hypershotMode and hypershotFOV or aimbotFOV)
    local nearestDist = limit
    local nearestPlayer, nearestPart = nil, nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local part = getAimPart(plr.Character)
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                    if dist <= limit and dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = plr
                        nearestPart = part
                    end
                end
            end
        end
    end

    return nearestPlayer, nearestPart
end

local function aimAt(position)
    local cf = CFrame.new(camera.CFrame.Position, position)
    if aimbotSmoothing <= 0 then
        camera.CFrame = cf
    else
        camera.CFrame = camera.CFrame:Lerp(cf, aimbotSmoothing)
    end
end

local holdingAim = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if aimbotEnabled and input.UserInputType == aimbotHoldKey then
        holdingAim = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == aimbotHoldKey then
        holdingAim = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled or not holdingAim then return end
    local enemy, part = getClosestEnemyToCrosshair()
    if enemy and part then
        aimAt(part.Position)
    end
end)

--================= GUI (Visual only: ESP + Aimbot) =================--

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 320, 0, 160)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Visible = false
frame.BackgroundTransparency = 0.4
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 26)
title.Position = UDim2.new(0, 14, 0, 6)
title.BackgroundTransparency = 1
title.Text = "AisbergHub"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(235, 235, 245)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextTransparency = 1
closeBtn.AutoButtonColor = false
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -28, 1, -50)
content.Position = UDim2.new(0, 14, 0, 40)
content.BackgroundTransparency = 1
content.Parent = frame

-- ESP button

local playerESPBtn = Instance.new("TextButton")
playerESPBtn.Size = UDim2.new(0, 160, 0, 28)
playerESPBtn.Position = UDim2.new(0, 0, 0, 0)
playerESPBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
playerESPBtn.BorderSizePixel = 0
playerESPBtn.Text = "Player ESP: OFF"
playerESPBtn.TextColor3 = Color3.fromRGB(230,230,240)
playerESPBtn.Font = Enum.Font.Gotham
playerESPBtn.TextSize = 14
playerESPBtn.TextTransparency = 1
playerESPBtn.AutoButtonColor = false
playerESPBtn.Parent = content
Instance.new("UICorner", playerESPBtn).CornerRadius = UDim.new(0, 6)

-- Aimbot button

local function getCurrentFOV()
    return hypershotMode and hypershotFOV or aimbotFOV
end

local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(0, 220, 0, 28)
aimbotBtn.Position = UDim2.new(0, 0, 0, 40)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
aimbotBtn.BorderSizePixel = 0
aimbotBtn.Text = "Aimbot: OFF (RMB, FOV "..getCurrentFOV()..")"
aimbotBtn.TextColor3 = Color3.fromRGB(230,230,240)
aimbotBtn.Font = Enum.Font.Gotham
aimbotBtn.TextSize = 14
aimbotBtn.TextTransparency = 1
aimbotBtn.AutoButtonColor = false
aimbotBtn.Parent = content
Instance.new("UICorner", aimbotBtn).CornerRadius = UDim.new(0, 6)

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, 0, 0, 18)
modeLabel.Position = UDim2.new(0, 0, 0, 76)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = hypershotMode and "Mode: body/root aim" or "Mode: head/torso aim"
modeLabel.TextColor3 = Color3.fromRGB(180,180,195)
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 13
modeLabel.TextTransparency = 1
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = content

-- Handlers

playerESPBtn.MouseButton1Click:Connect(function()
    togglePlayerESP()
    playerESPBtn.Text = playerESPEnabled and "Player ESP: ON" or "Player ESP: OFF"
    playerESPBtn.BackgroundColor3 = playerESPEnabled and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(35,35,50)
end)

aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    local fovText = getCurrentFOV()
    aimbotBtn.Text = aimbotEnabled
        and ("Aimbot: ON (RMB, FOV "..fovText..")")
        or ("Aimbot: OFF (RMB, FOV "..fovText..")")
    aimbotBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(35,35,50)
end)

-- Animation + draggable + keybind K

local isVisible = false
local tweenTime = 0.25
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local guiElements = {title, closeBtn, playerESPBtn, aimbotBtn, modeLabel}

local function setTextTransparency(value)
    for _, ui in ipairs(guiElements) do
        if ui and (ui:IsA("TextLabel") or ui:IsA("TextButton")) then
            ui.TextTransparency = value
        end
    end
end

local function fadeIn()
    frame.Visible = true
    frame.Size = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    setTextTransparency(1)

    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(0, 320, 0, 160),
        BackgroundTransparency = 0.4
    }):Play()

    for _, ui in ipairs(guiElements) do
        if ui then
            TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
        end
    end
end

local function fadeOut(callback)
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    }):Play()

    for _, ui in ipairs(guiElements) do
        if ui then
            TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
        end
    end

    task.delay(tweenTime, function()
        frame.Visible = false
        if callback then callback() end
    end)
end

-- draggable
do
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

closeBtn.MouseButton1Click:Connect(function()
    if isVisible then
        isVisible = false
        fadeOut(function()
            gui.Enabled = false
        end)
    else
        gui.Enabled = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        isVisible = not isVisible
        if isVisible then
            gui.Enabled = true
            fadeIn()
        else
            fadeOut()
        end
    end
end)

print("AisbergHub Visual (ESP + universal Aimbot) loaded. Press K to open, toggle ESP, hold RMB for aimbot.")
