-- СВОЙ МИНИ-ХАБ БЕЗ БИБЛИОТЕК

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- создаём ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "MySimpleHub"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-- фрейм (окно меню)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 150)
frame.Position = UDim2.new(0.5, -130, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

-- заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "My Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- кнопка скорости
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 40)
speedBtn.Position = UDim2.new(0, 10, 0, 40)
speedBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
speedBtn.BorderSizePixel = 0
speedBtn.Text = "Speed: OFF"
speedBtn.TextColor3 = Color3.new(1, 1, 1)
speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.TextSize = 18
speedBtn.Parent = frame

local speedOn = false

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speedOn and 50 or 16
        speedBtn.Text = speedOn and "Speed: ON" or "Speed: OFF"
        speedBtn.BackgroundColor3 = speedOn and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
    end
end)

print("MySimpleHub загружен: окно по центру экрана")
