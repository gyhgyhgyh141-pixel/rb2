-- NetErrror Roblox Cheat Script v3.0 - ESP + Wall Check
-- Полная версия с ESP и проверкой стен

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Настройки аимбота с проверкой стен
local Aimlock = {
    Enabled = true,
    Target = nil,
    Smoothness = 0.08,
    FOV = 60,
    TeamCheck = true,
    WallCheck = true, -- ПРОВЕРКА СТЕН
    AutoSwitch = true
}

-- Настройки ESP
local ESP = {
    Enabled = true,
    Boxes = true,
    Tracers = true,
    Names = true,
    Distance = true,
    TeamColor = true,
    WallHack = true -- ESP ЧЕРЕЗ СТЕНЫ
}

local ESPObjects = {}

-- Функция проверки видимости через стены
function IsVisible(targetPart)
    if not Aimlock.WallCheck then return true end
    
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local target = targetPart.Position
    local direction = (target - origin).Unit
    local distance = (target - origin).Magnitude
    
    -- Raycast для проверки препятствий
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    return raycastResult == nil
end

-- Автопоиск цели с проверкой стен
function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Aimlock.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Aimlock.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local character = player.Character
            local head = character:FindFirstChild("Head")
            
            if head then
                local screenPoint, visible = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                
                -- ПРОВЕРКА СТЕН
                local isVisible = IsVisible(head)
                
                if distance < shortestDistance and (visible or ESP.WallHack) and isVisible then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Аимбот с проверкой стен
RunService.RenderStepped:Connect(function()
    if Aimlock.Enabled then
        if Aimlock.AutoSwitch or not Aimlock.Target then
            Aimlock.Target = GetClosestPlayer()
        end
        
        if Aimlock.Target then
            local targetCharacter = Aimlock.Target.Character
            if targetCharacter and targetCharacter:FindFirstChild("Head") then
                local head = targetCharacter.Head
                
                -- ПРОВЕРКА СТЕН ПЕРЕД ПРИЦЕЛИВАНИЕМ
                if IsVisible(head) then
                    local camera = workspace.CurrentCamera
                    local currentCFrame = camera.CFrame
                    local targetPosition = head.Position + Vector3.new(0, -0.5, 0)
                    local newCFrame = currentCFrame:Lerp(CFrame.lookAt(currentCFrame.Position, targetPosition), Aimlock.Smoothness)
                    
                    camera.CFrame = newCFrame
                else
                    Aimlock.Target = nil
                end
            else
                Aimlock.Target = nil
            end
        end
    end
end)

-- УЛУЧШЕННЫЙ ESP С ИНДИКАТОРОМ СТЕН
function CreateESP(player)
    if ESPObjects[player] then return end
    
    local drawingObjects = {}
    
    -- Box
    drawingObjects.Box = Drawing.new("Square")
    drawingObjects.Box.Thickness = 2
    drawingObjects.Box.Filled = false
    
    -- Tracer
    drawingObjects.Tracer = Drawing.new("Line")
    drawingObjects.Tracer.Thickness = 1
    
    -- Name
    drawingObjects.Name = Drawing.new("Text")
    drawingObjects.Name.Size = 16
    drawingObjects.Name.Center = true
    drawingObjects.Name.Outline = true
    
    -- Distance
    drawingObjects.Distance = Drawing.new("Text")
    drawingObjects.Distance.Size = 14
    drawingObjects.Distance.Center = true
    drawingObjects.Distance.Outline = true
    
    -- Wall Indicator
    drawingObjects.WallIndicator = Drawing.new("Text")
    drawingObjects.WallIndicator.Size = 12
    drawingObjects.WallIndicator.Center = true
    drawingObjects.WallIndicator.Outline = true
    drawingObjects.WallIndicator.Text = "🔴"
    
    ESPObjects[player] = drawingObjects
end

-- Обновление ESP с индикатором стен
function UpdateESP()
    for player, drawings in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if rootPart and head then
                local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                local isVisible = IsVisible(head)
                
                -- Цвет в зависимости от видимости
                local color
                if ESP.TeamColor and player.Team then
                    color = player.Team.TeamColor.Color
                else
                    color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) -- Зеленый если видно, красный если скрыт
                end
                
                if onScreen or ESP.WallHack then
                    -- Box
                    local scale = 1000 / (position.Z > 0 and position.Z or 1)
                    drawings.Box.Size = Vector2.new(scale, scale * 2)
                    drawings.Box.Position = Vector2.new(position.X - scale/2, position.Y - scale)
                    drawings.Box.Visible = ESP.Boxes
                    drawings.Box.Color = color
                    
                    -- Tracer
                    if onScreen then
                        drawings.Tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(position.X, position.Y)
                    else
                        -- Если игрок за экраном, показываем трассер к краю экрана
                        local dir = (rootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit
                        local screenSize = workspace.CurrentCamera.ViewportSize
                        local edgePos = Vector2.new(
                            math.clamp(position.X, 50, screenSize.X - 50),
                            math.clamp(position.Y, 50, screenSize.Y - 50)
                        )
                        drawings.Tracer.From = Vector2.new(screenSize.X/2, screenSize.Y/2)
                        drawings.Tracer.To = edgePos
                    end
                    drawings.Tracer.Visible = ESP.Tracers
                    drawings.Tracer.Color = color
                    
                    -- Name
                    drawings.Name.Position = Vector2.new(position.X, position.Y - 40)
                    drawings.Name.Text = player.Name
                    drawings.Name.Visible = ESP.Names
                    drawings.Name.Color = color
                    
                    -- Distance
                    local distance = (rootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                    drawings.Distance.Position = Vector2.new(position.X, position.Y - 20)
                    drawings.Distance.Text = tostring(math.floor(distance)) .. " studs"
                    drawings.Distance.Visible = ESP.Distance
                    drawings.Distance.Color = Color3.new(1, 1, 0)
                    
                    -- Wall Indicator
                    drawings.WallIndicator.Position = Vector2.new(position.X, position.Y - 60)
                    drawings.WallIndicator.Text = isVisible and "🟢" or "🔴"
                    drawings.WallIndicator.Visible = true
                    drawings.WallIndicator.Color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                else
                    HideESP(player)
                end
            else
                HideESP(player)
            end
        else
            HideESP(player)
        end
    end
end

function HideESP(player)
    local drawings = ESPObjects[player]
    if drawings then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
    end
end

-- Инициализация ESP
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end)

-- Главный цикл ESP
RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        UpdateESP()
    else
        for player, _ in pairs(ESPObjects) do
            HideESP(player)
        end
    end
end)

print("===========================================")
print("NetErrror Cheat v3.0 ЗАПУЩЕН!")
print("Аимбот: ВКЛ (с проверкой стен)")
print("ESP: ВКЛ (с индикаторами видимости)")
print("🟢 = Видно | 🔴 = Скрыт за стеной")
print("===========================================")
