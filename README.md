--=== AisbergHub Neo v4.0 (MODERN DESIGN) ===--
if getgenv and getgenv().AisbergHubLoaded then return end
if getgenv then getgenv().AisbergHubLoaded = true end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Modern color palette
local Colors = {
    Primary = Color3.fromRGB(15, 15, 25),
    Secondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(100, 150, 255),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(255, 180, 80),
    Text = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(160, 160, 180),
    Glass = Color3.fromRGB(20, 20, 30)
}

-- State
local isMinimized = false
local isClosed = false
local CurrentTab = 1

-- Enhanced fade function
local function fadeAllChildren(parent, targetTransparency, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    for _, child in pairs(parent:GetDescendants()) do
        if child:IsA("GuiObject") then
            local goals = {BackgroundTransparency = targetTransparency}
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                goals.TextTransparency = targetTransparency
            elseif child:IsA("ImageLabel") then
                goals.ImageTransparency = targetTransparency
            end
            TweenService:Create(child, tweenInfo, goals):Play()
        end
    end
end

-- Create main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AisbergHub_Neo"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

-- Main container with glassmorphism
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
MainFrame.BackgroundColor3 = Colors.Glass
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Glass effect with UIGradient + UIStroke
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Colors.Accent
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

-- Header Bar
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "Header"
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)
HeaderFrame.BackgroundColor3 = Colors.Primary
HeaderFrame.BackgroundTransparency = 0.05
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = HeaderFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Colors.Primary),
    ColorSequenceKeypoint.new(1, Colors.Secondary)
}
HeaderGradient.Parent = HeaderFrame

-- Logo & Title
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 200, 1, 0)
LogoLabel.Position = UDim2.new(0, 25, 0, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "AisbergHub"
LogoLabel.TextColor3 = Colors.Accent
LogoLabel.TextStrokeTransparency = 0.8
LogoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 28
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = HeaderFrame

-- Status indicator
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 80, 0, 25)
StatusFrame.Position = UDim2.new(0, 240, 0.5, -12.5)
StatusFrame.BackgroundColor3 = Colors.Success
StatusFrame.BackgroundTransparency = 0.2
StatusFrame.Parent = HeaderFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 12)
StatusCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ONLINE"
StatusLabel.TextColor3 = Colors.Text
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.Parent = StatusFrame

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.BackgroundTransparency = 0.1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = HeaderFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

-- Sidebar (Vertical tabs)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 200, 1, -80)
Sidebar.Position = UDim2.new(0, 0, 0, 60)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, -20, 1, -20)
TabContainer.Position = UDim2.new(0, 10, 0, 10)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 4
TabContainer.ScrollBarImageColor3 = Colors.Accent
TabContainer.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabContainer

-- Tab buttons data
local TabData = {
    {name = "🏠 Dashboard", layoutOrder = 1},
    {name = "⚡ Tap Sim", layoutOrder = 2},
    {name = "👁️ Visuals", layoutOrder = 3},
    {name = "🎮 Universal", layoutOrder = 4},
    {name = "🛡️ AntiAFK", layoutOrder = 5},
    {name = "⚙️ Settings", layoutOrder = 6}
}

local TabButtons = {}
for i, data in ipairs(TabData) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "TabBtn" .. i
    TabBtn.Size = UDim2.new(1, 0, 0, 50)
    TabBtn.BackgroundColor3 = Colors.Secondary
    TabBtn.BackgroundTransparency = 0.3
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = data.name
    TabBtn.TextColor3 = Colors.Text
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 15
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.LayoutOrder = data.layoutOrder
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 12)
    TabCorner.Parent = TabBtn
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Colors.Accent
    TabStroke.Thickness = 1.5
    TabStroke.Transparency = i == 1 and 0 or 1
    TabStroke.Parent = TabBtn
    
    TabButtons[i] = {button = TabBtn, stroke = TabStroke}
end

-- Main content area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -220, 1, -80)
ContentArea.Position = UDim2.new(0, 210, 0, 60)
ContentArea.BackgroundColor3 = Colors.Glass
ContentArea.BackgroundTransparency = 0.15
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 16)
ContentCorner.Parent = ContentArea

-- Tab content pages
local TabPages = {}
for i = 1, #TabData do
    local Page = Instance.new("Frame")
    Page.Name = "Page" .. i
    Page.Size = UDim2.new(1, -30, 1, -30)
    Page.Position = UDim2.new(0, 15, 0, 15)
    Page.BackgroundTransparency = 1
    Page.Visible = i == 1
    Page.Parent = ContentArea
    TabPages[i] = Page
end

-- Tap Sim Page content (Page 2)
local TapSimPage = TabPages[2]
local CollectEssenceBtn = Instance.new("TextButton")
CollectEssenceBtn.Size = UDim2.new(0, 280, 0, 60)
CollectEssenceBtn.Position = UDim2.new(0.5, -140, 0, 40)
CollectEssenceBtn.BackgroundColor3 = Colors.Secondary
CollectEssenceBtn.BackgroundTransparency = 0.2
CollectEssenceBtn.BorderSizePixel = 0
CollectEssenceBtn.Text = "💎 Auto Collect Essence"
CollectEssenceBtn.TextColor3 = Colors.Text
CollectEssenceBtn.Font = Enum.Font.GothamBold
CollectEssenceBtn.TextSize = 16
CollectEssenceBtn.AutoButtonColor = false
CollectEssenceBtn.Parent = TapSimPage

local EssenceCorner = Instance.new("UICorner")
EssenceCorner.CornerRadius = UDim.new(0, 14)
EssenceCorner.Parent = CollectEssenceBtn

local CollectChestBtn = Instance.new("TextButton")
CollectChestBtn.Size = UDim2.new(0, 280, 0, 60)
CollectChestBtn.Position = UDim2.new(0.5, -140, 0, 120)
CollectChestBtn.BackgroundColor3 = Colors.Secondary
CollectChestBtn.BackgroundTransparency = 0.2
CollectChestBtn.BorderSizePixel = 0
CollectChestBtn.Text = "📦 Auto Collect Chests"
CollectChestBtn.TextColor3 = Colors.Text
CollectChestBtn.Font = Enum.Font.GothamBold
CollectChestBtn.TextSize = 16
CollectChestBtn.AutoButtonColor = false
CollectChestBtn.Parent = TapSimPage

local ChestCorner = Instance.new("UICorner")
ChestCorner.CornerRadius = UDim.new(0, 14)
ChestCorner.Parent = CollectChestBtn

-- Dashboard welcome text
local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Size = UDim2.new(1, -40, 0, 80)
WelcomeLabel.Position = UDim2.new(0, 20, 0, 20)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Text = "Welcome to AisbergHub Neo\nModern exploit interface"
WelcomeLabel.TextColor3 = Colors.Text
WelcomeLabel.TextScaled = true
WelcomeLabel.Font = Enum.Font.GothamBold
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
WelcomeLabel.Parent = TabPages[1]

-- Footer info
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, -20, 0, 35)
Footer.Position = UDim2.new(0, 10, 1, -45)
Footer.BackgroundColor3 = Colors.Primary
Footer.BackgroundTransparency = 0.3
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 12)
FooterCorner.Parent = Footer

local UserInfo = Instance.new("TextLabel")
UserInfo.Size = UDim2.new(0.5, 0, 1, 0)
UserInfo.BackgroundTransparency = 1
UserInfo.Text = "User: " .. lp.Name
UserInfo.TextColor3 = Colors.TextDim
UserInfo.Font = Enum.Font.Gotham
UserInfo.TextSize = 13
UserInfo.TextXAlignment = Enum.TextXAlignment.Left
UserInfo.Parent = Footer

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0.5, 0, 1, 0)
VersionLabel.Position = UDim2.new(0.5, 0, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v4.0 Neo | by hasberd"
VersionLabel.TextColor3 = Colors.TextDim
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 13
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.Parent = Footer

-- Button hover effects
local function addHoverEffect(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, 10, 1, 8)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
    end)
end

-- Apply hover to all buttons
for _, tabData in pairs(TabButtons) do
    addHoverEffect(tabData.button)
end
addHoverEffect(CollectEssenceBtn)
addHoverEffect(CollectChestBtn)
addHoverEffect(CloseBtn)

-- Tab switching logic
for i, tabData in ipairs(TabButtons) do
    tabData.button.MouseButton1Click:Connect(function()
        CurrentTab = i
        
        -- Update tab highlights
        for j, data in ipairs(TabButtons) do
            TweenService:Create(data.stroke, TweenInfo.new(0.3), {
                Transparency = j == i and 0 or 1
            }):Play()
            TweenService:Create(data.button, TweenInfo.new(0.3), {
                BackgroundTransparency = j == i and 0 or 0.3
            }):Play()
        end
        
        -- Switch content pages
        for j, page in ipairs(TabPages) do
            page.Visible = j == i
        end
    end)
end

-- Toggle functionality (RightCtrl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or isClosed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if isMinimized then
            fadeAllChildren(MainFrame, 0.15, 0.4)
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 720, 0, 480),
                Position = UDim2.new(0.5, -360, 0.5, -240)
            }):Play()
            isMinimized = false
        else
            fadeAllChildren(MainFrame, 0.9, 0.3)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0, 100, 0, 100),
                Position = UDim2.new(1, -120, 1, -120)
            }):Play()
            isMinimized = true
        end
    end
end)

-- Close functionality
CloseBtn.MouseButton1Click:Connect(function()
    fadeAllChildren(MainFrame, 1, 0.4)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play():Wait()
    ScreenGui:Destroy()
    isClosed = true
end)

-- Draggable header
local dragging, dragInput, dragStart, startPos
HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

HeaderFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Initial fade in
fadeAllChildren(MainFrame, 0.15, 0.6)

print("AisbergHub Neo v4.0 loaded! [RightCtrl] = toggle, drag header, modern glassmorphism design")
