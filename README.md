-- Midnight Chasers GUI: Autofarm (с очисткой мира) + Auto City Highway Race 🏁 (solo, цикл гонок)

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- GUI
--------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MidnightChasersGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 230)
mainFrame.Position = UDim2.new(0, 20, 0.5, -115)
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
    end
end)

--------------------------------------------------
-- Speed
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
speedBox.PlaceholderText = "200–350 норм"
speedBox.Text = "250"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false
speedBox.Parent = mainFrame

local function getSpeed()
    local n = tonumber(speedBox.Text)
    if not n or n <= 0 then
        n = 250
        speedBox.Text = "250"
    end
    return n
end

--------------------------------------------------
-- Очистка мира (только для Autofarm)
--------------------------------------------------

local function hideWorkspaceObjects(plr)
    if not ReplicatedStorage:FindFirstChild("mrbackupfolder") then
        local folder = Instance.new("Folder")
        folder.Name = "mrbackupfolder"
        folder.Parent = ReplicatedStorage
    end
    local backup = ReplicatedStorage:FindFirstChild("mrbackupfolder")

    local mustRemoveByName = {
        Bush = true,
        BeltPole = true,
        Bridge = true,
        BridgeAccent = true,
        Curve = true,
        GarageLamp = true,
        Hangar = true,
        HedgeTall = true,
        MapBoard = true,
        PortCraneOversized = true,
        RailGuide = true
    }

    for _, v in pairs(Workspace:GetChildren()) do
        local name = v.Name or ""
        local isPlayerCar = string.find(name, plr.Name) or string.find(name, plr.DisplayName)

        if v == Workspace.Terrain then
            continue
        end

        if mustRemoveByName[name] then
            v.Parent = backup
            continue
        end

        if (v:IsA("Model") or v:IsA("Folder") or v:IsA("MeshPart"))
            and not isPlayerCar
            and name ~= "" then
            v.Parent = backup
        end
    end
end

local function restoreWorkspaceObjects()
    local backup = ReplicatedStorage:FindFirstChild("mrbackupfolder")
    if backup then
        for _, v in pairs(backup:GetChildren()) do
            v.Parent = Workspace
            task.wait()
        end
    end
end

--------------------------------------------------
-- Платформа и движение
--------------------------------------------------

local function ensureGroundPart()
    if not _G.ooga then
        local new = Instance.new("Part")
        new.Name = "AisbergGround"
        new.Anchored = true
        new.Size = Vector3.new(10000, 10, 10000)
        new.Transparency = 1
        new.CanCollide = true
        new.Parent = Workspace
        _G.ooga = new
    end
end

local currentTween

local function tweenToPosition(car, targetCFrame, speed)
    local plr = LocalPlayer
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = targetCFrame.Position
    local dist = (hrp.Position - targetPos).Magnitude
    local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

    local cfValue = Instance.new("CFrameValue")
    cfValue.Value = car:GetPrimaryPartCFrame()

    cfValue.Changed:Connect(function()
        local pos = cfValue.Value.Position
        _G.ooga.Position = pos - Vector3.new(0, 14, 0)
        car:PivotTo(CFrame.new(_G.ooga.Position + Vector3.new(0, 7, 0), targetPos))
        local vel = car.PrimaryPart.CFrame.LookVector * speed
        car.PrimaryPart.AssemblyLinearVelocity = vel
    end)

    if currentTween then
        currentTween:Cancel()
    end
    currentTween = TweenService:Create(cfValue, info, {Value = targetCFrame})
    currentTween:Play()

    repeat task.wait() until currentTween.PlaybackState ~= Enum.PlaybackState.Playing

    cfValue:Destroy()
end

--------------------------------------------------
-- Маршрут для обычного фарма
--------------------------------------------------

local farmFrames = {
    CFrame.new(105.419128, -26.0098934, 7965.37988, -3.36e-05, 0.951051414, -0.309032798, -1, -3.36e-05, 5.32e-06, -5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(2751.86499, -26.0098934, 3694.63354, 3.35e-05, 0.951051414, -0.309032798, -1, 3.35e-05, -5.32e-06, 5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(-8821.48438, -26.0098934, 2042.49939, -3.36e-05, 0.951051414, -0.309032798, -1, -3.36e-05, 5.32e-06, -5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(-6408.62109, -26.0098934, -727.765198, 3.35e-05, 0.951051414, -0.309032798, -1, 3.35e-05, -5.32e-06, 5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(-6099.79639, -26.00989345, -1027.94556, -3.36e-05, 0.951051414, -0.309032798, -1, -3.36e-05, 5.32e-06, -5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(-6066.70068, -26.0098934, 493.255524, 3.35e-05, 0.951051414, -0.309032798, -1, 3.35e-05, -5.32e-06, 5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(132.786133, -26.0098934, 15.2286377, 3.35e-05, 0.951051414, -0.309032798, -1, 3.35e-05, -5.32e-06, 5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(-7692.85449, -26.0098934, -4668.61963, -3.36e-05, 0.951051414, -0.309032798, -1, -3.36e-05, 5.32e-06, -5.32e-06, 0.309032798, 0.951051414),
    CFrame.new(4887.24609, -26.0098934, 1222.96826, -3.36e-05, 0.951051414, -0.309032798, -1, -3.36e-05, 5.32e-06, -5.32e-06, 0.309032798, 0.951051414)
}

--------------------------------------------------
-- City Highway Race чекпоинты (последний — Finish)
--------------------------------------------------

local race1Frames = {
    CFrame.new(3322.75391, -2.98221874, 856.207031, 0.961249948, 0, -0.275678426, 0, 1, 0, 0.275678426, 0, 0.961249948),
    CFrame.new(3029.10547, -2.98221874, 660.068298, 0.90629667, 0, -0.422642082, 0, 1, 0, 0.422642082, 0, 0.90629667),
    CFrame.new(2712.34058, -2.71214509, 551.92157, 0.961249948, 0, -0.275678426, 0, 1, 0, 0.275678426, 0, 0.961249948),
    CFrame.new(2243.67383, 11.4915237, 400.449432, 0.961249948, 0, -0.275678426, 0, 1, 0, 0.275678426, 0, 0.961249948),
    CFrame.new(1904.4292, 26.7461739, 291.238892, 0.961249948, 0, -0.275678426, 0, 1, 0, 0.275678426, 0, 0.961249948),
    CFrame.new(1530.24976, 31.9470787, 174.713318, 0.961249948, 0, -0.275678426, 0, 1, 0, 0.275678426, 0, 0.961249948),
    CFrame.new(1003.00555, 31.9470787, 89.626709, 0.997561574, 0, -0.0697919354, 0, 1, 0, 0.0697919354, 0, 0.997561574),
    CFrame.new(650.276245, 31.9470787, 85.0392456, 0.997561574, 0, -0.0697919354, 0, 1, 0, 0.0697919354, 0, 0.997561574),
    CFrame.new(-70.900238, 31.9470787, 85.0537109, 0.997561574, 0, -0.0697919354, 0, 1, 0, 0.0697919354, 0, 0.997561574),
    CFrame.new(-598.24646, 31.9470787, 90.0340347, 0.999847949, 0, -0.017436387, 0, 1, 0, 0.017436387, 0, 0.999847949),
    CFrame.new(-1268.20715, 27.0799713, 127.024689, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    CFrame.new(-1907.91687, 0.0381088257, 273.76712, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    CFrame.new(-2636.75439, 1.82433498, 428.236969, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    CFrame.new(-3216.68896, 31.0067902, 553.627808, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-3950.38281, 35.2188492, 709.579285, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-4660.51465, 42.7382584, 850.088745, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-5585.84326, 31.2532387, 1047.83704, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-6619.23975, 21.7995338, 1267.49231, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-7327.26025, 22.3056812, 1417.98682, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-7820.7583, 21.3901939, 1591.68262, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-8344.27539, 20.6600914, 1812.5863, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-8820.78027, -8.071908, 2015.47388, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-9545.16992, -71.8721237, 2322.55127, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-10178.4844, -110.570114, 2591.98633, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-10954.001, -101.621788, 2920.5835, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-11599.6211, -49.2231827, 3194.64307, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-12213.9854, -3.47495794, 3455.35791, 0.919960797, 0.0320986696, 0.390693992, -0.0348859616, 0.999391317, 0, -0.390454978, -0.0136640742, 0.920520604),
    CFrame.new(-12793.209, 10.828455, 3767.78052, 0.81912142, 0.00712457765, 0.573575914, -0.00868201349, 0.99996233, 0, -0.573554456, -0.0049616769, 0.819152415),
    CFrame.new(-13161.6553, 11.159811, 4079.8335, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247),
    CFrame.new(-13403.7881, 11.0526257, 4361.42969, 0.601813793, 0, 0.798636556, 0, 1, 0, -0.798636556, 0, 0.601813793),
    CFrame.new(-13679.3564, 8.66459465, 4764.74365, 0.559090972, -0.00979252718, 0.829048514, 0.0174922645, 0.999846995, 0, -0.828921795, 0.0144943399, 0.559176683),
    CFrame.new(-14051.54, -1.67275488, 5316.52441, 0.559090972, -0.00979252718, 0.829048514, 0.0174922645, 0.999846995, 0, -0.828921795, 0.0144943399, 0.559176683),
    CFrame.new(-14523.7363, 15.3383675, 6016.58105, 0.559090972, -0.00979252718, 0.829048514, 0.0174922645, 0.999846995, 0, -0.828921795, 0.0144943399, 0.559176683),
    CFrame.new(-14915.6709, 18.7657909, 6628.46875, 0.492420912, 0, 0.870357215, 0, 1, 0, -0.870357215, 0, 0.492420912),
    CFrame.new(-15249.7275, 18.6684055, 7331.59912, 0.36646831, 0, 0.930430532, 0, 1, 0, -0.930430532, 0, 0.36646831),
    CFrame.new(-15492.6279, 15.5853186, 8070.8833, 0.292322516, -0.00514886947, 0.956305981, 0.0174715482, 0.999847353, 0, -0.956160188, 0.0166956857, 0.292367876),
    CFrame.new(-15689.4658, 3.47872114, 8714.70117, 0.292322516, -0.00514886947, 0.956305981, 0.0174715482, 0.999847353, 0, -0.956160188, 0.0166956857, 0.292367876),
    CFrame.new(-15938.4365, -8.56782627, 9528.88477, 0.292318881, 0, 0.956320882, 0, 1, 0, -0.956320882, 0, 0.292318881),
    CFrame.new(-16209.9053, 10.1734743, 10416.8262, 0.292318881, 0, 0.956320882, 0, 1, 0, -0.956320882, 0, 0.292318881),
    CFrame.new(-16381.2129, 20.5226669, 11257.2275, 0.15644598, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, 0.15644598),
    CFrame.new(-16520.5859, 23.4347839, 12137.5049, 0.156420708, 0.0034087766, 0.987684667, -0.0217956547, 0.999762475, 0, -0.987450063, -0.0215274431, 0.156457841)
}

--------------------------------------------------
-- Получение машины
--------------------------------------------------

local function getCar()
    local plr = LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat then return nil end

    local car = seat.Parent
    local body = car:FindFirstChild("Body")
    local weight = body and body:FindFirstChild("#Weight")
    if not weight then
        warn("Не найден Body/#Weight в машине")
        return nil
    end

    car.PrimaryPart = weight
    return car
end

local autofarmRunning = false
local race1Running   = false

--------------------------------------------------
-- Автофарм (с очисткой мира, циклом)
--------------------------------------------------

local function runFarmRoute()
    autofarmRunning = true

    local plr = LocalPlayer
    hideWorkspaceObjects(plr)
    ensureGroundPart()
    task.wait()

    while autofarmRunning do
        local car = getCar()
        if not car then
            task.wait(0.5)
        else
            local speed = getSpeed()
            for _, cf in ipairs(farmFrames) do
                if not autofarmRunning then break end
                tweenToPosition(car, cf + Vector3.new(0, 5, 0), speed)
            end
        end
    end

    if currentTween then
        currentTween:Cancel()
    end
    restoreWorkspaceObjects()
end

--------------------------------------------------
-- City Highway Race: Solo
--------------------------------------------------

local function getRace1()
    local races = Workspace:FindFirstChild("Races")
    if not races then return nil end
    return races:FindFirstChild("Race1")
end

local function getRace1Config()
    local race1 = getRace1()
    if not race1 then return nil end
    return race1:FindFirstChild("Config")
end

local function teleportToRaceStart()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(
        3260.53076, -7.51575422, 1015.698,
        -3.36170197e-05, -0.951051414, -0.309032798,
        1, -3.36170197e-05, -5.31971455e-06,
        -5.31971455e-06, -0.309032798, 0.951051414
    )
end

local function startSoloRace()
    local config = getRace1Config()
    if not config then return end

    local solo = config:FindFirstChild("Solo")
    if solo and solo:IsA("BoolValue") then
        solo.Value = true
    end
end

--------------------------------------------------
-- Auto City Highway Race 🏁: цикл гонок
--------------------------------------------------

local function runCityHighwayRoute()
    race1Running = true

    while race1Running do
        -- 1) сразу телепорт на старт
        teleportToRaceStart()
        if not race1Running then break end

        -- 2) включаем Solo
        startSoloRace()
        if not race1Running then break end

        -- 3) ждём 4 секунды перед началом движения
        task.wait(4)
        if not race1Running then break end

        -- 4) ждём машину (пока ты сядешь)
        local car
        for i = 1, 60 do
            car = getCar()
            if car then break end
            task.wait(0.1)
            if not race1Running then break end
        end
        if not race1Running or not car then
            break
        end

        ensureGroundPart()
        local speed = getSpeed()

        -- 5) едем по чекпоинтам до последнего (Finish)
        for idx, cf in ipairs(race1Frames) do
            if not race1Running then break end
            tweenToPosition(car, cf + Vector3.new(0, 5, 0), speed)

            if idx == #race1Frames then
                break
            end
        end

        if currentTween then
            currentTween:Cancel()
        end
        if not race1Running then break end

        -- 6) после Finish: телепорт на старт и ожидание 3 секунды перед новым Solo
        teleportToRaceStart()
        if not race1Running then break end

        task.wait(3)
        if not race1Running then break end

        startSoloRace()
        -- дальше цикл while повторится: снова 4 сек ожидания, машина, движение
    end

    race1Running = false
end

--------------------------------------------------
-- Кнопки
--------------------------------------------------

local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(1, -20, 0, 30)
autofarmBtn.Position = UDim2.new(0, 10, 0, 140)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
autofarmBtn.BorderSizePixel = 0
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.Text = "Start Autofarm"
autofarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autofarmBtn.TextSize = 14
autofarmBtn.Parent = mainFrame

local race1Btn = Instance.new("TextButton")
race1Btn.Size = UDim2.new(1, -20, 0, 30)
race1Btn.Position = UDim2.new(0, 10, 0, 175)
race1Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
race1Btn.BorderSizePixel = 0
race1Btn.Font = Enum.Font.GothamBold
race1Btn.Text = "Start Auto City Highway Race 🏁"
race1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
race1Btn.TextSize = 14
race1Btn.Parent = mainFrame

autofarmBtn.MouseButton1Click:Connect(function()
    if race1Running then return end
    if not autofarmRunning then
        autofarmRunning = true
        autofarmBtn.Text = "Stop Autofarm"
        task.spawn(function()
            runFarmRoute()
            autofarmRunning = false
            autofarmBtn.Text = "Start Autofarm"
        end)
    else
        autofarmRunning = false
    end
end)

race1Btn.MouseButton1Click:Connect(function()
    if autofarmRunning then return end
    if not race1Running then
        race1Running = true
        race1Btn.Text = "Stop Auto City Highway Race 🏁"
        task.spawn(function()
            runCityHighwayRoute()
            race1Btn.Text = "Start Auto City Highway Race 🏁"
        end)
    else
        race1Running = false
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
