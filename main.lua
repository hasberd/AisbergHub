-- Проверка на повторный запуск
if getgenv().MyHubLoaded then return end
getgenv().MyHubLoaded = true

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Мой Хаб v1.0 (2026)",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyHubConfig"
})

local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998"})

PlayerTab:AddSection({Name = "Движение"})

local SpeedToggle = PlayerTab:AddToggle({
    Name = "Скорость x3",
    Default = false,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v and 48 or 16 end
    end
})

PlayerTab:AddButton({
    Name = "Инфинити Джамп",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local InfiniteJumpEnabled = false
        UserInputService.JumpRequest:Connect(function()
            if InfiniteJumpEnabled then game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
        end)
        InfiniteJumpEnabled = not InfiniteJumpEnabled
        OrionLib:MakeNotification({Name = "Jump", Content = InfiniteJumpEnabled and "Вкл" or "Выкл", Time = 2})
    end
})

local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})

CombatTab:AddSection({Name = "ESP & TP"})

CombatTab:AddButton({
    Name = "ESP Всех игроков",
    Callback = function()
        for i,v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Highlight = Instance.new("Highlight")
                Highlight.Name = v.Name .. " ESP"
                Highlight.Parent = v.Character
                Highlight.Adornee = v.Character
                Highlight.FillColor = Color3.new(0,1,0)
            end
        end
    end
})

CombatTab:AddButton({
    Name = "TP к рандом игроку",
    Callback = function()
        local players = game.Players:GetPlayers()
        local randomPlayer = players[math.random(1, #players)]
        if randomPlayer.Character and randomPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
        end
    end
})

OrionLib:Init()
OrionLib:MakeNotification({
    Name = "Хаб готов!",
    Content = "RightShift для меню. VPN включи!",
    Time = 5
})
