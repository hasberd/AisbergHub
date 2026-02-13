-- МЯГКОЕ МЕНЮ С K + SLIDE + FADE

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 1, 10) -- старт снизу (за экраном)
frame.Visible = false
frame.BackgroundTransparency = 1 -- для fade
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.4
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.ZIndex = 0
shadow.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "My Soft Menu"
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextTransparency = 1
closeBtn.AutoButtonColor = false
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local fullBtn = Instance.new("TextButton")
fullBtn.Size = UDim2.new(0, 110, 0, 30)
fullBtn.Position = UDim2.new(0, 10, 0, 40)
fullBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
fullBtn.BorderSizePixel = 0
fullBtn.Text = "Во весь экран"
fullBtn.TextColor3 = Color3.fromRGB(230,230,240)
fullBtn.Font = Enum.Font.Gotham
fullBtn.TextSize = 16
fullBtn.TextTransparency = 1
fullBtn.AutoButtonColor = false
fullBtn.Parent = frame
Instance.new("UICorner", fullBtn).CornerRadius = UDim.new(0, 8)

local normalBtn = Instance.new("TextButton")
normalBtn.Size = UDim2.new(0, 150, 0, 30)
normalBtn.Position = UDim2.new(0, 10, 0, 80)
normalBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
normalBtn.BorderSizePixel = 0
normalBtn.Text = "Обычный размер"
normalBtn.TextColor3 = Color3.fromRGB(230,230,240)
normalBtn.Font = Enum.Font.Gotham
normalBtn.TextSize = 16
normalBtn.TextTransparency = 1
normalBtn.AutoButtonColor = false
normalBtn.Parent = frame
Instance.new("UICorner", normalBtn).CornerRadius = UDim.new(0, 8)

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 110, 0, 30)
hideBtn.Position = UDim2.new(0, 10, 0, 120)
hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
hideBtn.BorderSizePixel = 0
hideBtn.Text = "Скрыть меню"
hideBtn.TextColor3 = Color3.fromRGB(230,230,240)
hideBtn.Font = Enum.Font.Gotham
hideBtn.TextSize = 16
hideBtn.TextTransparency = 1
hideBtn.AutoButtonColor = false
hideBtn.Parent = frame
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

-- Состояния
local isVisible = false
local isFullScreen = false

-- Настройки твина
local tweenTime = 0.35
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

-- Функции fade/slide
local function fadeIn()
    frame.Visible = true
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Position = UDim2.new(0.5, -160, 0.5, -100),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(title, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    TweenService:Create(fullBtn, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    TweenService:Create(normalBtn, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    TweenService:Create(hideBtn, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
end

local function fadeOut(callback)
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Position = UDim2.new(0.5, -160, 1, 10),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(title, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    TweenService:Create(fullBtn, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    TweenService:Create(normalBtn, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    TweenService:Create(hideBtn, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    task.delay(tweenTime, function()
        frame.Visible = false
        if callback then callback() end
    end)
end

local function setNormal()
    isFullScreen = false
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(0, 320, 0, 200),
        Position = UDim2.new(0.5, -160, 0.5, -100)
    }):Play()
end

local function setFull()
    isFullScreen = true
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
end

fullBtn.MouseButton1Click:Connect(function()
    setFull()
end)

normalBtn.MouseButton1Click:Connect(function()
    setNormal()
end)

hideBtn.MouseButton1Click:Connect(function()
    if isVisible then
        isVisible = false
        fadeOut()
    end
end)

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

-- Тоггл на K с slide + fade
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        isVisible = not isVisible
        if isVisible then
            fadeIn()
        else
            fadeOut()
        end
    end
end)

print("SoftMenu с tween-анимацией загружено. Нажми K.")
