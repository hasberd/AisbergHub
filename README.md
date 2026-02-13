--=== AisbergHub Spectral Style (по образцу Spectral Hub) ===--

if getgenv and getgenv().AisbergHubLoaded then return end
if getgenv then getgenv().AisbergHubLoaded = true end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

-- Твоя логика ESP, коллекторов (без изменений)
local playerESPEnabled = false
-- ... [все твои функции clearPlayerESP, applyPlayerESP, collectBlockEssence и т.д. остаются как есть]

--================= SPECTRAL-STYLE GUI =================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AisbergHub_Spectral"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

-- Главная рамка (тёмная тема Spectral)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Верхняя панель (как у Spectral)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Логотип AisbergHub (сверху слева)
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 150, 1, 0)
Logo.Position = UDim2.new(0, 15, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "AisbergHub"
Logo.TextColor3 = Color3.fromRGB(100, 200, 255)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 18
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

-- Статус Undetected (как Spectral)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 120, 0, 20)
StatusLabel.Position = UDim2.new(0, 180, 0.5, -10)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
StatusLabel.BorderSizePixel = 0
StatusLabel.Text = "Undetected"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = TopBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 4)
StatusCorner.Parent = StatusLabel

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(0, 120, 0, 16)
AuthorLabel.Position = UDim2.new(0, 310, 0.5, -8)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "by hasberd"
AuthorLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
AuthorLabel.Font = Enum.Font.Gotham
AuthorLabel.TextSize = 11
AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
AuthorLabel.Parent = TopBar

-- Левая боковая панель (иконки категорий)
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 180, 1, -60)
SideBar.Position = UDim2.new(0, 0, 0, 45)
SideBar.BackgroundTransparency = 1
SideBar.Parent = MainFrame

-- Кнопки категорий (иконки + текст справа)
local Categories = {"🏠 Main", "🎮 Universal", "⚡ Tap Sim", "👁️ Visuals", "🛡️ AntiAFK"}
local CategoryBtns = {}

for i, category in ipairs(Categories) do
    local btn = Instance.new("TextButton")
    btn.Name = "CategoryBtn" .. i
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (i-1) * 45 + 10)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BorderSizePixel = 0
    btn.Text = category
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = SideBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    CategoryBtns[i] = btn
end

-- Основная область контента (справа)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -200, 1, -65)
ContentFrame.Position = UDim2.new(0, 185, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Информационная панель (как в Spectral снизу)
local InfoPanel = Instance.new("Frame")
InfoPanel.Name = "InfoPanel"
InfoPanel.Size = UDim2.new(1, -20, 0, 30)
InfoPanel.Position = UDim2.new(0, 10, 1, -40)
InfoPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
InfoPanel.BorderSizePixel = 0
InfoPanel.Parent = MainFrame

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoPanel

-- Инфо лейблы (как в Spectral)
local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0.3, 0, 1, 0)
UserLabel.Position = UDim2.new(0, 10, 0, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "User: " .. lp.Name
UserLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 12
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = InfoPanel

local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(0.4, 0, 1, 0)
GameLabel.Position = UDim2.new(0.35, 0, 0, 0)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Current Game: [UPD] Tap Simulator"
GameLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
GameLabel.Font = Enum.Font.Gotham
GameLabel.TextSize = 12
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.Parent = InfoPanel

-- Твои кнопки в ContentFrame (пример для Tap Sim таба)
local CollectEssenceBtn = Instance.new("TextButton")
CollectEssenceBtn.Size = UDim2.new(0, 220, 0, 45)
CollectEssenceBtn.Position = UDim2.new(0, 20, 0, 20)
CollectEssenceBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CollectEssenceBtn.BorderSizePixel = 0
CollectEssenceBtn.Text = "💎 Collect Block Essence"
CollectEssenceBtn.TextColor3 = Color3.fromRGB(230, 230, 250)
CollectEssenceBtn.Font = Enum.Font.Gotham
CollectEssenceBtn.TextSize = 15
CollectEssenceBtn.AutoButtonColor = false
CollectEssenceBtn.Parent = ContentFrame

local CollectChestBtn = Instance.new("TextButton")
CollectChestBtn.Size = UDim2.new(0, 220, 0, 45)
CollectChestBtn.Position = UDim2.new(0, 20, 0, 75)
CollectChestChestBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CollectChestBtn.BorderSizePixel = 0
CollectChestBtn.Text = "📦 Collect Clicker Chest"
CollectChestBtn.TextColor3 = Color3.fromRGB(230, 230, 250)
CollectChestBtn.Font = Enum.Font.Gotham
CollectChestBtn.TextSize = 15
CollectChestBtn.AutoButtonColor = false
CollectChestBtn.Parent = ContentFrame

-- Скругления для кнопок
for _, btn in pairs({CollectEssenceBtn, CollectChestBtn}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
end

-- Анимация открытия (улучшенная)
local isVisible = false
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function toggleMenu()
    isVisible = not isVisible
    if isVisible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 50, 0, 50)
        TweenService:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 600, 0, 400)
        }):Play()
    else
        TweenService:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 50, 0, 50)
        }):Play()
        task.wait(0.4)
        MainFrame.Visible = false
    end
end

-- Хоткей (Insert вместо K)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
end)

-- Подключение твоих функций к кнопкам
CollectEssenceBtn.MouseButton1Click:Connect(collectBlockEssence)
CollectChestBtn.MouseButton1Click:Connect(collectClickerChests)

print("🔥 AisbergHub загружен! Нажми INSERT для открытия")
