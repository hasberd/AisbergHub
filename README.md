-- Midnight Chasers Autofarm GUI (по точкам маршрута)

local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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
    end
end)

--------------------------------------------------
-- Ввод скорости
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
speedBox.PlaceholderText = "рекомендую 200–350"
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
-- Логика движения машины
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
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
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

    repeat
        task.wait()
    until currentTween.PlaybackState ~= Enum.PlaybackState.Playing

    cfValue:Destroy()
end

-- точки маршрута из найденного скрипта
local frames = {
    CFrame.new(105.419128, -26.0098934, 7965.37988, -3.36170197e-05, 0.951051414, -0.309032798, -1, -3.36170197e-05, 5.31971455e-06, -5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(2751.86499, -26.0098934, 3694.63354, 3.34978104e-05, 0.951051414, -0.309032798, -1, 3.34978104e-05, -5.31971455e-06, 5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(-8821.48438, -26.0098934, 2042.49939, -3.36170197e-05, 0.951051414, -0.309032798, -1, -3.36170197e-05, 5.31971455e-06, -5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(-6408.62109, -26.0098934, -727.765198, 3.34978104e-05, 0.951051414, -0.309032798, -1, 3.34978104e-05, -5.31971455e-06, 5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(-6099.79639, -26.00989345, -1027.94556, -3.36170197e-05, 0.951051414, -0.309032798, -1, -3.36170197e-05, 5.31971455e-06, -5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(-6066.70068, -26.0098934, 493.255524, 3.34978104e-05, 0.951051414, -0.309032798, -1, 3.34978104e-05, -5.31971455e-06, 5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(132.786133, -26.0098934, 15.2286377, 3.34978104e-05, 0.951051414, -0.309032798, -1, 3.34978104e-05, -5.31971455e-06, 5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(-7692.85449, -26.0098934, -4668.61963, -3.36170197e-05, 0.951051414, -0.309032798, -1, -3.36170197e-05, 5.31971455e-06, -5.31971455e-06, 0.309032798, 0.951051414),
    CFrame.new(4887.24609, -26.0098934, 1222.96826, -3.36170197e-05, 0.951051414, -0.309032798, -1, -3.36170197e-05, 5.31971455e-06, -5.31971455e-06, 0.309032798, 0.951051414)
}

local autofarmRunning = false

local function runAutofarm()
    autofarmRunning = true
    ensureGroundPart()

    while autofarmRunning do
        local plr = LocalPlayer
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart

        if not seat then
            task.wait(0.2)
        else
            local car = seat.Parent
            local weight = car:FindFirstChild("Body") and car.Body:FindFirstChild("#Weight")
            if not weight then
                warn("Не найден Body/#Weight в машине")
                return
            end

            car.PrimaryPart = weight

            local speed = getSpeed()

            for _, cf in ipairs(frames) do
                if not autofarmRunning then break end
                tweenToPosition(car, cf + Vector3.new(0, 5, 0), speed)
            end
        end
    end

    if currentTween then
        currentTween:Cancel()
    end
end

--------------------------------------------------
-- Кнопка Autofarm
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

autofarmBtn.MouseButton1Click:Connect(function()
    if not autofarmRunning then
        autofarmBtn.Text = "Stop Autofarm"
        task.spawn(runAutofarm)
    else
        autofarmRunning = false
        autofarmBtn.Text = "Start Autofarm"
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
