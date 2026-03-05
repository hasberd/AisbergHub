-- Midnight Chasers Utility GUI
-- ВСТАВЛЯТЬ в executor как LocalScript (эксплойт)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

---------------------------------------------------------------------
-- 1. Создание GUI
---------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MidnightChasersGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 180)
mainFrame.Position = UDim2.new(0, 20, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.Text = "Midnight Chasers GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Parent = mainFrame

---------------------------------------------------------------------
-- 2. Кнопка Remove NPC Vehicles
---------------------------------------------------------------------

local removeNPCBtn = Instance.new("TextButton")
removeNPCBtn.Name = "RemoveNPCButton"
removeNPCBtn.Size = UDim2.new(1, -20, 0, 30)
removeNPCBtn.Position = UDim2.new(0, 10, 0, 40)
removeNPCBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
removeNPCBtn.BorderSizePixel = 0
removeNPCBtn.Font = Enum.Font.GothamBold
removeNPCBtn.Text = "Remove NPC Vehicles"
removeNPCBtn.TextSize = 14
removeNPCBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
removeNPCBtn.Parent = mainFrame

removeNPCBtn.MouseButton1Click:Connect(function()
    local folder = Workspace:FindFirstChild("NPCVechicles")
    if folder then
        folder:Destroy()
    end
end)

---------------------------------------------------------------------
-- 3. Выбор скорости для Autofarm
---------------------------------------------------------------------

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 80)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Center
speedLabel.Parent = mainFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Name = "SpeedMinus"
minusBtn.Size = UDim2.new(0, 40, 0, 25)
minusBtn.Position = UDim2.new(0, 10, 0, 110)
minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minusBtn.BorderSizePixel = 0
minusBtn.Font = Enum.Font.GothamBold
minusBtn.Text = "-"
minusBtn.TextSize = 18
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Parent = mainFrame

local plusBtn = Instance.new("TextButton")
plusBtn.Name = "SpeedPlus"
plusBtn.Size = UDim2.new(0, 40, 0, 25)
plusBtn.Position = UDim2.new(1, -50, 0, 110)
plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
plusBtn.BorderSizePixel = 0
plusBtn.Font = Enum.Font.GothamBold
plusBtn.Text = "+"
plusBtn.TextSize = 18
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Parent = mainFrame

local speed = 50
local minSpeed, maxSpeed, step = 10, 200, 10

local function updateSpeedLabel()
    speedLabel.Text = "Speed: " .. speed
end
updateSpeedLabel()

minusBtn.MouseButton1Click:Connect(function()
    speed = math.clamp(speed - step, minSpeed, maxSpeed)
    updateSpeedLabel()
end)

plusBtn.MouseButton1Click:Connect(function()
    speed = math.clamp(speed + step, minSpeed, maxSpeed)
    updateSpeedLabel()
end)

---------------------------------------------------------------------
-- 4. Кнопка Autofarm (движущаяся платформа для машины)
---------------------------------------------------------------------

local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Name = "AutofarmButton"
autofarmBtn.Size = UDim2.new(1, -20, 0, 35)
autofarmBtn.Position = UDim2.new(0, 10, 1, -45)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
autofarmBtn.BorderSizePixel = 0
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.Text = "Start Autofarm"
autofarmBtn.TextSize = 16
autofarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autofarmBtn.Parent = mainFrame

local autofarmRunning = false
local platform
local tween

-- НАСТРОЙ ЭТИ ТОЧКИ ПОД СВОЙ МАРШРУТ
local pointA = Vector3.new(0, 5, 0)       -- старт
local pointB = Vector3.new(600, 5, 0)     -- конец (например вдоль хайвея)

local function createPlatform()
    local p = Instance.new("Part")
    p.Name = "AutofarmPlatform"
    p.Size = Vector3.new(10, 1, 6)
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 1
    p.Position = pointA
    p.Parent = Workspace
    return p
end

local function attachCarToPlatform(carModel, p)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = carModel.PrimaryPart
    weld.Part1 = p
    weld.Parent = carModel.PrimaryPart
end

local function getPlayerCar()
    -- ПОДРЕДАКТИРУЙ под структуру Midnight Chasers:
    -- ищем модель, где в имени ник игрока
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("VehicleSeat", true) then
            if string.find(obj.Name, LocalPlayer.Name) then
                return obj
            end
        end
    end
    return nil
end

local function startAutofarm()
    if autofarmRunning then return end
    autofarmRunning = true
    autofarmBtn.Text = "Stop Autofarm"

    local car = getPlayerCar()
    if not car or not car.PrimaryPart then
        warn("Car not found – поправь функцию getPlayerCar() под игру")
        autofarmRunning = false
        autofarmBtn.Text = "Start Autofarm"
        return
    end

    platform = createPlatform()
    attachCarToPlatform(car, platform)

    local distance = (pointA - pointB).Magnitude
    local time = distance / speed  -- чем больше speed, тем быстрее

    local info = TweenInfo.new(
        time,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1,       -- бесконечно
        true,     -- туда‑обратно
        0
    )

    tween = TweenService:Create(platform, info, {Position = pointB})
    tween:Play()
end

local function stopAutofarm()
    autofarmRunning = false
    autofarmBtn.Text = "Start Autofarm"
    if tween then tween:Cancel() end
    if platform then platform:Destroy() end
end

autofarmBtn.MouseButton1Click:Connect(function()
    if autofarmRunning then
        stopAutofarm()
    else
        startAutofarm()
    end
end)

---------------------------------------------------------------------
-- 5. Открытие/закрытие GUI на клавишу (например, G)
---------------------------------------------------------------------

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.G then
        screenGui.Enabled = not screenGui.Enabled
    end
end)
