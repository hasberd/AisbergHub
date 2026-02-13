local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "AisbergHub v1.0",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyHub",
    IntroEnabled = true
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddSection({Name = "Настройки игрока"})

PlayerTab:AddToggle({
    Name = "Скорость (WalkSpeed)",
    Default = false,
    Save = true,
    Flag = "SpeedToggle",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value and 50 or 16
        end
    end
})

PlayerTab:AddToggle({
    Name = "Высокий прыжок (JumpPower)",
    Default = false,
    Save = true,
    Flag = "JumpToggle",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value and 100 or 50
        end
    end
})

PlayerTab:AddButton({
    Name = "ESP (подсветка игроков)",
    Callback = function()
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local highlight = Instance.new("Highlight", player.Character)
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
            end
        end
        OrionLib:MakeNotification({
            Name = "ESP включён",
            Content = "Все игроки подсвечены!",
            Time = 3
        })
    end
})

local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddSection({Name = "Бой и телепорт"})

CombatTab:AddButton({
    Name = "Телепорт к ближайшему игроку",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local closest, dist = nil, math.huge
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then closest = p; dist = d end
            end
        end
        if closest then
            lp.Character.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            OrionLib:MakeNotification({Name = "TP", Content = "Телепорт к " .. closest.Name, Time = 3})
        end
    end
})

CombatTab:AddButton({
    Name = "Выдать инструмент (Tool)",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        local handle = Instance.new("Part", tool)
        handle.Name = "Handle"
        handle.Size = Vector3.new(0, 0, 0)
        tool.Parent = game.Players.LocalPlayer.Backpack
    end
})

OrionLib:Init()
