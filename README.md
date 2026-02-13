--=== AisbergHub UI (Main/Game/Visual/AntiAFK/Settings + Collectors, draggable) ===--

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

local function getHRP()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

--================= COLLECT BLOCK ESSENCE (GAME TAB) =================--

local collectingEssence = false

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

--================= COLLECT CLICKER CHEST (GAME TAB) =================--

local collectingChest = false

local function findClickerChestHitboxes()
    local list = {}

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "ClickerChest" then
            local hitbox = model:FindFirstChild("Hitbox")
            if hitbox and hitbox:IsA("BasePart") then
                table.insert(list, hitbox)
            end
        end
    end

    return list
end

local function collectClickerChests()
    if collectingChest then return end
    collectingChest = true

    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        collectingChest = false
        return
    end

    local hitboxes = findClickerChestHitboxes()
    print("ClickerChest hitboxes found:", #hitboxes)

    for _, hit in ipairs(hitboxes) do
        if not collectingChest then break end
        if hit and hit.Parent then
            pcall(function()
                firetouchinterest(hit, hrp, 0)
                task.wait(0.05)
                firetouchinterest(hit, hrp, 1)
            end)
            task.wait(0.1)
        end
    end

    collectingChest = false
end

--================= GUI BASE =================--

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 420, 0, 260)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Visible = false
frame.BackgroundTransparency = 0.4
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.ZIndex = 0
shadow.Parent = frame

-- Header
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

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.new(0, 14, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Utility Panel"
subtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextTransparency = 1
subtitle.Parent = frame

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

--================= TABS (RIGHT SIDE) =================--

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0, 110, 1, -60)
tabsFrame.Position = UDim2.new(1, -120, 0, 50)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(210,210,220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextTransparency = 1
    btn.AutoButtonColor = false
    btn.Parent = tabsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local mainTabBtn     = createTabButton("Main",     1)
local gameTabBtn     = createTabButton("Game",     2)
local visualTabBtn   = createTabButton("Visual",   3)
local antiTabBtn     = createTabButton("AntiAFK",  4)
local settingsTabBtn = createTabButton("Settings", 5)

--================= CONTENT AREA (LEFT) =================--

local pagesFrame = Instance.new("Frame")
pagesFrame.Size = UDim2.new(1, -140, 1, -80)
pagesFrame.Position = UDim2.new(0, 14, 0, 70)
pagesFrame.BackgroundTransparency = 1
pagesFrame.Parent = frame

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Parent = pagesFrame

local mainPlaceholder = Instance.new("TextLabel")
mainPlaceholder.Size = UDim2.new(1, 0, 0, 20)
mainPlaceholder.Position = UDim2.new(0, 0, 0, 0)
mainPlaceholder.BackgroundTransparency = 1
mainPlaceholder.Text = "Main tab: general features (speed, info, etc.)."
mainPlaceholder.TextColor3 = Color3.fromRGB(180,180,195)
mainPlaceholder.Font = Enum.Font.Gotham
mainPlaceholder.TextSize = 14
mainPlaceholder.TextTransparency = 1
mainPlaceholder.TextXAlignment = Enum.TextXAlignment.Left
mainPlaceholder.Parent = mainPage

local gamePage = Instance.new("Frame")
gamePage.Size = UDim2.new(1, 0, 1, 0)
gamePage.BackgroundTransparency = 1
gamePage.Visible = false
gamePage.Parent = pagesFrame

local gamePlaceholder = mainPlaceholder:Clone()
gamePlaceholder.Text = "Game tab: Tap Simulator utilities."
gamePlaceholder.Parent = gamePage

local visualPage = Instance.new("Frame")
visualPage.Size = UDim2.new(1, 0, 1, 0)
visualPage.BackgroundTransparency = 1
visualPage.Visible = false
visualPage.Parent = pagesFrame

local visualPlaceholder = mainPlaceholder:Clone()
visualPlaceholder.Text = "Visual tab: ESP and visual effects."
visualPlaceholder.Parent = visualPage

local antiPage = Instance.new("Frame")
antiPage.Size = UDim2.new(1, 0, 1, 0)
antiPage.BackgroundTransparency = 1
antiPage.Visible = false
antiPage.Parent = pagesFrame

local settingsPage = Instance.new("Frame")
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false
settingsPage.Parent = pagesFrame

local settingsPlaceholder = mainPlaceholder:Clone()
settingsPlaceholder.Text = "Settings tab: later we can put colors, keybinds, etc."
settingsPlaceholder.Parent = settingsPage

--================= GAME TAB BUTTONS =================--

local collectEssenceBtn = Instance.new("TextButton")
collectEssenceBtn.Size = UDim2.new(0, 200, 0, 28)
collectEssenceBtn.Position = UDim2.new(0, 0, 0, 40)
collectEssenceBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
collectEssenceBtn.BorderSizePixel = 0
collectEssenceBtn.Text = "Collect Block Essence"
collectEssenceBtn.TextColor3 = Color3.fromRGB(230,230,240)
collectEssenceBtn.Font = Enum.Font.Gotham
collectEssenceBtn.TextSize = 14
collectEssenceBtn.TextTransparency = 1
collectEssenceBtn.AutoButtonColor = false
collectEssenceBtn.Parent = gamePage
Instance.new("UICorner", collectEssenceBtn).CornerRadius = UDim.new(0, 6)

local collectChestBtn = Instance.new("TextButton")
collectChestBtn.Size = UDim2.new(0, 200, 0, 28)
collectChestBtn.Position = UDim2.new(0, 0, 0, 80)
collectChestBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
collectChestBtn.BorderSizePixel = 0
collectChestBtn.Text = "Collect Clicker Chest"
collectChestBtn.TextColor3 = Color3.fromRGB(230,230,240)
collectChestBtn.Font = Enum.Font.Gotham
collectChestBtn.TextSize = 14
collectChestBtn.TextTransparency = 1
collectChestBtn.AutoButtonColor = false
collectChestBtn.Parent = gamePage
Instance.new("UICorner", collectChestBtn).CornerRadius = UDim.new(0, 6)

--================= VISUAL TAB BUTTONS (только ESP) =================--

local playerESPBtn = Instance.new("TextButton")
playerESPBtn.Size = UDim2.new(0, 160, 0, 28)
playerESPBtn.Position = UDim2.new(0, 0, 0, 30)
playerESPBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
playerESPBtn.BorderSizePixel = 0
playerESPBtn.Text = "Player ESP: OFF"
playerESPBtn.TextColor3 = Color3.fromRGB(230,230,240)
playerESPBtn.Font = Enum.Font.Gotham
playerESPBtn.TextSize = 14
playerESPBtn.TextTransparency = 1
playerESPBtn.AutoButtonColor = false
playerESPBtn.Parent = visualPage
Instance.new("UICorner", playerESPBtn).CornerRadius = UDim.new(0, 6)

--================= ANTIAFK TAB =================--

local antiTitle = Instance.new("TextLabel")
antiTitle.Size = UDim2.new(1, 0, 0, 20)
antiTitle.Position = UDim2.new(0, 0, 0, 0)
antiTitle.BackgroundTransparency = 1
antiTitle.Text = "Aisberg AntiAFK"
antiTitle.TextColor3 = Color3.fromRGB(230,230,240)
antiTitle.Font = Enum.Font.GothamBold
antiTitle.TextSize = 16
antiTitle.TextTransparency = 1
antiTitle.TextXAlignment = Enum.TextXAlignment.Left
antiTitle.Parent = antiPage

local antiStatus = Instance.new("TextLabel")
antiStatus.Size = UDim2.new(1, 0, 0, 18)
antiStatus.Position = UDim2.new(0, 0, 0, 24)
antiStatus.BackgroundTransparency = 1
antiStatus.Text = "Status: Inactive"
antiStatus.TextColor3 = Color3.fromRGB(200,200,210)
antiStatus.Font = Enum.Font.Gotham
antiStatus.TextSize = 14
antiStatus.TextTransparency = 1
antiStatus.TextXAlignment = Enum.TextXAlignment.Left
antiStatus.Parent = antiPage

local antiDesc = Instance.new("TextLabel")
antiDesc.Size = UDim2.new(1, 0, 0, 32)
antiDesc.Position = UDim2.new(0, 0, 0, 46)
antiDesc.BackgroundTransparency = 1
antiDesc.TextWrapped = true
antiDesc.Text = "Moves/zooms the camera every few seconds to avoid AFK kick."
antiDesc.TextColor3 = Color3.fromRGB(160,160,185)
antiDesc.Font = Enum.Font.Gotham
antiDesc.TextSize = 13
antiDesc.TextTransparency = 1
antiDesc.TextXAlignment = Enum.TextXAlignment.Left
antiDesc.TextYAlignment = Enum.TextYAlignment.Top
antiDesc.Parent = antiPage

local antiBtn = Instance.new("TextButton")
antiBtn.Size = UDim2.new(0, 140, 0, 28)
antiBtn.Position = UDim2.new(0, 0, 0, 90)
antiBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
antiBtn.BorderSizePixel = 0
antiBtn.Text = "Toggle AntiAFK"
antiBtn.TextColor3 = Color3.fromRGB(230,230,240)
antiBtn.Font = Enum.Font.Gotham
antiBtn.TextSize = 14
antiBtn.TextTransparency = 1
antiBtn.AutoButtonColor = false
antiBtn.Parent = antiPage
Instance.new("UICorner", antiBtn).CornerRadius = UDim.new(0, 6)

local antiAFKEnabled = false

local function setAntiAFK(state)
    antiAFKEnabled = state
    if antiAFKEnabled then
        antiStatus.Text = "Status: Active"
        antiStatus.TextColor3 = Color3.fromRGB(0,255,0)
    else
        antiStatus.Text = "Status: Inactive"
        antiStatus.TextColor3 = Color3.fromRGB(200,200,210)
    end

    task.spawn(function()
        while antiAFKEnabled do
            task.wait(15)
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CFrame = cam.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, math.rad(8), 0)
            end
        end
    end)
end

antiBtn.MouseButton1Click:Connect(function()
    setAntiAFK(not antiAFKEnabled)
end)

--================= TAB LOGIC =================--

local function setActiveTab(name)
    mainPage.Visible     = (name == "Main")
    gamePage.Visible     = (name == "Game")
    visualPage.Visible   = (name == "Visual")
    antiPage.Visible     = (name == "AntiAFK")
    settingsPage.Visible = (name == "Settings")

    mainTabBtn.BackgroundColor3     = name == "Main"     and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    gameTabBtn.BackgroundColor3     = name == "Game"     and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    visualTabBtn.BackgroundColor3   = name == "Visual"   and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    antiTabBtn.BackgroundColor3     = name == "AntiAFK"  and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    settingsTabBtn.BackgroundColor3 = name == "Settings" and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
end

mainTabBtn.MouseButton1Click:Connect(function() setActiveTab("Main") end)
gameTabBtn.MouseButton1Click:Connect(function() setActiveTab("Game") end)
visualTabBtn.MouseButton1Click:Connect(function() setActiveTab("Visual") end)
antiTabBtn.MouseButton1Click:Connect(function() setActiveTab("AntiAFK") end)
settingsTabBtn.MouseButton1Click:Connect(function() setActiveTab("Settings") end)

setActiveTab("Main")

--================= BUTTON HANDLERS =================--

playerESPBtn.MouseButton1Click:Connect(function()
    togglePlayerESP()
    playerESPBtn.Text = playerESPEnabled and "Player ESP: ON" or "Player ESP: OFF"
    playerESPBtn.BackgroundColor3 = playerESPEnabled and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(35,35,50)
end)

collectEssenceBtn.MouseButton1Click:Connect(function()
    if not collectingEssence then
        collectEssenceBtn.Text = "Collecting..."
        collectBlockEssence()
        collectEssenceBtn.Text = "Collect Block Essence"
    else
        collectingEssence = false
        collectEssenceBtn.Text = "Collect Block Essence"
    end
end)

collectChestBtn.MouseButton1Click:Connect(function()
    if not collectingChest then
        collectChestBtn.Text = "Collecting..."
        collectClickerChests()
        collectChestBtn.Text = "Collect Clicker Chest"
    else
        collectingChest = false
        collectChestBtn.Text = "Collect Clicker Chest"
    end
end)

--================= ANIMATION (open/close) =================--

local isVisible = false
local tweenTime = 0.3
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local guiElements = {
    title, subtitle, closeBtn,
    mainTabBtn, gameTabBtn, visualTabBtn, antiTabBtn, settingsTabBtn,
    mainPlaceholder, gamePlaceholder, visualPlaceholder, settingsPlaceholder,
    antiTitle, antiStatus, antiDesc, antiBtn,
    playerESPBtn, collectEssenceBtn, collectChestBtn
}

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
        Size = UDim2.new(0, 420, 0, 260),
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

--================= DRAGGABLE MENU =================--

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

--================= KEYBIND & CLOSE =================--

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

print("AisbergHub UI loaded. Press K to open menu, drag the window to move it.")
