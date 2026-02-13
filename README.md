--=== AisbergHub Soft Menu (Full) ===--

if getgenv and getgenv().AisbergHubLoaded then
    return
end
if getgenv then
    getgenv().AisbergHubLoaded = true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer

--================= FEATURES =================--

local currentSpeed = 16

local function applySpeed()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed = currentSpeed
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
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
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
        local UIS = UserInputService
        infJumpConnection = UIS.JumpRequest:Connect(function()
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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
frame.Size = UDim2.new(0, 380, 0, 280)
frame.Position = UDim2.new(0.5, -190, 1, 10)
frame.Visible = false
frame.BackgroundTransparency = 1
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.4
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
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

local fullBtn = Instance.new("TextButton")
fullBtn.Size = UDim2.new(0, 130, 0, 30)
fullBtn.Position = UDim2.new(0, 10, 0, 40)
fullBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
fullBtn.BorderSizePixel = 0
fullBtn.Text = "Во весь экран"
fullBtn.TextColor3 = Color3.fromRGB(230,230,240)
fullBtn.Font = Enum.Font.Gotham
fullBtn.TextSize = 16
fullBtn.TextTransparency = 1
fullBtn.AutoButtonColor = false
fullBtn.Parent = frame
Instance.new("UICorner", fullBtn).CornerRadius = UDim.new(0, 8)

local normalBtn = Instance.new("TextButton")
normalBtn.Size = UDim2.new(0, 160, 0, 30)
normalBtn.Position = UDim2.new(0, 10, 0, 80)
normalBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
normalBtn.BorderSizePixel = 0
normalBtn.Text = "Обычный размер"
normalBtn.TextColor3 = Color3.fromRGB(230,230,240)
normalBtn.Font = Enum.Font.Gotham
normalBtn.TextSize = 16
normalBtn.TextTransparency = 1
normalBtn.AutoButtonColor = false
normalBtn.Parent = frame
Instance.new("UICorner", normalBtn).CornerRadius = UDim.new(0, 8)

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 130, 0, 30)
hideBtn.Position = UDim2.new(0, 10, 0, 120)
hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
hideBtn.BorderSizePixel = 0
hideBtn.Text = "Скрыть меню"
hideBtn.TextColor3 = Color3.fromRGB(230,230,240)
hideBtn.Font = Enum.Font.Gotham
hideBtn.TextSize = 16
hideBtn.TextTransparency = 1
hideBtn.AutoButtonColor = false
hideBtn.Parent = frame
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

--================= SPEED SLIDER =================--

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 170, 0, 20)
speedLabel.Position = UDim2.new(0, 200, 0, 30)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(230,230,240)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextTransparency = 1
speedLabel.Parent = frame

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 170, 0, 6)
sliderBar.Position = UDim2.new(0, 200, 0, 55)
sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
sliderBar.BorderSizePixel = 0
sliderBar.BackgroundTransparency = 0
sliderBar.Parent = frame
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
    currentSpeed = speed
    applySpeed()
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

--================= ESP / TP / INF JUMP BUTTONS =================--

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 170, 0, 30)
espBtn.Position = UDim2.new(0, 200, 0, 80)
espBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
espBtn.BorderSizePixel = 0
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.fromRGB(230,230,240)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 16
espBtn.TextTransparency = 1
espBtn.AutoButtonColor = false
espBtn.Parent = frame
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 170, 0, 30)
tpBtn.Position = UDim2.new(0, 200, 0, 120)
tpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tpBtn.BorderSizePixel = 0
tpBtn.Text = "TP к ближайшему"
tpBtn.TextColor3 = Color3.fromRGB(230,230,240)
tpBtn.Font = Enum.Font.Gotham
tpBtn.TextSize = 16
tpBtn.TextTransparency = 1
tpBtn.AutoButtonColor = false
tpBtn.Parent = frame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

local infBtn = Instance.new("TextButton")
infBtn.Size = UDim2.new(0, 170, 0, 30)
infBtn.Position = UDim2.new(0, 200, 0, 160)
infBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
infBtn.BorderSizePixel = 0
infBtn.Text = "Infinite Jump: OFF"
infBtn.TextColor3 = Color3.fromRGB(230,230,240)
infBtn.Font = Enum.Font.Gotham
infBtn.TextSize = 16
infBtn.TextTransparency = 1
infBtn.AutoButtonColor = false
infBtn.Parent = frame
Instance.new("UICorner", infBtn).CornerRadius = UDim.new(0, 8)

--================= Infinite Yield + Dex кнопки =================--

local iyBtn = Instance.new("TextButton")
iyBtn.Size = UDim2.new(0, 170, 0, 30)
iyBtn.Position = UDim2.new(0, 200, 0, 200)
iyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
iyBtn.BorderSizePixel = 0
iyBtn.Text = "Open Infinite Yield"
iyBtn.TextColor3 = Color3.fromRGB(230,230,240)
iyBtn.Font = Enum.Font.Gotham
iyBtn.TextSize = 16
iyBtn.TextTransparency = 1
iyBtn.AutoButtonColor = false
iyBtn.Parent = frame
Instance.new("UICorner", iyBtn).CornerRadius = UDim.new(0, 8)

local dexBtn = Instance.new("TextButton")
dexBtn.Size = UDim2.new(0, 170, 0, 30)
dexBtn.Position = UDim2.new(0, 200, 0, 240)
dexBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
dexBtn.BorderSizePixel = 0
dexBtn.Text = "Open Dex Explorer"
dexBtn.TextColor3 = Color3.fromRGB(230,230,240)
dexBtn.Font = Enum.Font.Gotham
dexBtn.TextSize = 16
dexBtn.TextTransparency = 1
dexBtn.AutoButtonColor = false
dexBtn.Parent = frame
Instance.new("UICorner", dexBtn).CornerRadius = UDim.new(0, 8)

--================= ReplicatedStorage Explorer =================--

local rsFrame = Instance.new("Frame")
rsFrame.Size = UDim2.new(0, 260, 0, 200)
rsFrame.Position = UDim2.new(0, 10, 0, 140)
rsFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
rsFrame.BorderSizePixel = 0
rsFrame.Visible = false
rsFrame.Parent = frame
Instance.new("UICorner", rsFrame).CornerRadius = UDim.new(0, 8)

local rsTitle = Instance.new("TextLabel")
rsTitle.Size = UDim2.new(1, 0, 0, 20)
rsTitle.Position = UDim2.new(0, 0, 0, 0)
rsTitle.BackgroundTransparency = 1
rsTitle.Text = "ReplicatedStorage"
rsTitle.TextColor3 = Color3.fromRGB(230,230,240)
rsTitle.Font = Enum.Font.GothamBold
rsTitle.TextSize = 14
rsTitle.Parent = rsFrame

local rsScroll = Instance.new("ScrollingFrame")
rsScroll.Size = UDim2.new(1, -10, 1, -30)
rsScroll.Position = UDim2.new(0, 5, 0, 25)
rsScroll.BackgroundTransparency = 1
rsScroll.BorderSizePixel = 0
rsScroll.CanvasSize = UDim2.new(0,0,0,0)
rsScroll.ScrollBarThickness = 4
rsScroll.Parent = rsFrame

local rsLayout = Instance.new("UIListLayout", rsScroll)
rsLayout.FillDirection = Enum.FillDirection.Vertical
rsLayout.SortOrder = Enum.SortOrder.LayoutOrder
rsLayout.Padding = UDim.new(0, 2)

local function makeEntry(obj, indent)
    indent = indent or 0

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 18)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,35)
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(220,220,230)
    btn.Parent = rsScroll

    local prefix = string.rep("  ", indent)
    btn.Text = prefix .. obj.Name .. " [" .. obj.ClassName .. "]"

    local expanded = false
    local childrenButtons = {}

    local function toggle()
        expanded = not expanded
        if expanded then
            for _, child in ipairs(obj:GetChildren()) do
                local childBtn = makeEntry(child, indent + 1)
                table.insert(childrenButtons, childBtn)
            end
        else
            for _, b in ipairs(childrenButtons) do
                b:Destroy()
            end
            childrenButtons = {}
        end
        rsScroll.CanvasSize = UDim2.new(0,0,0,rsLayout.AbsoluteContentSize.Y)
    end

    btn.MouseButton1Click:Connect(toggle)

    return btn
end

local function rebuildRS()
    rsScroll:ClearAllChildren()
    rsLayout.Parent = rsScroll
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        makeEntry(obj, 0)
    end
    rsScroll.CanvasSize = UDim2.new(0,0,0,rsLayout.AbsoluteContentSize.Y)
end

local rsVisible = false

local rsBtn = Instance.new("TextButton")
rsBtn.Size = UDim2.new(0, 170, 0, 30)
rsBtn.Position = UDim2.new(0, 10, 0, 160)
rsBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
rsBtn.BorderSizePixel = 0
rsBtn.Text = "ReplicatedStorage Explorer"
rsBtn.TextColor3 = Color3.fromRGB(230,230,240)
rsBtn.Font = Enum.Font.Gotham
rsBtn.TextSize = 14
rsBtn.TextTransparency = 1
rsBtn.AutoButtonColor = false
rsBtn.Parent = frame
Instance.new("UICorner", rsBtn).CornerRadius = UDim.new(0, 8)

rsBtn.MouseButton1Click:Connect(function()
    rsVisible = not rsVisible
    rsFrame.Visible = rsVisible
    if rsVisible then
        rebuildRS()
    end
end)

--================= ANIMATION =================--

local isVisible = false
local isFullScreen = false
local tweenTime = 0.35
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local function fadeIn()
    frame.Visible = true
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Position = UDim2.new(0.5, -190, 0.5, -140),
        BackgroundTransparency = 0
    }):Play()

    local elems = {
        title, fullBtn, normalBtn, hideBtn, closeBtn,
        speedLabel, espBtn, tpBtn, infBtn,
        iyBtn, dexBtn, rsBtn
    }

    for _, ui in ipairs(elems) do
        TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    end
end

local function fadeOut(callback)
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Position = UDim2.new(0.5, -190, 1, 10),
        BackgroundTransparency = 1
    }):Play()

    local elems = {
        title, fullBtn, normalBtn, hideBtn, closeBtn,
        speedLabel, espBtn, tpBtn, infBtn,
        iyBtn, dexBtn, rsBtn
    }

    for _, ui in ipairs(elems) do
        TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
    end

    task.delay(tweenTime, function()
        frame.Visible = false
        if callback then callback() end
    end)
end

local function setNormal()
    isFullScreen = false
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(0, 380, 0, 280),
        Position = UDim2.new(0.5, -190, 0.5, -140)
    }):Play()
end

local function setFull()
    isFullScreen = true
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
end

--================= BUTTON CALLBACKS =================--

fullBtn.MouseButton1Click:Connect(function()
    setFull()
end)

normalBtn.MouseButton1Click:Connect(function()
    setNormal()
end)

hideBtn.MouseButton1Click:Connect(function()
    if isVisible then
        isVisible = false
        fadeOut()
    end
end)

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

iyBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

dexBtn.MouseButton1Click:Connect(function()
    if not getgenv or not getgenv().IY_LOADED then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        task.wait(2)
    end
    if getgenv and getgenv().IY and getgenv().IY.ExecuteCommand then
        getgenv().IY.ExecuteCommand("dex")
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
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
