--================= Collect Block Essence (BlockEssence = Model: Primary + ProximityPrompt) =================--

local collectingEssence = false

local function getHRP()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- возвращает таблицу { part = PrimaryPart, prompt = ProximityPrompt } для всех BlockEssence
local function findEssenceTargets()
    local list = {}

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "BlockEssence" then
            local primary = model:FindFirstChild("Primary")
            if not (primary and primary:IsA("BasePart")) then
                -- если нет ноды "Primary", пробуем Model.PrimaryPart или первый Part
                if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
                    primary = model.PrimaryPart
                else
                    for _, child in ipairs(model:GetDescendants()) do
                        if child:IsA("BasePart") then
                            primary = child
                            break
                        end
                    end
                end
            end

            local prompt = model:FindFirstChildOfClass("ProximityPrompt")
                or model:FindFirstChildWhichIsA("ProximityPrompt", true)

            if primary and prompt then
                table.insert(list, {
                    part = primary,
                    prompt = prompt
                })
            end
        end
    end

    return list
end

local function collectBlockEssence()
    if collectingEssence then return end
    collectingEssence = true

    local hrp = getHRP()
    if not hrp then
        collectingEssence = false
        return
    end

    local targets = findEssenceTargets()
    print("BlockEssence targets found:", #targets)

    for _, t in ipairs(targets) do
        if not collectingEssence then break end
        local part = t.part
        local prompt = t.prompt

        if part and part.Parent and prompt and prompt.Parent then
            -- телепорт немного над блоком
            hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.2)

            -- «зажимаем E» несколько раз[web:278][web:281]
            for i = 1, 5 do
                if not collectingEssence then break end
                pcall(function()
                    fireproximityprompt(prompt, 1)
                end)
                task.wait(0.25)
            end
        end
    end

    collectingEssence = false
end

-- обработчик кнопки (оставь как есть либо проверь, что он именно такой)
collectEssenceBtn.MouseButton1Click:Connect(function()
    if not collectingEssence then
        collectEssenceBtn.Text = "Collecting..."
        collectBlockEssence()
        collectEssenceBtn.Text = "Collect Block Essence"
    else
        collectingEssence = false
        collectEssenceBtn.Text = "Collect Block Essence"
    end
end)
