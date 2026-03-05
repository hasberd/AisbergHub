-- ВСТАВЬ ЭТО ВМЕСТО БЛОКА "Autofarm" В ТВОЁМ СКРИПТЕ

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

-- 1) Находим именно структуру вида:
-- Workspace
--   bonitoscocos (модель)
--     bonitoscocos's Car (модель)
local function getPlayerCar()
    local playerModel = Workspace:FindFirstChild(LocalPlayer.Name)
    if not playerModel then
        warn("player model not found in Workspace: ".. LocalPlayer.Name)
        return nil
    end

    local carName = LocalPlayer.Name .. "'s Car"
    local car = playerModel:FindFirstChild(carName)
    if not car then
        warn("car model not found inside player model: ".. carName)
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

-- ПОДМЕНИ ЭТИ ТОЧКИ НА СВОИ
local pointA = Vector3.new(0, 5, 0)
local pointB = Vector3.new(200, 5, 0)

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

    -- якорим все части, чтобы физика не мешала
    for _, p in ipairs(car:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = true
        end
    end

    -- ставим в стартовую точку
    car:PivotTo(CFrame.new(pointA))

    local dist = (pointA - pointB).Magnitude
    local time = dist / math.max(speed, 1)

    local info = TweenInfo.new(
        time,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1,    -- бесконечно
        true,  -- туда‑обратно
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
