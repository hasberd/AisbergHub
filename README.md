-- Midnight Chasers GUI (debug + autofarm)

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
-- Ввод скорости (TextBox)
--------------------------------------------------

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 80)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = "Speed:"
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
speedBox.PlaceholderText = "Введите скорость, напр. 100"
speedBox.Text = "100"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false
speedBox.Parent = mainFrame

local speed = 100

speedBox:GetPropertyChangedSignal("Text"):Connect(function()
    local onlyNums = speedBox.Text:gsub("%D", "")
    if onlyNums == "" then
        speedBox.Text = ""
    else
        speedBox.Text = onlyNums
    end
end)

speedBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local value = tonumber(speedBox.Text)
    if value and value > 0 then
        speed = value
    else
        speedBox.Text = tostring(speed)
    end
end)

--------------------------------------------------
-- Autofarm (debug‑версия)
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
local tween

-- Workspace
--   bonitoscocos (Model)
--     bonitoscocos's Car (Model)
local function getPlayerCar()
    local playerModel = Workspace:FindFirstChild(LocalPlayer.Name)
    if not playerModel then
        warn("player model not found in Workspace: " .. LocalPlayer.Name)
        return nil
    end

    local carName = LocalPlayer.Name .. "'s Car"
    local car = playerModel:FindFirstChild(carName)
    if not car then
        warn("car model not found inside player model: " .. carName)
        return nil
    end
    if not car:IsA("Model") then
        warn("found object is not a Model")
        return nil
    end
    return car
end

local function ensurePrimaryPart(car)
    if not car.PrimaryPart then
        local seat = car:FindFirstChild("DriveSeat", true)
        if seat and seat:IsA("BasePart") then
            car.PrimaryPart = seat
        end
    end
    return car.PrimaryPart
end

-- Для теста двигаем машину недалеко
local function getTestPoints(primary)
    local startPos = primary.Position
    local finishPos = startPos + Vector3.new(0, 0, 100)
    return startPos, finishPos
end

local function startAutofarm()
    if running then return end
    running = true
    autofarmBtn.Text = "Stop Autofarm"

    local car = getPlayerCar()
    if not car then
        running = false
        autofarmBtn.Text = "Start Autofarm"
        return
    end

    local primary = ensurePrimaryPart(car)
    if not primary then
        warn("PrimaryPart not set even after ensurePrimaryPart")
        running = false
        autofarmBtn.Text = "Start Autofarm"
        return
    end

    for _, p in ipairs(car:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = true
        end
    end

    local pointA, pointB = getTestPoints(primary)

    car:PivotTo(CFrame.new(pointA))  -- стартовая позиция

    local dist = (pointA - pointB).Magnitude
    local time = dist / math.max(speed, 1)

    local info = TweenInfo.new(
        time,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1,
        true,
        0
    )

    tween = TweenService:Create(primary, info, {CFrame = CFrame.new(pointB)})
    tween:Play()
end

local function stopAutofarm()
    running = false
    autofarmBtn.Text = "Start Autofarm"
    if tween then tween:Cancel() end
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
