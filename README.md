--=== AisbergHub Modern GUI (Complete K Toggle + Smooth Animations) ===--
if getgenv and getgenv().AisbergHubLoaded then return end
if getgenv then getgenv().AisbergHubLoaded = true end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- Colors
local Colors = {
    BG = Color3.fromRGB(15, 15, 20),
    Shadow = Color3.new(0,0,0),
    TextPrimary = Color3.fromRGB(235, 235, 245),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    Button = Color3.fromRGB(40, 40, 55),
    Active = Color3.fromRGB(50, 180, 100)
}

-- State
local isVisible = false
local collectingEssence = false
local collectingChest = false

--================= GUI BASE =================--
local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.BackgroundColor3 = Colors.BG
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 420, 0, 320)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Visible = false
frame.BackgroundTransparency = 1
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Colors.Shadow
shadow.ImageTransparency = 1
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.ZIndex = 0
shadow.Parent = frame

-- Header
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 26)
title.Position = UDim2.new(0, 14, 0, 8)
title.BackgroundTransparency = 1
title.Text = "AisbergHub"
title.TextColor3 = Colors.TextPrimary
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.new(0, 14, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Tap Simulator Utility"
subtitle.TextColor3 = Colors.TextSecondary
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextTransparency = 1
subtitle.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 10)
closeBtn.BackgroundColor3 = Colors.Button
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Colors.TextPrimary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextTransparency = 1
closeBtn.AutoButtonColor = false
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- Status indicator
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 60, 0, 20)
statusFrame.Position = UDim2.new(1, -80, 0, 12)
statusFrame.BackgroundColor3 = Colors.Active
statusFrame.BackgroundTransparency = 1
statusFrame.BorderSizePixel = 0
statusFrame.Parent = frame

local statusCorner = Instance.new("UICorner", statusFrame)
statusCorner.CornerRadius = UDim.new(0, 10)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ACTIVE"
statusLabel.TextColor3 = Colors.TextPrimary
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextTransparency = 1
statusLabel.Parent = statusFrame

-- Tabs container
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -20, 0, 40)
tabsFrame.Position = UDim2.new(0, 10, 0, 60)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.Padding = UDim.new(0, 10)
tabsLayout.Parent = tabsFrame

local tabs = {"⚡ Tap Sim", "👁️ Visuals", "🛡️ Misc"}
local tabButtons = {}
local currentTab = 1

for i, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.BackgroundColor3 = Colors.Button
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Colors.TextSecondary
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.TextTransparency = 1
    tabBtn.BackgroundTransparency = 1
    tabBtn.Parent = tabsFrame
    
    local tabCorner = Instance.new("UICorner", tabBtn)
    tabCorner.CornerRadius = UDim.new(0, 8)
    
    tabButtons[i] = tabBtn
end

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -120)
contentFrame.Position = UDim2.new(0, 10, 0, 105)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

-- Tab contents
local tabContents = {}
for i = 1, #tabs do
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = i == 1
    content.Parent = contentFrame
    tabContents[i] = content
end

-- Tap Sim buttons (Tab 1)
local essenceBtn = Instance.new("TextButton")
essenceBtn.Size = UDim2.new(1, -20, 0, 50)
essenceBtn.Position = UDim2.new(0, 10, 0, 10)
essenceBtn.BackgroundColor3 = Colors.Button
essenceBtn.BorderSizePixel = 0
essenceBtn.Text = "💎 Collect Essence"
essenceBtn.TextColor3 = Colors.TextPrimary
essenceBtn.Font = Enum.Font.Gotham
essenceBtn.TextSize = 15
essenceBtn.TextTransparency = 1
essenceBtn.AutoButtonColor = false
essenceBtn.BackgroundTransparency = 1
essenceBtn.Parent = tabContents[1]

local essenceCorner = Instance.new("UICorner", essenceBtn)
essenceCorner.CornerRadius = UDim.new(0, 10)

local chestBtn = Instance.new("TextButton")
chestBtn.Size = UDim2.new(1, -20, 0, 50)
chestBtn.Position = UDim2.new(0, 10, 0, 70)
chestBtn.BackgroundColor3 = Colors.Button
chestBtn.BorderSizePixel = 0
chestBtn.Text = "📦 Collect Chests"
chestBtn.TextColor3 = Colors.TextPrimary
chestBtn.Font = Enum.Font.Gotham
chestBtn.TextSize = 15
chestBtn.TextTransparency = 1
chestBtn.AutoButtonColor = false
chestBtn.BackgroundTransparency = 1
chestBtn.Parent = tabContents[1]

local chestCorner = Instance.new("UICorner", chestBtn)
chestCorner.CornerRadius = UDim.new(0, 10)

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 20)
footer.Position = UDim2.new(0, 10, 1, -30)
footer.BackgroundTransparency = 1
footer.Text = "User: " .. lp.Name .. " | Tap Simulator | v2.0"
footer.TextColor3 = Colors.TextSecondary
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextTransparency = 1
footer.Parent = frame

--================= ANIMATIONS & LOGIC =================--
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function fadeAll(targetTransparency)
    for _, obj in pairs(frame:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.BackgroundTransparency ~= nil then
            local goals = {BackgroundTransparency = targetTransparency}
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                goals.TextTransparency = targetTransparency
            elseif obj:IsA("ImageLabel") then
                goals.ImageTransparency = targetTransparency
            end
            TweenService:Create(obj, fadeInfo, goals):Play()
        end
    end
end

-- Tab switching
for i, tabBtn in ipairs(tabButtons) do
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        for j, btn in ipairs(tabButtons) do
            TweenService:Create(btn, tweenInfo, {
                BackgroundTransparency = j == i and 0.1 or 0.4,
                TextColor3 = j == i and Colors.TextPrimary or Colors.TextSecondary,
                BackgroundColor3 = j == i and Colors.Active or Colors.Button
            }):Play()
        end
        
        for j, content in ipairs(tabContents) do
            content.Visible = j == i
        end
    end)
end

-- Toggle buttons
essenceBtn.MouseButton1Click:Connect(function()
    collectingEssence = not collectingEssence
    TweenService:Create(essenceBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = collectingEssence and Colors.Active or Colors.Button,
        BackgroundTransparency = 0.2
    }):Play()
    print("Essence collector:", collectingEssence)
end)

chestBtn.MouseButton1Click:Connect(function()
    collectingChest = not collectingChest
    TweenService:Create(chestBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = collectingChest and Colors.Active or Colors.Button,
        BackgroundTransparency = 0.2
    }):Play()
    print("Chest collector:", collectingChest)
end)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    isVisible = false
    fadeAll(1)
    TweenService:Create(frame, fadeInfo, {
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(1, -90, 1, -90)
    }):Play()
end)

-- ✅ ПЛАВНЫЙ K TOGGLE (основная фича)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        isVisible = not isVisible
        
        if isVisible then
            -- ПЛАВНОЕ ОТКРЫТИЕ
            frame.Visible = true
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = UDim2.new(0.5, 0, 0.5, 0)
            frame.BackgroundTransparency = 1
            shadow.ImageTransparency = 1
            
            local openTween = TweenService:Create(frame, tweenInfo, {
                Size = UDim2.new(0, 420, 0, 320),
                BackgroundTransparency = 0.4
            })
            
            TweenService:Create(shadow, TweenInfo.new(0.5), {
                ImageTransparency = 0.6
            }):Play()
            
            openTween:Play()
            openTween.Completed:Connect(function()
                fadeAll(0.4)
            end)
            
        else
            -- ПЛАВНОЕ ЗАКРЫТИЕ
            fadeAll(1)
            TweenService:Create(frame, fadeInfo, {
                Size = UDim2.new(0, 80, 0, 80),
                Position = UDim2.new(1, -90, 1, -90),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(shadow, fadeInfo, {ImageTransparency = 1}):Play()
        end
    end
end)

-- Draggable
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isVisible then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("AisbergHub v2.0 loaded! Press [K] for smooth menu toggle")
