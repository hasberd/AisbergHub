-- Midnight Chasers GUI:
-- Autofarm + Auto City Highway Race 🏁 + Anti AFK + Auto Playtime Rewards
-- AisbergHub

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

print("Welcome to AisbergHub. Thanks for using.")

--------------------------------------------------
-- Auto Playtime Rewards
--------------------------------------------------

local okRewards, errRewards = pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules")
    local Shared  = Modules:WaitForChild("Shared")
    local DB      = Modules:WaitForChild("DB")

    local Data      = require(Shared:WaitForChild("Data"))
    local RewardsDB = require(DB:WaitForChild("RewardsDB"))
    local Network   = require(Modules.Modules:WaitForChild("Network"))

    local dataObj = Data.WaitForData(LocalPlayer)
    if not dataObj then
        warn("[AutoPlaytime] WaitForData returned nil")
        return
    end

    warn("[AutoPlaytime] Auto playtime rewards started")

    task.spawn(function()
        while task.wait(2) do
            local okLoop, errLoop = pcall(function()
                local playData = dataObj.Data.PlaytimeRewards
                if not playData or not playData.Claimed then
                    return
                end

                local now = Workspace:GetServerTimeNow()
                for tierName, cfg in pairs(RewardsDB.PlaytimeRewards) do
                    if not playData.Claimed[tierName] then
                        local elapsed = now - playData.StartTime + playData.Playtime
                        if elapsed >= cfg.Time then
                            warn("[AutoPlaytime] Claiming", tierName, "elapsed =", elapsed)
                            Network.FireServer("ClaimPlaytimeReward", tierName)
                        end
                    end
                end
            end)
            if not okLoop then
                warn("[AutoPlaytime] Loop error:", errLoop)
            end
        end
    end)
end)

if not okRewards then
    warn("[AutoPlaytime] Init error:", errRewards)
end

--------------------------------------------------
-- Anti AFK
--------------------------------------------------

warn("Anti AFK launching")
LocalPlayer.Idled:Connect(function()
    warn("Anti AFK triggered, sending fake input")
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

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
    print("[AisbergHub] GUI closed")
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
    local ok, err = pcall(function()
        local folder = Workspace:FindFirstChild("NPCVehicles")
        if folder then
            folder:Destroy()
            print("[AisbergHub] NPC Vehicles removed")
        else
            print("[AisbergHub] NPC Vehicles folder not found")
        end
    end)
    if not ok then
        warn("[RemoveBtn] Error:", err)
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
    local ok, err = pcall(function()
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
    end)
    if not ok then
        warn("[hideWorkspaceObjects] Error:", err)
    end
end

local function restoreWorkspaceObjects()
    local ok, err = pcall(function()
        local backup = ReplicatedStorage:FindFirstChild("mrbackupfolder")
        if backup then
            for _, v in pairs(backup:GetChildren()) do
                v.Parent = Workspace
                task.wait()
            end
        end
    end)
    if not ok then
        warn("[restoreWorkspaceObjects] Error:", err)
    end
end

--------------------------------------------------
-- Платформы: отдельная для фарма и для гонки
--------------------------------------------------

local function ensureFarmGround()
    if not _G.farmGround then
        local p = Instance.new("Part")
        p.Name = "FarmGround"
        p.Anchored = true
        p.Size = Vector3.new(10000, 10, 10000)
        p.Transparency = 0
        p.CanCollide = true
        p.Parent = Workspace
        _G.farmGround = p
    end
end

local function ensureRaceGround()
    if not _G.raceGround then
        local p = Instance.new("Part")
        p.Name = "RaceGround"
        p.Anchored = true
        p.Size = Vector3.new(50, 10, 50)
        p.Transparency = 1
        p.CanCollide = true
        p.Parent = Workspace
        _G.raceGround = p
    end
end

--------------------------------------------------
-- Общие твины
--------------------------------------------------

local currentTween

local function tweenFarm(car, targetCFrame, speed)
    local ok, err = pcall(function()
        ensureFarmGround()

        local plr = LocalPlayer
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            warn("[tweenFarm] No HumanoidRootPart")
            return
        end

        local targetPos = targetCFrame.Position
        local dist = (hrp.Position - targetPos).Magnitude
        local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

        local cfValue = Instance.new("CFrameValue")
        cfValue.Value = car:GetPrimaryPartCFrame()

        cfValue.Changed:Connect(function()
            local pos = cfValue.Value.Position
            _G.farmGround.Position = pos - Vector3.new(0, 14, 0)
            car:PivotTo(CFrame.new(_G.farmGround.Position + Vector3.new(0, 7, 0), targetPos))
            car.PrimaryPart.AssemblyLinearVelocity = car.PrimaryPart.CFrame.LookVector * speed
        end)

        if currentTween then
            currentTween:Cancel()
        end
        currentTween = TweenService:Create(cfValue, info, {Value = targetCFrame})
        currentTween:Play()

        repeat task.wait() until currentTween.PlaybackState ~= Enum.PlaybackState.Playing

        cfValue:Destroy()
    end)
    if not ok then
        warn("[tweenFarm] Error:", err)
    end
end

local function tweenRace(car, targetCFrame, speed)
    local ok, err = pcall(function()
        ensureRaceGround()

        local plr = LocalPlayer
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            warn("[tweenRace] No HumanoidRootPart")
            return
        end

        local targetPos = targetCFrame.Position
        local dist = (hrp.Position - targetPos).Magnitude
        local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

        local cfValue = Instance.new("CFrameValue")
        cfValue.Value = car:GetPrimaryPartCFrame()

        cfValue.Changed:Connect(function()
            local pos = cfValue.Value.Position
            _G.raceGround.Position = Vector3.new(pos.X, targetPos.Y - 2, pos.Z)
            car:PivotTo(CFrame.new(Vector3.new(pos.X, targetPos.Y + 1, pos.Z), targetPos))
            car.PrimaryPart.AssemblyLinearVelocity = car.PrimaryPart.CFrame.LookVector * speed
        end)

        if currentTween then
            currentTween:Cancel()
        end
        currentTween = TweenService:Create(cfValue, info, {Value = targetCFrame})
        currentTween:Play()

        repeat task.wait() until currentTween.PlaybackState ~= Enum.PlaybackState.Playing

        cfValue:Destroy()
    end)
    if not ok then
        warn("[tweenRace] Error:", err)
    end
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
-- City Highway Race чекпоинты (сюда подставь полный список, как раньше)
--------------------------------------------------

local race1Frames = {
    CFrame.new(3322.75391, -2.98221874, 856.207031, 0.961249948, 0, -0.275678426, 0, 1, 0, 0.275678426, 0, 0.961249948),
    CFrame.new(3029.10547, -2.98221874, 660.068298, 0.90629667, 0, -0.422642082, 0, 1, 0, 0.422642082, 0, 0.90629667),
    -- ... остальные CFrame трассы ...
    CFrame.new(-16520.5859, 23.4347839, 12137.5049, 0.156420708, 0.0034087766, 0.987684667, -0.0217956547, 0.999762475, 0, -0.987450063, -0.0215274431, 0.156457841)
}

--------------------------------------------------
-- Получение машины
--------------------------------------------------

local function getCar()
    local ok, result = pcall(function()
        local plr = LocalPlayer
        local char = plr.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if not seat then return nil end

        local car = seat.Parent
        local body = car:FindFirstChild("Body")
        local weight = body and body:FindFirstChild("#Weight")
        if not weight then
            warn("[getCar] Body/#Weight not found")
            return nil
        end

        car.PrimaryPart = weight
        return car
    end)
    if not ok then
        warn("[getCar] Error:", result)
        return nil
    end
    return result
end

local autofarmRunning = false
local race1Running   = false

--------------------------------------------------
-- Автофарм
--------------------------------------------------

local function runFarmRoute()
    local ok, err = pcall(function()
        autofarmRunning = true
        print("[AisbergHub] Autofarm loop started")

        local plr = LocalPlayer
        hideWorkspaceObjects(plr)
        ensureFarmGround()
        task.wait()

        while autofarmRunning do
            local car = getCar()
            if not car then
                task.wait(0.5)
            else
                local speed = getSpeed()
                for _, cf in ipairs(farmFrames) do
                    if not autofarmRunning then break end
                    tweenFarm(car, cf, speed)
                end
            end
        end

        if currentTween then
            currentTween:Cancel()
        end
        restoreWorkspaceObjects()
        print("[AisbergHub] Autofarm loop exited")
    end)
    if not ok then
        warn("[runFarmRoute] Error:", err)
        autofarmRunning = false
    end
end

--------------------------------------------------
-- City Highway Race: Solo и старт
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
    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            warn("[teleportToRaceStart] No HumanoidRootPart")
            return
        end

        hrp.CFrame = CFrame.new(
            3260.53076, -7.51575422, 1015.698,
            -3.36170197e-05, -0.951051414, -0.309032798,
            1, -3.36170197e-05, -5.31971455e-06,
            -5.31971455e-06, -0.309032798, 0.951051414
        )
    end)
    if not ok then
        warn("[teleportToRaceStart] Error:", err)
    end
end

local function startSoloRace()
    local ok, err = pcall(function()
        local config = getRace1Config()
        if not config then
            warn("[startSoloRace] No Race1 Config")
            return
        end

        local solo = config:FindFirstChild("Solo")
        if solo and solo:IsA("BoolValue") then
            solo.Value = true
        else
            warn("[startSoloRace] Solo BoolValue not found")
        end
    end)
    if not ok then
        warn("[startSoloRace] Error:", err)
    end
end

--------------------------------------------------
-- Auto City Highway Race 🏁
--------------------------------------------------

local function runCityHighwayRoute()
    local ok, err = pcall(function()
        race1Running = true
        print("[AisbergHub] Auto City Highway Race loop started")

        while race1Running do
            teleportToRaceStart()
            if not race1Running then break end

            startSoloRace()
            if not race1Running then break end

            task.wait(4)
            if not race1Running then break end

            local car
            for i = 1, 60 do
                car = getCar()
                if car then break end
                task.wait(0.1)
                if not race1Running then break end
            end
            if not race1Running or not car then
                if not car then
                    warn("[runCityHighwayRoute] Car not found, breaking loop")
                end
                break
            end

            local speed = getSpeed()

            for idx, cf in ipairs(race1Frames) do
                if not race1Running then break end
                tweenRace(car, cf, speed)
                if idx == #race1Frames then
                    break
                end
            end

            if currentTween then
                currentTween:Cancel()
            end
            if not race1Running then break end

            teleportToRaceStart()
            if not race1Running then break end

            task.wait(3)
            if not race1Running then break end

            startSoloRace()
        end

        if _G.raceGround then
            _G.raceGround:Destroy()
            _G.raceGround = nil
        end

        race1Running = false
        print("[AisbergHub] Auto City Highway Race loop exited")
    end)
    if not ok then
        warn("[runCityHighwayRoute] Error:", err)
        race1Running = false
        if _G.raceGround then
            _G.raceGround:Destroy()
            _G.raceGround = nil
        end
    end
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
        print("[AisbergHub] Autofarm started")
        task.spawn(function()
            runFarmRoute()
            autofarmRunning = false
            autofarmBtn.Text = "Start Autofarm"
            print("[AisbergHub] Autofarm stopped")
        end)
    else
        autofarmRunning = false
        if currentTween then
            currentTween:Cancel()
        end
        print("[AisbergHub] Autofarm stopped (by button)")
    end
end)

race1Btn.MouseButton1Click:Connect(function()
    if autofarmRunning then return end
    if not race1Running then
        race1Running = true
        race1Btn.Text = "Stop Auto City Highway Race 🏁"
        print("[AisbergHub] Auto City Highway Race started")
        task.spawn(function()
            runCityHighwayRoute()
            race1Btn.Text = "Start Auto City Highway Race 🏁"
            print("[AisbergHub] Auto City Highway Race stopped")
        end)
    else
        race1Running = false
        if currentTween then
            currentTween:Cancel()
        end
        if _G.raceGround then
            _G.raceGround:Destroy()
            _G.raceGround = nil
        end
        print("[AisbergHub] Auto City Highway Race stopped (by button)")
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
            print("[AisbergHub] GUI toggled, Enabled =", screenGui.Enabled)
        end
    end
end)
