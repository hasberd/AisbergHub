-- Midnight Chasers GUI (DriveSeat control, car in Workspace)

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local Workspace    = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- GUI с крестиком
--------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MidnightChasersGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 190)
mainFrame.Position = UDim2.new(0, 20, 0.5, -95)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.Text = "Midnight Chasers GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Parent = title

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

--------------------------------------------------
-- Remove NPCVehicles
--------------------------------------------------

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(1, -20, 0, 30)
removeBtn.Position = UDim2.new(0, 10, 0, 40)
removeBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
removeBtn.BorderSizePixel = 0
removeBtn.Font = Enum.Font.GothamBold
removeBtn.Text = "Remove NPC Vehicles"
removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
removeBtn.TextSize = 14
removeBtn.Parent = mainFrame

removeBtn.MouseButton1Click:Connect(function()
    local folder = Workspace:FindFirstChild("NPCVehicles")
    if folder then
        folder:Destroy()
    else
        warn("NPCVehicles folder not found in Workspace")
    end
end)

--------------------------------------------------
-- Ввод «скорости» (Throttle)
--------------------------------------------------

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 80)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = "Throttle (0–1):"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Name = "SpeedBox"
speedBox.Size = UDim2.new(1, -20, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 105)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.BorderSizePixel = 0
speedBox.Font = Enum.Font.Gotham
speedBox.PlaceholderText = "например 1 или 0.7"
speedBox.Text = "1"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false
speedBox.Parent = mainFrame

local throttleValue = 1

speedBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local value = tonumber(speedBox.Text)
    if value then
        value = math.clamp(value, -1, 1)
        throttleValue = value
        speedBox.Text = tostring(value)
    else
        speedBox.Text = tostring(throttleValue)
    end
end)

--------------------------------------------------
-- Autofarm через DriveSeat (машина в Workspace)
--------------------------------------------------

local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(1, -20, 0, 35)
autofarmBtn.Position = UDim2.new(0, 10, 1, -45)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
autofarmBtn.BorderSizePixel = 0
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.Text = "Start Autofarm"
autofarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autofarmBtn.TextSize = 16
autofarmBtn.Parent = mainFrame

local running = false
local driveSeat

-- Ищем машину прямо в Workspace: "<ник>'s Car"
local function getDriveSeat()
    local carName = LocalPlayer.Name .. "'s Car"
    local car = Workspace:FindFirstChild(carName)
    if not car or not car:IsA("Model") then
        warn("car model not found in Workspace: " .. carName)
        return nil
    end

    local seat = car:FindFirstChild("DriveSeat", true)
    if not seat or not seat:IsA("VehicleSeat") then
        warn("DriveSeat not found in car")
        return nil
    end
    return seat
end

-- направление руля (0 = прямо)
local steerDirection = 0

local function startAutofarm()
    if running then return end
    running = true
    autofarmBtn.Text = "Stop Autofarm"

    driveSeat = getDriveSeat()
    if not driveSeat then
        running = false
        autofarmBtn.Text = "Start Autofarm"
        return
    end

    -- постоянный газ, как будто зажата W
    driveSeat.ThrottleFloat = throttleValue
    driveSeat.SteerFloat    = steerDirection
end

local function stopAutofarm()
    running = false
    autofarmBtn.Text = "Start Autofarm"
    if driveSeat then
        driveSeat.ThrottleFloat = 0
        driveSeat.SteerFloat    = 0
    end
end

autofarmBtn.MouseButton1Click:Connect(function()
    if running then
        stopAutofarm()
    else
        startAutofarm()
    end
end)

--------------------------------------------------
-- Тоггл GUI на G
--------------------------------------------------

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.G then
        if screenGui and screenGui.Parent then
            screenGui.Enabled = not screenGui.Enabled
        end
    end
end)
