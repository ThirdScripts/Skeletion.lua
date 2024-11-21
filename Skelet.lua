-- Убедитесь, что игра загружена
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Подключение служб
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Таблица для хранения линий
local ESP_Lines = {}

-- Функция для создания ESP линий
local function createESP(player)
    if player == Players.LocalPlayer then return end

    local lines = {
        HeadToTorso = Drawing.new("Line"), -- Голова -> Туловище
        TorsoToLeftArm = Drawing.new("Line"), -- Туловище -> Левая верхняя рука
        LeftArmToHand = Drawing.new("Line"), -- Верхняя -> нижняя рука -> кисть
        TorsoToRightArm = Drawing.new("Line"), -- Туловище -> Правая верхняя рука
        RightArmToHand = Drawing.new("Line"), -- Верхняя -> нижняя рука -> кисть
        TorsoToLeftLeg = Drawing.new("Line"), -- Туловище -> Левая верхняя нога
        LeftLegToFoot = Drawing.new("Line"), -- Верхняя -> нижняя нога -> ступня
        TorsoToRightLeg = Drawing.new("Line"), -- Туловище -> Правая верхняя нога
        RightLegToFoot = Drawing.new("Line"), -- Верхняя -> нижняя нога -> ступня
    }

    -- Настройка линий
    for _, line in pairs(lines) do
        line.Thickness = 2 -- Толщина линий
        line.Color = Color3.new(1, 1, 1) -- Белый цвет
        line.Transparency = 1 -- Полностью видимые
    end

    ESP_Lines[player] = lines
end

-- Функция для обновления ESP линий
local function updateESP(player)
    local character = player.Character
    local lines = ESP_Lines[player]

    if not character or not lines then return end

    -- Поиск частей тела
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    local leftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local leftLowerArm = character:FindFirstChild("LeftLowerArm")
    local leftHand = character:FindFirstChild("LeftHand")
    local rightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    local rightLowerArm = character:FindFirstChild("RightLowerArm")
    local rightHand = character:FindFirstChild("RightHand")
    local leftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
    local leftFoot = character:FindFirstChild("LeftFoot")
    local rightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
    local rightFoot = character:FindFirstChild("RightFoot")

    -- Функция для обновления линии между двумя частями
    local function updateLine(line, part1, part2)
        if part1 and part2 then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)

            if onScreen1 and onScreen2 then
                line.Visible = true
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end

    -- Обновление линий
    updateLine(lines.HeadToTorso, head, torso)
    updateLine(lines.TorsoToLeftArm, torso, leftUpperArm)
    updateLine(lines.LeftArmToHand, leftUpperArm, leftHand or leftLowerArm)
    updateLine(lines.TorsoToRightArm, torso, rightUpperArm)
    updateLine(lines.RightArmToHand, rightUpperArm, rightHand or rightLowerArm)
    updateLine(lines.TorsoToLeftLeg, torso, leftUpperLeg)
    updateLine(lines.LeftLegToFoot, leftUpperLeg, leftFoot or leftLowerLeg)
    updateLine(lines.TorsoToRightLeg, torso, rightUpperLeg)
    updateLine(lines.RightLegToFoot, rightUpperLeg, rightFoot or rightLowerLeg)
end

-- Функция для удаления ESP линий
local function removeESP(player)
    if ESP_Lines[player] then
        for _, line in pairs(ESP_Lines[player]) do
            line:Remove()
        end
        ESP_Lines[player] = nil
    end
end

-- Отслеживание новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

-- Удаление ESP линий при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Основной цикл обновления ESP
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        updateESP(player)
    end
end)

-- Инициализация для существующих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        createESP(player)
    end
end
