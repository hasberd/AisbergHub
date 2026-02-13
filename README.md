--=== AisbergHub Nova UI (Modern, Tabs, Smooth K Toggle) ===--
if getgenv and getgenv().AisbergHubLoaded then return end
if getgenv then getgenv().AisbergHubLoaded = true end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local lp = Players.LocalPlayer

--================= STATE =================--
local playerESPEnabled = false
local collectingEssence = false
local collectingChest = false
local antiAFKEnabled = false
local menuVisible = false

--================= HELPERS =================--
local function getHRP()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

--================= PLAYER ESP =================--
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
                highlight.FillColor = Color3.fromRGB(0, 255, 120)
            elseif lp:IsFriendsWith(plr.UserId) then
                highlight.FillColor = Color3.fromRGB(200, 200, 255)
            else
                highlight.FillColor = Color3.fromRGB(255, 80, 80)
            end

            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
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

local function togglePlayerESP()
    playerESPEnabled = not playerESPEnabled
    if playerESPEnabled then applyPlayerESP() else clearPlayerESP() end
end

--================= BLOCK ESSENCE COLLECTOR =================--
local function findEssenceTargets()
    local list = {}
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "BlockEssence" then
            local primary = model.PrimaryPart or model:FindFirstChild("Primary")
            if not primary then
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("BasePart") then primary = child break end
                end
            end
            local prompt = model:FindFirstChildOfClass("ProximityPrompt")
                or model:FindFirstChildWhichIsA("ProximityPrompt", true)

            if primary and prompt then
                table.insert(list, {part = primary, prompt = prompt})
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

--================= CLICKER CHEST COLLECTOR =================--
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

--================= ANTI-AFK =================--
local function setAntiAFK(state)
    antiAFKEnabled = state
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

--================= UI SETUP (MODERN PANEL) =================--
local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHub_NovaUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 520, 0, 320)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 1.6
mainStroke.Color = Color3.fromRGB(90, 120, 255)
mainStroke.Transparency = 0.6

local mainShadow = Instance.new("ImageLabel")
mainShadow.Name = "Shadow"
mainShadow.BackgroundTransparency = 1
mainShadow.Image = "rbxassetid://5028857084"
mainShadow.ImageColor3 = Color3.new(0, 0, 0)
mainShadow.ImageTransparency = 1
mainShadow.ScaleType = Enum.ScaleType.Slice
mainShadow.SliceCenter = Rect.new(24, 24, 276, 276)
mainShadow.Size = UDim2.new(1, 38, 1, 38)
mainShadow.Position = UDim2.new(0, -19, 0, -19)
mainShadow.ZIndex = 0
mainShadow.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 14)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "AisbergHub Nova"
titleLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextTransparency = 1
titleLabel.Parent = header

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
subtitleLabel.Position = UDim2.new(0, 16, 0, 20)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Tap Simulator Utility Panel"
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 13
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.TextTransparency = 1
subtitleLabel.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -38, 0.5, -14)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(235, 235, 245)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.TextTransparency = 1
closeButton.Parent = header
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 8)

-- Tabs bar (left)
local tabsFrame = Instance.new("Frame")
tabsFrame.Name = "TabsFrame"
tabsFrame.Size = UDim2.new(0, 130, 1, -54)
tabsFrame.Position = UDim2.new(0, 10, 0, 52)
tabsFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
tabsFrame.BackgroundTransparency = 0.3
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = mainFrame
Instance.new("UICorner", tabsFrame).CornerRadius = UDim.new(0, 10)

local tabList = Instance.new("UIListLayout", tabsFrame)
tabList.Padding = UDim.new(0, 6)
tabList.FillDirection = Enum.FillDirection.Vertical
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.VerticalAlignment = Enum.VerticalAlignment.Top

local tabButtons = {}
local tabPages = {}
local activeTab = "Main"

local function createTabButton(text, key)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. key
    btn.Size = UDim2.new(1, -12, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextTransparency = 1
    btn.AutoButtonColor = false
    btn.Parent = tabsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    tabButtons[key] = btn
end

createTabButton("🏠 Main", "Main")
createTabButton("⚡ Game", "Game")
createTabButton("👁️ Visual", "Visual")
createTabButton("🛡️ Anti-AFK", "AntiAFK")
createTabButton("⚙️ Settings", "Settings")

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -160, 1, -70)
contentFrame.Position = UDim2.new(0, 150, 0, 58)
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
contentFrame.BackgroundTransparency = 0.25
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 12)

-- Pages
local function createPage(key)
    local page = Instance.new("Frame")
    page.Name = "Page_" .. key
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.Visible = (key == "Main")
    page.Parent = contentFrame
    tabPages[key] = page
    return page
end

local mainPage = createPage("Main")
local gamePage = createPage("Game")
local visualPage = createPage("Visual")
local antiPage = createPage("AntiAFK")
local settingsPage = createPage("Settings")

-- Main page (info)
local mainInfo = Instance.new("TextLabel")
mainInfo.Size = UDim2.new(1, 0, 0, 50)
mainInfo.Position = UDim2.new(0, 0, 0, 0)
mainInfo.BackgroundTransparency = 1
mainInfo.Text = "Welcome to AisbergHub Nova\nPress K to toggle this panel."
mainInfo.TextColor3 = Color3.fromRGB(220, 220, 235)
mainInfo.Font = Enum.Font.GothamSemibold
mainInfo.TextSize = 16
mainInfo.TextYAlignment = Enum.TextYAlignment.Top
mainInfo.TextTransparency = 1
mainInfo.Parent = mainPage

-- Game page buttons
local essenceButton = Instance.new("TextButton")
essenceButton.Size = UDim2.new(0, 260, 0, 40)
essenceButton.Position = UDim2.new(0, 0, 0, 0)
essenceButton.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
essenceButton.BorderSizePixel = 0
essenceButton.Text = "💎 Collect Block Essence"
essenceButton.TextColor3 = Color3.fromRGB(235, 235, 245)
essenceButton.Font = Enum.Font.Gotham
essenceButton.TextSize = 15
essenceButton.TextTransparency = 1
essenceButton.AutoButtonColor = false
essenceButton.Parent = gamePage
Instance.new("UICorner", essenceButton).CornerRadius = UDim.new(0, 10)

local chestButton = Instance.new("TextButton")
chestButton.Size = UDim2.new(0, 260, 0, 40)
chestButton.Position = UDim2.new(0, 0, 0, 50)
chestButton.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
chestButton.BorderSizePixel = 0
chestButton.Text = "📦 Collect Clicker Chest"
chestButton.TextColor3 = Color3.fromRGB(235, 235, 245)
chestButton.Font = Enum.Font.Gotham
chestButton.TextSize = 15
chestButton.TextTransparency = 1
chestButton.AutoButtonColor = false
chestButton.Parent = gamePage
Instance.new("UICorner", chestButton).CornerRadius = UDim.new(0, 10)

-- Visual page
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 220, 0, 40)
espButton.Position = UDim2.new(0, 0, 0, 0)
espButton.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
espButton.BorderSizePixel = 0
espButton.Text = "👁️ Player ESP: OFF"
espButton.TextColor3 = Color3.fromRGB(235, 235, 245)
espButton.Font = Enum.Font.Gotham
espButton.TextSize = 15
espButton.TextTransparency = 1
espButton.AutoButtonColor = false
espButton.Parent = visualPage
Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 10)

-- AntiAFK page
local antiLabel = Instance.new("TextLabel")
antiLabel.Size = UDim2.new(1, 0, 0, 40)
antiLabel.Position = UDim2.new(0, 0, 0, 0)
antiLabel.BackgroundTransparency = 1
antiLabel.Text = "Anti-AFK: prevents kick by moving camera."
antiLabel.TextColor3 = Color3.fromRGB(210, 210, 230)
antiLabel.Font = Enum.Font.Gotham
antiLabel.TextSize = 15
antiLabel.TextWrapped = true
antiLabel.TextYAlignment = Enum.TextYAlignment.Top
antiLabel.TextTransparency = 1
antiLabel.Parent = antiPage

local antiStatus = Instance.new("TextLabel")
antiStatus.Size = UDim2.new(0, 180, 0, 24)
antiStatus.Position = UDim2.new(0, 0, 0, 48)
antiStatus.BackgroundTransparency = 1
antiStatus.Text = "Status: Inactive"
antiStatus.TextColor3 = Color3.fromRGB(200, 200, 210)
antiStatus.Font = Enum.Font.GothamSemibold
antiStatus.TextSize = 14
antiStatus.TextTransparency = 1
antiStatus.Parent = antiPage

local antiButton = Instance.new("TextButton")
antiButton.Size = UDim2.new(0, 220, 0, 40)
antiButton.Position = UDim2.new(0, 0, 0, 80)
antiButton.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
antiButton.BorderSizePixel = 0
antiButton.Text = "Toggle Anti-AFK"
antiButton.TextColor3 = Color3.fromRGB(235, 235, 245)
antiButton.Font = Enum.Font.Gotham
antiButton.TextSize = 15
antiButton.TextTransparency = 1
antiButton.AutoButtonColor = false
antiButton.Parent = antiPage
Instance.new("UICorner", antiButton).CornerRadius = UDim.new(0, 10)

-- Settings page (placeholder)
local settingsLabel = Instance.new("TextLabel")
settingsLabel.Size = UDim2.new(1, 0, 0, 40)
settingsLabel.Position = UDim2.new(0, 0, 0, 0)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Text = "Settings: keybinds, colors and presets (coming soon)."
settingsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
settingsLabel.Font = Enum.Font.Gotham
settingsLabel.TextSize = 15
settingsLabel.TextWrapped = true
settingsLabel.TextYAlignment = Enum.TextYAlignment.Top
settingsLabel.TextTransparency = 1
settingsLabel.Parent = settingsPage

--================= TAB SWITCHING =================--
local function setActiveTab(key)
    activeTab = key
    for tabKey, page in pairs(tabPages) do
        page.Visible = (tabKey == key)
    end
    for tabKey, btn in pairs(tabButtons) do
        local isActive = (tabKey == key)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isActive and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(26, 26, 38),
            TextColor3 = isActive and Color3.fromRGB(240, 240, 255) or Color3.fromRGB(190, 190, 210)
        }):Play()
    end
end

for key, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        setActiveTab(key)
    end)
end
setActiveTab("Main")

--================= BUTTON HANDLERS =================--
essenceButton.MouseButton1Click:Connect(function()
    if collectingEssence then
        collectingEssence = false
        essenceButton.Text = "💎 Collect Block Essence"
        return
    end
    essenceButton.Text = "Collecting..."
    collectBlockEssence()
    essenceButton.Text = "💎 Collect Block Essence"
end)

chestButton.MouseButton1Click:Connect(function()
    if collectingChest then
        collectingChest = false
        chestButton.Text = "📦 Collect Clicker Chest"
        return
    end
    chestButton.Text = "Collecting..."
    collectClickerChests()
    chestButton.Text = "📦 Collect Clicker Chest"
end)

espButton.MouseButton1Click:Connect(function()
    togglePlayerESP()
    espButton.Text = playerESPEnabled and "👁️ Player ESP: ON" or "👁️ Player ESP: OFF"
    TweenService:Create(espButton, TweenInfo.new(0.2), {
        BackgroundColor3 = playerESPEnabled and Color3.fromRGB(50, 90, 60) or Color3.fromRGB(32, 32, 48)
    }):Play()
end)

antiButton.MouseButton1Click:Connect(function()
    local newState = not antiAFKEnabled
    setAntiAFK(newState)
    antiStatus.Text = newState and "Status: Active" or "Status: Inactive"
    antiStatus.TextColor3 = newState and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 210)
end)

closeButton.MouseButton1Click:Connect(function()
    if not menuVisible then return end
    menuVisible = false
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 80, 0, 80),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(mainShadow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
end)

--================= FADE HELPERS =================--
local function fadeAllElements(target)
    for _, obj in pairs(mainFrame:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            TweenService:Create(obj, TweenInfo.new(0.25), {TextTransparency = target}):Play()
        end
    end
end

--================= K TOGGLE (SMOOTH) =================--
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        menuVisible = not menuVisible
        if menuVisible then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            mainShadow.ImageTransparency = 1
            fadeAllElements(1)

            TweenService:Create(mainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 520, 0, 320),
                BackgroundTransparency = 0.2
            }):Play()
            TweenService:Create(mainShadow, TweenInfo.new(0.4), {ImageTransparency = 0.55}):Play()
            fadeAllElements(0)
        else
            fadeAllElements(1)
            TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 80, 0, 80),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(mainShadow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        end
    end
end)

--================= DRAGGABLE HEADER =================--
do
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

print("AisbergHub Nova loaded. Press K to toggle modern menu.")
