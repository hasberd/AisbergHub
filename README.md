--=== AisbergHub UI (каркас, без функционала) ===--

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

--================= ВКЛАДКИ (кнопки) =================--

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0, 260, 0, 30)
tabsFrame.Position = UDim2.new(0, 14, 0, 56)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local function createTabButton(name, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 24)
    btn.Position = UDim2.new(0, xOffset, 0, 3)
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

local mainTabBtn   = createTabButton("Main",   0)
local gameTabBtn   = createTabButton("Game",   90)
local visualTabBtn = createTabButton("Visual", 180)

--================= КОНТЕНТ ВКЛАДОК (пока пустой) =================--

local pagesFrame = Instance.new("Frame")
pagesFrame.Size = UDim2.new(1, -28, 1, -96)
pagesFrame.Position = UDim2.new(0, 14, 0, 90)
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
mainPlaceholder.Text = "Main tab (сюда позже добавим Speed/AntiAFK/и т.д.)"
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
gamePlaceholder.Text = "Game tab (Tap Simulator: авто‑тап, авто‑яйца и т.п.)"
gamePlaceholder.Parent = gamePage

local visualPage = Instance.new("Frame")
visualPage.Size = UDim2.new(1, 0, 1, 0)
visualPage.BackgroundTransparency = 1
visualPage.Visible = false
visualPage.Parent = pagesFrame

local visualPlaceholder = mainPlaceholder:Clone()
visualPlaceholder.Text = "Visual tab (ESP, UI, эффекты)."
visualPlaceholder.Parent = visualPage

--================= ЛОГИКА ВКЛАДОК =================--

local function setActiveTab(name)
    mainPage.Visible   = (name == "Main")
    gamePage.Visible   = (name == "Game")
    visualPage.Visible = (name == "Visual")

    mainTabBtn.BackgroundColor3   = name == "Main"   and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    gameTabBtn.BackgroundColor3   = name == "Game"   and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
    visualTabBtn.BackgroundColor3 = name == "Visual" and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,45)
end

mainTabBtn.MouseButton1Click:Connect(function() setActiveTab("Main") end)
gameTabBtn.MouseButton1Click:Connect(function() setActiveTab("Game") end)
visualTabBtn.MouseButton1Click:Connect(function() setActiveTab("Visual") end)

setActiveTab("Main")

--================= АНИМАЦИЯ (scale + fade) =================--

local isVisible = false
local tweenTime = 0.3
local easing = Enum.EasingStyle.Quad
local direction = Enum.EasingDirection.Out

local guiElements = {
    title, subtitle, closeBtn,
    mainTabBtn, gameTabBtn, visualTabBtn,
    mainPlaceholder, gamePlaceholder, visualPlaceholder
}

local function setTextTransparency(value)
    for _, ui in ipairs(guiElements) do
        if ui and ui:IsA("GuiObject") then
            if ui:IsA("TextLabel") or ui:IsA("TextButton") then
                ui.TextTransparency = value
            end
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

--================= КНОПКА ЗАКРЫТИЯ И КЛАВИША K =================--

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

print("AisbergHub UI загружен. Нажми K для открытия меню.")
