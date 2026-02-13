--=== AisbergHub Spectral Style (FADE ANIMATIONS) ===--
if getgenv and getgenv().AisbergHubLoaded then return end
if getgenv then getgenv().AisbergHubLoaded = true end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

-- Global state variables
local playerESPEnabled = false
local collectingEssence = false
local collectingChest = false
local antiAFKEnabled = false
local isMinimized = false
local isClosed = false
local CurrentTab = 1

-- Fade tween presets
local FadeInInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local FadeOutInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local ResizeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Function to fade in/out entire GUI recursively
local function fadeElement(element, targetTransparency, speed)
    local tweenInfo = TweenInfo.new(speed or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goals = {BackgroundTransparency = targetTransparency}
    
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        goals.TextTransparency = targetTransparency
    elseif element:IsA("ImageLabel") then
        goals.ImageTransparency = targetTransparency
    end
    
    local tween = TweenService:Create(element, tweenInfo, goals)
    tween:Play()
    return tween
end

local function fadeAllChildren(parent, targetTransparency, speed)
    for _, child in pairs(parent:GetDescendants()) do
        if child:IsA("GuiObject") and child.BackgroundTransparency ~= nil then
            spawn(function()
                fadeElement(child, targetTransparency, speed)
            end)
        end
    end
end

-- Tap Sim functions
local function collectBlockEssence()
    collectingEssence = not collectingEssence
    local btn = ScreenGui.MainFrame.ContentFrame.CollectEssenceBtn
    local targetColor = collectingEssence and Color3.fromRGB(0, 255, 100, 200) or Color3.fromRGB(20, 20, 25, 180)
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end

local function collectClickerChests()
    collectingChest = not collectingChest
    local btn = ScreenGui.MainFrame.ContentFrame.CollectChestBtn
    local targetColor = collectingChest and Color3.fromRGB(0, 255, 100, 200) or Color3.fromRGB(20, 20, 25, 180)
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AisbergHub_Spectral"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

-- MainFrame (STARTS COMPLETELY INVISIBLE)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 50, 0, 50)
MainFrame.Position = UDim2.new(1, -70, 1, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50, 255)  -- Fully transparent initially
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15, 255)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20, 255)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Logo
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 150, 1, 0)
Logo.Position = UDim2.new(0, 15, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "AisbergHub"
Logo.TextTransparency = 1
Logo.TextColor3 = Color3.fromRGB(150, 200, 255)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 18
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 100, 0, 20)
StatusLabel.Position = UDim2.new(0, 180, 0.5, -10)
StatusLabel.BackgroundColor3 = Color3.fromRGB(10, 20, 10, 255)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Undetected"
StatusLabel.TextTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = TopBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 4)
StatusCorner.Parent = StatusLabel

-- Author Label
local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(0, 100, 0, 16)
AuthorLabel.Position = UDim2.new(0, 290, 0.5, -8)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "by hasberd"
AuthorLabel.TextTransparency = 1
AuthorLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
AuthorLabel.Font = Enum.Font.Gotham
AuthorLabel.TextSize = 11
AuthorLabel.Parent = TopBar

-- SideBar (Categories)
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 180, 1, -60)
SideBar.Position = UDim2.new(0, 0, 0, 45)
SideBar.BackgroundTransparency = 1
SideBar.Parent = MainFrame

local Categories = {"🏠 Main", "🎮 Universal", "⚡ Tap Sim", "👁️ Visuals", "🛡️ AntiAFK"}
local CategoryBtns = {}

for i, category in ipairs(Categories) do
    local btn = Instance.new("TextButton")
    btn.Name = "CategoryBtn" .. i
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (i-1) * 45 + 10)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20, 255)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = category
    btn.TextTransparency = 1
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = SideBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    CategoryBtns[i] = btn
end

-- ContentFrame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -200, 1, -65)
ContentFrame.Position = UDim2.new(0, 185, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- InfoPanel
local InfoPanel = Instance.new("Frame")
InfoPanel.Size = UDim2.new(1, -20, 0, 30)
InfoPanel.Position = UDim2.new(0, 10, 1, -40)
InfoPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 15, 255)
InfoPanel.BackgroundTransparency = 1
InfoPanel.BorderSizePixel = 0
InfoPanel.Parent = MainFrame

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoPanel

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0.3, 0, 1, 0)
UserLabel.Position = UDim2.new(0, 10, 0, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "User: " .. lp.Name
UserLabel.TextTransparency = 1
UserLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 12
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = InfoPanel

local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(0.4, 0, 1, 0)
GameLabel.Position = UDim2.new(0.35, 0, 0, 0)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Current Game: Tap Simulator"
GameLabel.TextTransparency = 1
GameLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
GameLabel.Font = Enum.Font.Gotham
GameLabel.TextSize = 12
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.Parent = InfoPanel

-- Tab Content Frames
local TabContents = {}
for i, category in ipairs(Categories) do
    local content = Instance.new("Frame")
    content.Name = "Tab" .. i
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 10)
    content.BackgroundTransparency = 1
    content.Visible = i == 1
    content.Parent = ContentFrame
    TabContents[i] = content
end

-- Tap Sim Buttons (in Tab 3)
local CollectEssenceBtn = Instance.new("TextButton")
CollectEssenceBtn.Size = UDim2.new(0, 220, 0, 45)
CollectEssenceBtn.Position = UDim2.new(0, 20, 0, 20)
CollectEssenceBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25, 255)
CollectEssenceBtn.BackgroundTransparency = 1
CollectEssenceBtn.BorderSizePixel = 0
CollectEssenceBtn.Text = "💎 Collect Block Essence"
CollectEssenceBtn.TextTransparency = 1
CollectEssenceBtn.TextColor3 = Color3.fromRGB(230, 230, 250)
CollectEssenceBtn.Font = Enum.Font.Gotham
CollectEssenceBtn.TextSize = 15
CollectEssenceBtn.AutoButtonColor = false
CollectEssenceBtn.Parent = TabContents[3]

local CollectChestBtn = Instance.new("TextButton")
CollectChestBtn.Size = UDim2.new(0, 220, 0, 45)
CollectChestBtn.Position = UDim2.new(0, 20, 0, 75)
CollectChestBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25, 255)
CollectChestBtn.BackgroundTransparency = 1
CollectChestBtn.BorderSizePixel = 0
CollectChestBtn.Text = "📦 Collect Clicker Chest"
CollectChestBtn.TextTransparency = 1
CollectChestBtn.TextColor3 = Color3.fromRGB(230, 230, 250)
CollectChestBtn.Font = Enum.Font.Gotham
CollectChestBtn.TextSize = 15
CollectChestBtn.AutoButtonColor = false
CollectChestBtn.Parent = TabContents[3]

-- Button corners
for _, btn in pairs({CollectEssenceBtn, CollectChestBtn}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
end

-- INITIAL FADE IN (icon only)
spawn(function()
    fadeAllChildren(MainFrame, 0.2, 0.5)  -- Semi-transparent black
end)

-- Tab switching with fade
for i, btn in ipairs(CategoryBtns) do
    btn.MouseButton1Click:Connect(function()
        CurrentTab = i
        for j, catBtn in ipairs(CategoryBtns) do
            TweenService:Create(catBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = j == i and 0.1 or 0.8
            }):Play()
        end
        
        -- Fade out all tabs, then fade in target
        for j, tab in ipairs(TabContents) do
            if j ~= i then
                fadeElement(tab, 1, 0.2)
                tab.Visible = false
            else
                tab.Visible = true
                fadeElement(tab, 0.2, 0.3)
            end
        end
    end)
end

-- Close button with fade out
CloseBtn.MouseButton1Click:Connect(function()
    fadeAllChildren(MainFrame, 1, 0.3)
    local closeTween = TweenService:Create(MainFrame, FadeOutInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
        isClosed = true
    end)
end)

-- ENHANCED K key toggle with FADE + RESIZE
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or isClosed then return end
    if input.KeyCode == Enum.KeyCode.K then
        if MainFrame.Size.X.Offset == 50 then -- Icon -> Full menu
            -- Resize first
            local resizeTween = TweenService:Create(MainFrame, ResizeInfo, {
                Size = UDim2.new(0, 600, 0, 400),
                Position = UDim2.new(0.5, -300, 0.5, -200)
            })
            resizeTween:Play()
            
            -- Then fade in everything
            resizeTween.Completed:Connect(function()
                fadeAllChildren(MainFrame, 0.2, 0.4)
            end)
            isMinimized = false
        else -- Full -> Icon
            fadeAllChildren(MainFrame, 1, 0.3)
            local minimizeTween = TweenService:Create(MainFrame, FadeOutInfo, {
                Size = UDim2.new(0, 50, 0, 50),
                Position = UDim2.new(1, -70, 1, -70)
            })
            minimizeTween:Play()
            isMinimized = true
        end
    end
end)

-- Button connections
CollectEssenceBtn.MouseButton1Click:Connect(collectBlockEssence)
CollectChestBtn.MouseButton1Click:Connect(collectClickerChests)

-- Draggable TopBar
do
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

print("AisbergHub Spectral Fade v3.0 loaded! Smooth fade animations enabled")
