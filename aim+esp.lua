-- UltraSharp Roblox Cheat v6.1 (Исправленный FOV)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Ультра-резкий ESP
local SharpESP = {
    Boxes = {},
    Names = {},
    Distance = {}
}

-- Умный аимбот с исправленным FOV
local SmartAimbot = {
    Target = nil,
    Smoothness = 0.02, -- Очень резкий
    FOV = 500, -- Исправлено: разумное значение вместо math.huge
    TargetPart = "Head",
    WallCheck = true
}

-- Проверка видимости через Raycast
function IsVisible(targetPart)
    if not SmartAimbot.WallCheck then return true end
    
    local cameraPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local raycastResult = Workspace:Raycast(cameraPos, (targetPos - cameraPos), raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart:IsDescendantOf(targetPart.Parent) then
            return true
        else
            return false
        end
    end
    
    return true
end

-- Ультра-резкий ESP рендеринг
function CreateSharpESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.new(1, 0, 0)
    box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 16
    name.Center = true
    name.Color = Color3.new(1, 1, 1)
    name.Outline = true
    name.Visible = false
    
    local distance = Drawing.new("Text")
    distance.Size = 14
    distance.Center = true
    distance.Color = Color3.new(0, 1, 1)
    distance.Outline = true
    distance.Visible = false
    
    SharpESP.Boxes[player] = box
    SharpESP.Names[player] = name
    SharpESP.Distance[player] = distance
    
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if root and head then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local visible = IsVisible(head)
                    local espColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    
                    local scale = 2000 / pos.Z
                    box.Size = Vector2.new(scale, scale * 1.5)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Color = espColor
                    box.Visible = true
                    
                    name.Text = player.Name
                    name.Position = Vector2.new(pos.X, pos.Y - box.Size.Y / 2 - 15)
                    name.Visible = true
                    
                    local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                    distance.Text = dist .. "m"
                    distance.Position = Vector2.new(pos.X, pos.Y + box.Size.Y / 2 + 5)
                    distance.Visible = true
                else
                    box.Visible = false
                    name.Visible = false
                    distance.Visible = false
                end
            end
        else
            box.Visible = false
            name.Visible = false
            distance.Visible = false
        end
    end)
end

-- Умный аимбот с исправленной логикой FOV
function SmartAimbotLoop()
    RunService.RenderStepped:Connect(function()
        local closest = nil
        local closestDist = SmartAimbot.FOV -- Теперь используем FOV как максимальное расстояние
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local head = player.Character:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and root and head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen and IsVisible(head) then
                        local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- Исправленная логика: ищем ближайшую цель в пределах FOV
                        if dist < closestDist then
                            closestDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
        
        if closest and closest.Character then
            local targetPart = closest.Character:FindFirstChild(SmartAimbot.TargetPart)
            if targetPart and IsVisible(targetPart) then
                local currentCF = Camera.CFrame
                local targetPos = targetPart.Position
                
                local newCF = CFrame.lookAt(currentCF.Position, targetPos)
                Camera.CFrame = currentCF:Lerp(newCF, SmartAimbot.Smoothness)
            end
        end
    end)
end

-- Автоматическая инициализация для всех игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateSharpESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        CreateSharpESP(player)
    end)
end)

-- Запуск систем
SmartAimbotLoop()

print("🎯 АИМБОТ АКТИВИРОВАН (ИСПРАВЛЕННЫЙ FOV)")
print("📡 ESP С ПРОВЕРКОЙ СТЕН")
print("⚡ FOV: 500 (ОПТИМАЛЬНЫЙ)")
