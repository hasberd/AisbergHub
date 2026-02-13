--=== AisbergHub Soft Menu (Xeno-ready) ===--

if getgenv and getgenv().AisbergHubLoaded then
    return
end
if getgenv then
    getgenv().AisbergHubLoaded = true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

--================= FEATURES =================--

local function setSpeed(enabled)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed = enabled and 50 or 16
end

local function toggleESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local existing = plr.Character:FindFirstChild("AisbergESP")
            if existing then
                existing:Destroy()
            else
                local highlight = Instance.new("Highlight")
                highlight.Name = "AisbergESP"
                highlight.FillColor = Color3.new(0,1,0)
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.Parent = plr.Character
            end
        end
    end
end

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

--================= GUI =================--

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 360, 0, 220)
frame.Position = UDim2.new(0.5, -180, 1, 10) -- start off-screen bottom
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

-- Feature buttons
local speedOn = false
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, 170, 0, 30)
speedBtn.Position = UDim2.new(0, 180, 0, 40)
speedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
speedBtn.BorderSizePixel = 0
speedBtn.Text = "Speed: OFF"
speedBtn.TextColor3 = Color3.fromRGB(230,230,240)
speedBtn.Font = Enum.Font.Gotham
speedBtn.TextSize = 16
speedBtn.TextTransparency = 1
speedBtn.AutoButtonColor = false
speedBtn.Parent = frame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 8)

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 170, 0, 30)
espBtn.Position = UDim2.new(0, 180, 0, 80)
espBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
espBtn.BorderSizePixel = 0
espBtn.Text = "ESP TOGGLE"
espBtn.TextColor3 = Color3.fromRGB(230,230,240)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 16
espBtn.TextTransparency = 1
espBtn.AutoButtonColor = false
espBtn.Parent = frame
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 170, 0, 30)
tpBtn.Position = UDim2.new(0, 180, 0, 120)
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
infBtn.Position = UDim2.new(0, 180, 0, 160)
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

--================= ANIMATION =================--

local isVisible = false
local isFullScreen = false
local tweenTime = 0.35
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local function fadeIn()
    frame.Visible = true
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Position = UDim2.new(0.5, -180, 0.5, -110),
        BackgroundTransparency = 0
    }):Play()

    local elems = {title, fullBtn, normalBtn, hideBtn, closeBtn, speedBtn, espBtn, tpBtn, infBtn}
    for _, ui in ipairs(elems) do
        TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
    end
end

local function fadeOut(callback)
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Position = UDim2.new(0.5, -180, 1, 10),
        BackgroundTransparency = 1
    }):Play()

    local elems = {title, fullBtn, normalBtn, hideBtn, closeBtn, speedBtn, espBtn, tpBtn, infBtn}
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
        Size = UDim2.new(0, 360, 0, 220),
        Position = UDim2.new(0.5, -180, 0.5, -110)
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

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    setSpeed(speedOn)
    speedBtn.Text = speedOn and "Speed: ON" or "Speed: OFF"
    speedBtn.BackgroundColor3 = speedOn and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(35, 35, 50)
end)

espBtn.MouseButton1Click:Connect(function()
    toggleESP()
end)

tpBtn.MouseButton1Click:Connect(function()
    tpToNearest()
end)

infBtn.MouseButton1Click:Connect(function()
    toggleInfJump()
    infBtn.Text = infJumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
    infBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(80, 40, 80) or Color3.fromRGB(35, 35, 50)
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

print("AisbergHub загружен. Нажми K, чтобы открыть меню.")
