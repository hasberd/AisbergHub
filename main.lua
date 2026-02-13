-- МЯГКОЕ МЕНЮ С РЕЖИМАМИ И КЛАВИШЕЙ K

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SoftMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

-- Основной фрейм
local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.5, -100)
frame.Visible = false
frame.Parent = gui

-- Мягкие углы
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

-- Тень
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.3
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.ZIndex = 0
shadow.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "My Soft Menu"
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Кнопка закрытия (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Кнопка "на весь экран"
local fullBtn = Instance.new("TextButton")
fullBtn.Size = UDim2.new(0, 110, 0, 30)
fullBtn.Position = UDim2.new(0, 10, 0, 40)
fullBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
fullBtn.BorderSizePixel = 0
fullBtn.Text = "Во весь экран"
fullBtn.TextColor3 = Color3.fromRGB(230,230,240)
fullBtn.Font = Enum.Font.Gotham
fullBtn.TextSize = 16
fullBtn.Parent = frame
Instance.new("UICorner", fullBtn).CornerRadius = UDim.new(0, 8)

-- Кнопка обычного размера
local normalBtn = Instance.new("TextButton")
normalBtn.Size = UDim2.new(0, 150, 0, 30)
normalBtn.Position = UDim2.new(0, 10, 0, 80)
normalBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
normalBtn.BorderSizePixel = 0
normalBtn.Text = "Обычный размер"
normalBtn.TextColor3 = Color3.fromRGB(230,230,240)
normalBtn.Font = Enum.Font.Gotham
normalBtn.TextSize = 16
normalBtn.Parent = frame
Instance.new("UICorner", normalBtn).CornerRadius = UDim.new(0, 8)

-- Кнопка скрытия (свернуть)
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 110, 0, 30)
hideBtn.Position = UDim2.new(0, 10, 0, 120)
hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
hideBtn.BorderSizePixel = 0
hideBtn.Text = "Скрыть меню"
hideBtn.TextColor3 = Color3.fromRGB(230,230,240)
hideBtn.Font = Enum.Font.Gotham
hideBtn.TextSize = 16
hideBtn.Parent = frame
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

-- Состояние
local isVisible = false
local isFullScreen = false

-- Функции режимов
local function setNormal()
    isFullScreen = false
    frame.Size = UDim2.new(0, 320, 0, 200)
    frame.Position = UDim2.new(0.5, -160, 0.5, -100)
end

local function setFull()
    isFullScreen = true
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
end

-- Клики по кнопкам
fullBtn.MouseButton1Click:Connect(function()
    setFull()
end)

normalBtn.MouseButton1Click:Connect(function()
    setNormal()
end)

hideBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    isVisible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- Тоггл по клавише K
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        isVisible = not isVisible
        frame.Visible = isVisible
    end
end)

print("SoftMenu загружено. Нажми K, чтобы открыть/закрыть.")
