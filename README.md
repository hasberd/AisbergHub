--=== AisbergHub Soft Menu (AFK + Smooth Scale + TP List) ===--

if getgenv and getgenv().AisbergHubLoaded then
    return
end
if getgenv then
    getgenv().AisbergHubLoaded = true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

--================= FEATURES =================--

local currentSpeed = 16

local function getHumanoid()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function applySpeed()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = currentSpeed
    end
end

local function setSpeedFromValue(val)
    currentSpeed = math.clamp(val, 8, 100)
    applySpeed()
end

-- ESP: ты зелёный, остальные красные
local espEnabled = false

local function clearESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local existing = plr.Character:FindFirstChild("AisbergESP")
            if existing then existing:Destroy() end
        end
    end
end

local function refreshESP()
    clearESP()
    if not espEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "AisbergESP"
            if plr == lp then
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
            end
            highlight.OutlineColor = Color3.new(1,1,1)
            highlight.Parent = plr.Character
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if not espEnabled then
        clearESP()
        return
    end
    refreshESP()
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if espEnabled then
            task.wait(1)
            refreshESP()
        end
    end)
end)

local function tpToNearest()
    local hrp = getHRP()
    if not hrp then return end

    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                closest, dist = plr, d
            end
        end
    end

    if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
    end
end

local infJumpEnabled = false
local infJumpConnection

local function toggleInfJump()
    infJumpEnabled = not infJumpEnabled
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local hum = getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

-- AntiAFK: плавно крутим камеру
local antiAFKEnabled = false
local antiAFKConnection
local cam = workspace.CurrentCamera

local function toggleAntiAFK()
    antiAFKEnabled = not antiAFKEnabled
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    if antiAFKEnabled then
        local t0 = tick()
        antiAFKConnection = RunService.RenderStepped:Connect(function()
            if cam then
                local t = tick() - t0
                local angle = math.sin(t * 0.5) * 0.15 -- лёгкое покачивание
                cam.CFrame = cam.CFrame * CFrame.Angles(0, angle, 0)
            end
        end)
    end
end

--================= GUI BASE =================--

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 420, 0, 260)
frame.Position = UDim2.new(0.5, -210, 1, 10)
frame.Visible = false
frame.BackgroundTransparency = 0.25 -- полупрозрачный фон
frame.Parent = gui

local uiScale = Instance.new("UIScale", frame)
uiScale.Scale = 0.8

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.ZIndex = 0
shadow.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "AisbergHub"
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

-- Tabs (Main / Players / Info)
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0, 260, 0, 30)
tabsFrame.Position = UDim2.new(0, 10, 0, 40)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local function makeTabButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 80, 0, 24)
    b.Position = UDim2.new(0, x, 0, 3)
    b.BackgroundColor3 = Color3.fromRGB(30,30,45)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(200,200,210)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextTransparency = 1
    b.AutoButtonColor = false
    b.Parent = tabsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local mainTabBtn = makeTabButton("Main", 0)
local playersTabBtn = makeTabButton("Players", 90)
local infoTabBtn = makeTabButton("Info", 180)

--================= MAIN TAB =================--

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, -20, 1, -80)
mainPage.Position = UDim2.new(0, 10, 0, 70)
mainPage.BackgroundTransparency = 1
mainPage.Parent = frame

-- Speed slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 170, 0, 20)
speedLabel.Position = UDim2.new(0, 200, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(230,230,240)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextTransparency = 1
speedLabel.Parent = mainPage

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 170, 0, 6)
sliderBar.Position = UDim2.new(0, 200, 0, 25)
sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = mainPage
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.Position = UDim2.new(0, 0, 0, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 10, 0, 16)
sliderKnob.Position = UDim2.new(0, 0, 0, -5)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBar
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local dragging = false

local function updateSliderFromX(x)
    local absPos = sliderBar.AbsolutePosition.X
    local absSize = sliderBar.AbsoluteSize.X
    local rel = math.clamp((x - absPos) / absSize, 0, 1)
    local speed = 8 + (100 - 8) * rel
    speed = math.floor(speed + 0.5)
    setSpeedFromValue(speed)
    speedLabel.Text = "Speed: " .. tostring(speed)
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    sliderKnob.Position = UDim2.new(rel, -5, 0, -5)
end

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        updateSliderFromX(input.Position.X)
    end
end)

sliderBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSliderFromX(input.Position.X)
    end
end)

-- ESP / TP / InfJump
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 170, 0, 30)
espBtn.Position = UDim2.new(0, 10, 0, 0)
espBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
espBtn.BorderSizePixel = 0
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.fromRGB(230,230,240)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 16
espBtn.TextTransparency = 1
espBtn.AutoButtonColor = false
espBtn.Parent = mainPage
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 170, 0, 30)
tpBtn.Position = UDim2.new(0, 10, 0, 40)
tpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tpBtn.BorderSizePixel = 0
tpBtn.Text = "TP к ближайшему"
tpBtn.TextColor3 = Color3.fromRGB(230,230,240)
tpBtn.Font = Enum.Font.Gotham
tpBtn.TextSize = 16
tpBtn.TextTransparency = 1
tpBtn.AutoButtonColor = false
tpBtn.Parent = mainPage
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

local infBtn = Instance.new("TextButton")
infBtn.Size = UDim2.new(0, 170, 0, 30)
infBtn.Position = UDim2.new(0, 10, 0, 80)
infBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
infBtn.BorderSizePixel = 0
infBtn.Text = "Infinite Jump: OFF"
infBtn.TextColor3 = Color3.fromRGB(230,230,240)
infBtn.Font = Enum.Font.Gotham
infBtn.TextSize = 16
infBtn.TextTransparency = 1
infBtn.AutoButtonColor = false
infBtn.Parent = mainPage
Instance.new("UICorner", infBtn).CornerRadius = UDim.new(0, 8)

-- AntiAFK блок
local afkFrame = Instance.new("Frame")
afkFrame.Size = UDim2.new(0, 170, 0, 60)
afkFrame.Position = UDim2.new(0, 10, 0, 120)
afkFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
afkFrame.BorderSizePixel = 0
afkFrame.BackgroundTransparency = 0.1
afkFrame.Parent = mainPage
Instance.new("UICorner", afkFrame).CornerRadius = UDim.new(0, 8)

local afkTitle = Instance.new("TextLabel")
afkTitle.Size = UDim2.new(1, 0, 0, 20)
afkTitle.Position = UDim2.new(0, 0, 0, 5)
afkTitle.BackgroundTransparency = 1
afkTitle.Text = "Aisberg AntiAFK"
afkTitle.TextColor3 = Color3.fromRGB(230,230,240)
afkTitle.Font = Enum.Font.GothamBold
afkTitle.TextSize = 14
afkTitle.TextTransparency = 1
afkTitle.Parent = afkFrame

local afkStatus = Instance.new("TextLabel")
afkStatus.Size = UDim2.new(1, -10, 0, 16)
afkStatus.Position = UDim2.new(0, 5, 0, 26)
afkStatus.BackgroundTransparency = 1
afkStatus.Text = "Status: Inactive"
afkStatus.TextColor3 = Color3.fromRGB(200,200,210)
afkStatus.Font = Enum.Font.Gotham
afkStatus.TextSize = 13
afkStatus.TextXAlignment = Enum.TextXAlignment.Left
afkStatus.TextTransparency = 1
afkStatus.Parent = afkFrame

local afkBtn = Instance.new("TextButton")
afkBtn.Size = UDim2.new(0, 80, 0, 20)
afkBtn.Position = UDim2.new(1, -85, 1, -25)
afkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
afkBtn.BorderSizePixel = 0
afkBtn.Text = "Toggle"
afkBtn.TextColor3 = Color3.fromRGB(230,230,240)
afkBtn.Font = Enum.Font.Gotham
afkBtn.TextSize = 13
afkBtn.TextTransparency = 1
afkBtn.AutoButtonColor = false
afkBtn.Parent = afkFrame
Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0, 6)

--================= PLAYERS TAB (TP к конкретным) =================--

local playersPage = Instance.new("Frame")
playersPage.Size = UDim2.new(1, -20, 1, -80)
playersPage.Position = UDim2.new(0, 10, 0, 70)
playersPage.BackgroundTransparency = 1
playersPage.Visible = false
playersPage.Parent = frame

local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(1, 0, 0, 20)
playersLabel.Position = UDim2.new(0, 0, 0, 0)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "Players (click to TP)"
playersLabel.TextColor3 = Color3.fromRGB(230,230,240)
playersLabel.Font = Enum.Font.Gotham
playersLabel.TextSize = 14
playersLabel.TextTransparency = 1
playersLabel.Parent = playersPage

local playersScroll = Instance.new("ScrollingFrame")
playersScroll.Size = UDim2.new(1, -10, 1, -30)
playersScroll.Position = UDim2.new(0, 5, 0, 25)
playersScroll.BackgroundTransparency = 1
playersScroll.BorderSizePixel = 0
playersScroll.CanvasSize = UDim2.new(0,0,0,0)
playersScroll.ScrollBarThickness = 4
playersScroll.Parent = playersPage

local playersLayout = Instance.new("UIListLayout", playersScroll)
playersLayout.FillDirection = Enum.FillDirection.Vertical
playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersLayout.Padding = UDim.new(0, 4)

local function rebuildPlayersList()
    playersScroll:ClearAllChildren()
    playersLayout.Parent = playersScroll

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,45)
            btn.BorderSizePixel = 0
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(230,230,240)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextTransparency = 1
            btn.AutoButtonColor = false
            btn.Parent = playersScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if hrp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                end
            end)
        end
    end

    playersScroll.CanvasSize = UDim2.new(0,0,0,playersLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(rebuildPlayersList)
Players.PlayerRemoving:Connect(rebuildPlayersList)

--================= INFO TAB =================--

local infoPage = Instance.new("Frame")
infoPage.Size = UDim2.new(1, -20, 1, -80)
infoPage.Position = UDim2.new(0, 10, 0, 70)
infoPage.BackgroundTransparency = 1
infoPage.Visible = false
infoPage.Parent = frame

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, 0, 0, 20)
infoTitle.Position = UDim2.new(0, 0, 0, 0)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "Info"
infoTitle.TextColor3 = Color3.fromRGB(230,230,240)
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextSize = 14
infoTitle.TextTransparency = 1
infoTitle.Parent = infoPage

local posLabel = Instance.new("TextLabel")
posLabel.Size = UDim2.new(1, 0, 0, 20)
posLabel.Position = UDim2.new(0, 0, 0, 30)
posLabel.BackgroundTransparency = 1
posLabel.TextColor3 = Color3.fromRGB(200,200,210)
posLabel.Font = Enum.Font.Code
posLabel.TextSize = 14
posLabel.TextXAlignment = Enum.TextXAlignment.Left
posLabel.TextTransparency = 1
posLabel.Parent = infoPage

local speedInfoLabel = Instance.new("TextLabel")
speedInfoLabel.Size = UDim2.new(1, 0, 0, 20)
speedInfoLabel.Position = UDim2.new(0, 0, 0, 55)
speedInfoLabel.BackgroundTransparency = 1
speedInfoLabel.TextColor3 = Color3.fromRGB(200,200,210)
speedInfoLabel.Font = Enum.Font.Code
speedInfoLabel.TextSize = 14
speedInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
speedInfoLabel.TextTransparency = 1
speedInfoLabel.Parent = infoPage

local jpLabel = Instance.new("TextLabel")
jpLabel.Size = UDim2.new(1, 0, 0, 20)
jpLabel.Position = UDim2.new(0, 0, 0, 80)
jpLabel.BackgroundTransparency = 1
jpLabel.TextColor3 = Color3.fromRGB(200,200,210)
jpLabel.Font = Enum.Font.Code
jpLabel.TextSize = 14
jpLabel.TextXAlignment = Enum.TextXAlignment.Left
jpLabel.TextTransparency = 1
jpLabel.Parent = infoPage

task.spawn(function()
    while task.wait(0.25) do
        if not gui.Enabled then break end
        local hrp = getHRP()
        local hum = getHumanoid()
        if hrp then
            local p = hrp.Position
            posLabel.Text = string.format("Pos:  X=%.1f  Y=%.1f  Z=%.1f", p.X, p.Y, p.Z)
        else
            posLabel.Text = "Pos: N/A"
        end
        if hum then
            speedInfoLabel.Text = "WalkSpeed: " .. tostring(hum.WalkSpeed)
            jpLabel.Text = "JumpPower: " .. tostring(hum.JumpPower or 0)
        else
            speedInfoLabel.Text = "WalkSpeed: N/A"
            jpLabel.Text = "JumpPower: N/A"
        end
    end
end)

--================= TABS LOGIC =================--

local function setActiveTab(name)
    mainPage.Visible = (name == "Main")
    playersPage.Visible = (name == "Players")
    infoPage.Visible = (name == "Info")

    mainTabBtn.BackgroundColor3 = name == "Main" and Color3.fromRGB(40,40,60) or Color3.fromRGB(30,30,45)
    playersTabBtn.BackgroundColor3 = name == "Players" and Color3.fromRGB(40,40,60) or Color3.fromRGB(30,30,45)
    infoTabBtn.BackgroundColor3 = name == "Info" and Color3.fromRGB(40,40,60) or Color3.fromRGB(30,30,45)
end

mainTabBtn.MouseButton1Click:Connect(function()
    setActiveTab("Main")
end)

playersTabBtn.MouseButton1Click:Connect(function()
    setActiveTab("Players")
    rebuildPlayersList()
end)

infoTabBtn.MouseButton1Click:Connect(function()
    setActiveTab("Info")
end)

setActiveTab("Main")

--================= ANIMATION (fade + scale) =================--

local isVisible = false
local tweenTime = 0.35
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local function fadeIn()
    frame.Visible = true
    frame.BackgroundTransparency = 1
    uiScale.Scale = 0.8
    frame.Position = UDim2.new(0.5, -210, 0.5, -130)

    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        BackgroundTransparency = 0.25,
    }):Play()
    TweenService:Create(uiScale, TweenInfo.new(tweenTime, easing, direction), {
        Scale = 1
    }):Play()

    local elems = {
        title, closeBtn,
        mainTabBtn, playersTabBtn, infoTabBtn,
        speedLabel, espBtn, tpBtn, infBtn,
        afkTitle, afkStatus, afkBtn,
        playersLabel, infoTitle, posLabel, speedInfoLabel, jpLabel
    }

    for _, ui in ipairs(elems) do
        TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    end
end

local function fadeOut(callback)
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(uiScale, TweenInfo.new(tweenTime, easing, direction), {
        Scale = 0.8
    }):Play()

    local elems = {
        title, closeBtn,
        mainTabBtn, playersTabBtn, infoTabBtn,
        speedLabel, espBtn, tpBtn, infBtn,
        afkTitle, afkStatus, afkBtn,
        playersLabel, infoTitle, posLabel, speedInfoLabel, jpLabel
    }

    for _, ui in ipairs(elems) do
        TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    end

    task.delay(tweenTime, function()
        frame.Visible = false
        if callback then callback() end
    end)
end

--================= BUTTON CALLBACKS =================--

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

espBtn.MouseButton1Click:Connect(function()
    toggleESP()
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(35,35,50)
end)

tpBtn.MouseButton1Click:Connect(function()
    tpToNearest()
end)

infBtn.MouseButton1Click:Connect(function()
    toggleInfJump()
    infBtn.Text = infJumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
    infBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(80, 40, 80) or Color3.fromRGB(35, 35, 50)
end)

afkBtn.MouseButton1Click:Connect(function()
    toggleAntiAFK()
    if antiAFKEnabled then
        afkStatus.Text = "Status: Active"
        afkStatus.TextColor3 = Color3.fromRGB(120,255,120)
    else
        afkStatus.Text = "Status: Inactive"
        afkStatus.TextColor3 = Color3.fromRGB(200,200,210)
    end
end)

--================= KEYBIND (K) =================--

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

print("AisbergHub загружен. Нажми K для меню.")
