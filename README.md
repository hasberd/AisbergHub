--=== AisbergHub Spectral Style (автозапуск + расширяемое меню) ===--

if getgenv and getgenv().AisbergHubLoaded then return end
if getgenv then getgenv().AisbergHubLoaded = true end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

-- Твоя логика ESP, коллекторов (остается без изменений)
local playerESPEnabled = false
local collectingEssence = false
local collectingChest = false
local antiAFKEnabled = false

-- Все твои функции (clearPlayerESP, applyPlayerESP, collectBlockEssence, etc.) 
-- вставляются сюда БЕЗ ИЗМЕНЕНИЙ

--================= SPECTRAL GUI =================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AisbergHub_Spectral"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

-- Главная рамка
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true  -- ✅ ВКЛЮЧЕНО СРАЗУ
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Верхняя панель
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- ❌ КНОПКА ЗАКРЫТИЯ (СПРАВА В УГЛУ)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Логотип
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

-- Status + Автор
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 100, 0, 20)
StatusLabel.Position = UDim2.new(0, 180, 0.5, -10)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
StatusLabel.Text = "Undetected"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = TopBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 4)
StatusCorner.Parent = StatusLabel

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(0, 100, 0, 16)
AuthorLabel.Position = UDim2.new(0, 290, 0.5, -8)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "by hasberd"
AuthorLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
AuthorLabel.Font = Enum.Font.Gotham
AuthorLabel.TextSize = 11
AuthorLabel.Parent = TopBar

-- Левая панель категорий
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 180, 1, -60)
SideBar.Position = UDim2.new(0, 0, 0, 45)
SideBar.BackgroundTransparency = 1
SideBar.Parent = MainFrame

local Categories = {"🏠 Главное", "🎮 Универсал", "⚡ Tap Sim", "👁️ Visuals", "🛡️ AntiAFK"}
local CategoryBtns = {}
local CurrentTab = 1

for i, category in ipairs(Categories) do
    local btn = Instance.new("TextButton")
    btn.Name = "CategoryBtn" .. i
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (i-1) * 45 + 10)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 35)
    btn.BorderSizePixel = 0
    btn.Text = category
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = SideBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    CategoryBtns[i] = btn
end

-- Контент область
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -200, 1, -65)
ContentFrame.Position = UDim2.new(0, 185, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Info панель снизу
local InfoPanel = Instance.new("Frame")
InfoPanel.Size = UDim2.new(1, -20, 0, 30)
InfoPanel.Position = UDim2.new(0, 10, 1, -40)
InfoPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
InfoPanel.BorderSizePixel = 0
InfoPanel.Parent = MainFrame

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoPanel

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

-- Твои кнопки (Tap Sim таб)
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
CollectChestBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CollectChestBtn.BorderSizePixel = 0
CollectChestBtn.Text = "📦 Collect Clicker Chest"
CollectChestBtn.TextColor3 = Color3.fromRGB(230, 230, 250)
CollectChestBtn.Font = Enum.Font.Gotham
CollectChestBtn.TextSize = 15
CollectChestBtn.AutoButtonColor = false
CollectChestBtn.Parent = ContentFrame

-- Скругления кнопок
for _, btn in pairs({CollectEssenceBtn, CollectChestBtn}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
end

-- ЛОГИКА РАБОТЫ МЕНЮ

local isMinimized = false
local isClosed = false

-- 🔄 Переключение табов
for i, btn in ipairs(CategoryBtns) do
    btn.MouseButton1Click:Connect(function()
        CurrentTab = i
        for j, catBtn in ipairs(CategoryBtns) do
            catBtn.BackgroundColor3 = j == i and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 35)
        end
        -- Здесь логика показа контента для таба i
    end)
end

-- ❌ ЗАКРЫТИЕ НА СОВСЕМ
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()  -- Полное удаление
    isClosed = true
end)

-- K - СКРЫТЬ/ПОКАЗАТЬ
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        if isClosed then return end
        
        if MainFrame.Size.X.Scale == 0 then  -- Расширить на весь экран
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10)
            }):Play()
        else  -- Свернуть/показать
            if isMinimized then
                MainFrame.Size = UDim2.new(0, 600, 0, 400)
                MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
                isMinimized = false
            else
                MainFrame.Size = UDim2.new(0, 50, 0, 50)
                isMinimized = true
            end
        end
    end
end)

-- Подключение твоих функций
CollectEssenceBtn.MouseButton1Click:Connect(collectBlockEssence)
CollectChestBtn.MouseButton1Click:Connect(collectClickerChests)

print("🚀 AisbergHub Spectral загружен! K = свернуть/расширить, ✕ = закрыть навсегда")
