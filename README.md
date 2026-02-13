--=== AisbergHub UI (Main/Game/Visual/AntiAFK/Settings + Visual ESP) ===--

if getgenv and getgenv().AisbergHubLoaded then
    return
end
if getgenv then
    getgenv().AisbergHubLoaded = true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer

--================= ESP STATE =================--

local playerESPEnabled = false
local blockESPEnabled = false

local function clearPlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("Aisberg_PlayerESP")
            if h then h:Destroy() end
        end
    end
end

local function applyPlayerESP()
    clearPlayerESP()
    if not playerESPEnabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "Aisberg_PlayerESP"

            if plr == lp then
                highlight.FillColor = Color3.fromRGB(0, 255, 0)          -- ты
            elseif lp:IsFriendsWith(plr.UserId) then                    -- друзья
                highlight.FillColor = Color3.fromRGB(255, 255, 255)
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0)          -- остальные
            end

            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = plr.Character
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if playerESPEnabled then
            task.wait(1)
            applyPlayerESP()
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        local h = plr.Character:FindFirstChild("Aisberg_PlayerESP")
        if h then h:Destroy() end
    end
end)

local function togglePlayerESP()
    playerESPEnabled = not playerESPEnabled
    if playerESPEnabled then
        applyPlayerESP()
    else
        clearPlayerESP()
    end
end

-- Block Essence ESP
local blockESPObjects = {}

local function clearBlockESP()
    for obj, highlight in pairs(blockESPObjects) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    blockESPObjects = {}
end

local function scanBlockEssence()
    clearBlockESP()
    if not blockESPEnabled then return end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == "BlockEssence" then
            local h = Instance.new("Highlight")
            h.Name = "Aisberg_BlockESS"
            h.FillColor = Color3.fromRGB(255, 255, 255)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.Parent = descendant
            blockESPObjects[descendant] = h
        end
    end
end

local function toggleBlockESP()
    blockESPEnabled = not blockESPEnabled
    if blockESPEnabled then
        scanBlockEssence()
    else
        clearBlockESP()
    end
end

--================= GUI BASE =================--

local gui = Instance.new("ScreenGui")
gui.Name = "AisbergHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 420, 0, 260)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Visible = false
frame.BackgroundTransparency = 0.4
frame.Parent = gui

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
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.ZIndex = 0
shadow.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 26)
title.Position = UDim2.new(0, 14, 0, 6)
title.BackgroundTransparency = 1
title.Text = "AisbergHub"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.new(0, 14, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Utility Panel"
subtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextTransparency = 1
subtitle.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(235, 235, 245)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextTransparency = 1
closeBtn.AutoButtonColor = false
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

--================= ВКЛАДКИ СПРАВА =================--

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0, 110, 1, -60)
tabsFrame.Position = UDim2.new(1, -120, 0, 50)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(210,210,220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextTransparency = 1
    btn.AutoButtonColor = false
    btn.Parent = tabsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local mainTabBtn     = createTabButton("Main",     1)
local gameTabBtn     = createTabButton("Game",     2)
local visualTabBtn   = createTabButton("Visual",   3)
local antiTabBtn     = createTabButton("AntiAFK",  4)
local settingsTabBtn = createTabButton("Settings", 5)

--================= ОБЛАСТЬ КОНТЕНТА СЛЕВА =================--

local pagesFrame = Instance.new("Frame")
pagesFrame.Size = UDim2.new(1, -140, 1, -80)
pagesFrame.Position = UDim2.new(0, 14, 0, 70)
pagesFrame.BackgroundTransparency = 1
pagesFrame.Parent = frame

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Parent = pagesFrame

local mainPlaceholder = Instance.new("TextLabel")
mainPlaceholder.Size = UDim2.new(1, 0, 0, 20)
mainPlaceholder.Position = UDim2.new(0, 0, 0, 0)
mainPlaceholder.BackgroundTransparency = 1
mainPlaceholder.Text = "Main tab: общие функции (speed, info и т.п.)."
mainPlaceholder.TextColor3 = Color3.fromRGB(180,180,195)
mainPlaceholder.Font = Enum.Font.Gotham
mainPlaceholder.TextSize = 14
mainPlaceholder.TextTransparency = 1
mainPlaceholder.TextXAlignment = Enum.TextXAlignment.Left
mainPlaceholder.Parent = mainPage

local gamePage = Instance.new("Frame")
gamePage.Size = UDim2.new(1, 0, 1, 0)
gamePage.BackgroundTransparency = 1
gamePage.Visible = false
gamePage.Parent = pagesFrame

local gamePlaceholder = mainPlaceholder:Clone()
gamePlaceholder.Text = "Game tab: Tap Simulator (авто‑тап, авто‑яйца, бусты)."
gamePlaceholder.Parent = gamePage

local visualPage = Instance.new("Frame")
visualPage.Size = UDim2.new(1, 0, 1, 0)
visualPage.BackgroundTransparency = 1
visualPage.Visible = false
visualPage.Parent = pagesFrame

local visualPlaceholder = mainPlaceholder:Clone()
visualPlaceholder.Text = "Visual tab: ESP, визуальные эффекты."
visualPlaceholder.Parent = visualPage

local antiPage = Instance.new("Frame")
antiPage.Size = UDim2.new(1, 0, 1, 0)
antiPage.BackgroundTransparency = 1
antiPage.Visible = false
antiPage.Parent = pagesFrame

local settingsPage = Instance.new("Frame")
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false
settingsPage.Parent = pagesFrame

local settingsPlaceholder = mainPlaceholder:Clone()
settingsPlaceholder.Text = "Settings: позже сюда можно вынести цвета, keybind'ы и т.п."
settingsPlaceholder.Parent = settingsPage

--================= Visual кнопки =================--

local playerESPBtn = Instance.new("TextButton")
playerESPBtn.Size = UDim2.new(0, 160, 0, 28)
playerESPBtn.Position = UDim2.new(0, 0, 0, 30)
playerESPBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
playerESPBtn.BorderSizePixel = 0
playerESPBtn.Text = "Player ESP: OFF"
playerESPBtn.TextColor3 = Color3.fromRGB(230,230,240)
playerESPBtn.Font = Enum.Font.Gotham
playerESPBtn.TextSize = 14
playerESPBtn.TextTransparency = 1
playerESPBtn.AutoButtonColor = false
playerESPBtn.Parent = visualPage
Instance.new("UICorner", playerESPBtn).CornerRadius = UDim.new(0, 6)

local blockESPBtn = Instance.new("TextButton")
blockESPBtn.Size = UDim2.new(0, 200, 0, 28)
blockESPBtn.Position = UDim2.new(0, 0, 0, 70)
blockESPBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
blockESPBtn.BorderSizePixel = 0
blockESPBtn.Text = "Block Essence ESP: OFF"
blockESPBtn.TextColor3 = Color3.fromRGB(230,230,240)
blockESPBtn.Font = Enum.Font.Gotham
blockESPBtn.TextSize = 14
blockESPBtn.TextTransparency = 1
blockESPBtn.AutoButtonColor = false
blockESPBtn.Parent = visualPage
Instance.new("UICorner", blockESPBtn).CornerRadius = UDim.new(0, 6)

local refreshBlockBtn = Instance.new("TextButton")
refreshBlockBtn.Size = UDim2.new(0, 160, 0, 28)
refreshBlockBtn.Position = UDim2.new(0, 0, 0, 110)
refreshBlockBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
refreshBlockBtn.BorderSizePixel = 0
refreshBlockBtn.Text = "Refresh Block ESP"
refreshBlockBtn.TextColor3 = Color3.fromRGB(230,230,240)
refreshBlockBtn.Font = Enum.Font.Gotham
refreshBlockBtn.TextSize = 14
refreshBlockBtn.TextTransparency = 1
refreshBlockBtn.AutoButtonColor = false
refreshBlockBtn.Parent = visualPage
Instance.new("UICorner", refreshBlockBtn).CornerRadius = UDim.new(0, 6)

--================= AntiAFK блок =================--

local antiTitle = Instance.new("TextLabel")
antiTitle.Size = UDim2.new(1, 0, 0, 20)
antiTitle.Position = UDim2.new(0, 0, 0, 0)
antiTitle.BackgroundTransparency = 1
antiTitle.Text = "Aisberg AntiAFK"
antiTitle.TextColor3 = Color3.fromRGB(230,230,240)
antiTitle.Font = Enum.Font.GothamBold
antiTitle.TextSize = 16
antiTitle.TextTransparency = 1
antiTitle.TextXAlignment = Enum.TextXAlignment.Left
antiTitle.Parent = antiPage

local antiStatus = Instance.new("TextLabel")
antiStatus.Size = UDim2.new(1, 0, 0, 18)
antiStatus.Position = UDim2.new(0, 0, 0, 24)
antiStatus.BackgroundTransparency = 1
antiStatus.Text = "Status: Inactive"
antiStatus.TextColor3 = Color3.fromRGB(200,200,210)
antiStatus.Font = Enum.Font.Gotham
antiStatus.TextSize = 14
antiStatus.TextTransparency = 1
antiStatus.TextXAlignment = Enum.TextXAlignment.Left
antiStatus.Parent = antiPage

local antiDesc = Instance.new("TextLabel")
antiDesc.Size = UDim2.new(1, 0, 0, 32)
antiDesc.Position = UDim2.new(0, 0, 0, 46)
antiDesc.BackgroundTransparency = 1
antiDesc.TextWrapped = true
antiDesc.Text = "Двигает/отдаляет камеру раз в несколько секунд, чтобы избежать AFK‑кика."
antiDesc.TextColor3 = Color3.fromRGB(160,160,185)
antiDesc.Font = Enum.Font.Gotham
antiDesc.TextSize = 13
antiDesc.TextTransparency = 1
antiDesc.TextXAlignment = Enum.TextXAlignment.Left
antiDesc.TextYAlignment = Enum.TextYAlignment.Top
antiDesc.Parent = antiPage

local antiBtn = Instance.new("TextButton")
antiBtn.Size = UDim2.new(0, 140, 0, 28)
antiBtn.Position = UDim2.new(0, 0, 0, 90)
antiBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
antiBtn.BorderSizePixel = 0
antiBtn.Text = "Toggle AntiAFK"
antiBtn.TextColor3 = Color3.fromRGB(230,230,240)
antiBtn.Font = Enum.Font.Gotham
antiBtn.TextSize = 14
antiBtn.TextTransparency = 1
antiBtn.AutoButtonColor = false
antiBtn.Parent = antiPage
Instance.new("UICorner", antiBtn).CornerRadius = UDim.new(0, 6)

local antiAFKEnabled = false

local function setAntiAFK(state)
    antiAFKEnabled = state
    if antiAFKEnabled then
        antiStatus.Text = "Status: Active"
        antiStatus.TextColor3 = Color3.fromRGB(0,255,0)
    else
        antiStatus.Text = "Status: Inactive"
        antiStatus.TextColor3 = Color3.fromRGB(200,200,210)
    end

    task.spawn(function()
        while antiAFKEnabled do
            task.wait(15)
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CFrame = cam.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, math.rad(8), 0)
            end
        end
    end)
end

antiBtn.MouseButton1Click:Connect(function()
    setAntiAFK(not antiAFKEnabled)
end)

--================= ЛОГИКА ВКЛАДОК =================--

local function setActiveTab(name)
    mainPage.Visible     = (name == "Main")
    gamePage.Visible     = (name == "Game")
    visualPage.Visible   = (name == "Visual")
    antiPage.Visible     = (name == "AntiAFK")
    settingsPage.Visible = (name == "Settings")

    mainTabBtn.BackgroundColor3     = name == "Main"     and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    gameTabBtn.BackgroundColor3     = name == "Game"     and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    visualTabBtn.BackgroundColor3   = name == "Visual"   and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    antiTabBtn.BackgroundColor3     = name == "AntiAFK"  and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    settingsTabBtn.BackgroundColor3 = name == "Settings" and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
end

mainTabBtn.MouseButton1Click:Connect(function() setActiveTab("Main") end)
gameTabBtn.MouseButton1Click:Connect(function() setActiveTab("Game") end)
visualTabBtn.MouseButton1Click:Connect(function() setActiveTab("Visual") end)
antiTabBtn.MouseButton1Click:Connect(function() setActiveTab("AntiAFK") end)
settingsTabBtn.MouseButton1Click:Connect(function() setActiveTab("Settings") end)

setActiveTab("Main")

--================= ОБРАБОТЧИКИ VISUAL КНОПОК =================--

playerESPBtn.MouseButton1Click:Connect(function()
    togglePlayerESP()
    playerESPBtn.Text = playerESPEnabled and "Player ESP: ON" or "Player ESP: OFF"
    playerESPBtn.BackgroundColor3 = playerESPEnabled and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(35,35,50)
end)

blockESPBtn.MouseButton1Click:Connect(function()
    toggleBlockESP()
    blockESPBtn.Text = blockESPEnabled and "Block Essence ESP: ON" or "Block Essence ESP: OFF"
    blockESPBtn.BackgroundColor3 = blockESPEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(35,35,50)
end)

refreshBlockBtn.MouseButton1Click:Connect(function()
    if blockESPEnabled then
        scanBlockEssence()
    end
end)

--================= АНИМАЦИЯ =================--

local isVisible = false
local tweenTime = 0.3
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local guiElements = {
    title, subtitle, closeBtn,
    mainTabBtn, gameTabBtn, visualTabBtn, antiTabBtn, settingsTabBtn,
    mainPlaceholder, gamePlaceholder, visualPlaceholder, settingsPlaceholder,
    antiTitle, antiStatus, antiDesc, antiBtn,
    playerESPBtn, blockESPBtn, refreshBlockBtn
}

local function setTextTransparency(value)
    for _, ui in ipairs(guiElements) do
        if ui and (ui:IsA("TextLabel") or ui:IsA("TextButton")) then
            ui.TextTransparency = value
        end
    end
end

local function fadeIn()
    frame.Visible = true
    frame.Size = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    setTextTransparency(1)

    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(0, 420, 0, 260),
        BackgroundTransparency = 0.4
    }):Play()

    for _, ui in ipairs(guiElements) do
        if ui then
            TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 0}):Play()
        end
    end
end

local function fadeOut(callback)
    TweenService:Create(frame, TweenInfo.new(tweenTime, easing, direction), {
        Size = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    }):Play()

    for _, ui in ipairs(guiElements) do
        if ui then
            TweenService:Create(ui, TweenInfo.new(tweenTime), {TextTransparency = 1}):Play()
        end
    end

    task.delay(tweenTime, function()
        frame.Visible = false
        if callback then callback() end
    end)
end

--================= КЛАВИША K И ЗАКРЫТИЕ =================--

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

print("AisbergHub UI загружен. Нажми K для меню.")
