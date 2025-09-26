-- UltraSharp Roblox Cheat v5.0 (ESP + Aimbot Only)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Ультра-резкий ESP
local SharpESP = {
    Boxes = {},
    Names = {},
    Distance = {}
}

-- Резкий аимбот с мгновенным откликом на любом расстоянии
local SharpAimbot = {
    Target = nil,
    Smoothness = 0.05,
    TargetPart = "Head"
}

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
    
    -- Обновление ESP каждый кадр
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if root and head then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Резкое отображение без задержек
                    local scale = 2000 / pos.Z
                    box.Size = Vector2.new(scale, scale * 1.5)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
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

-- Резкий аимбот с мгновенным прицеливанием на любом расстоянии
function SharpAimbotLoop()
    RunService.RenderStepped:Connect(function()
        -- Поиск ближайшей цели без ограничений по расстоянию
        local closest = nil
        local closestDist = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and root then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
        
        -- Мгновенное прицеливание на любом расстоянии
        if closest and closest.Character then
            local targetPart = closest.Character:FindFirstChild(SharpAimbot.TargetPart)
            if targetPart then
                local currentCF = Camera.CFrame
                local targetPos = targetPart.Position
                
                -- Ультра-резкое наведение
                local newCF = CFrame.lookAt(currentCF.Position, targetPos)
                Camera.CFrame = currentCF:Lerp(newCF, SharpAimbot.Smoothness)
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
SharpAimbotLoop()

print("🎯 АИМБОТ АКТИВИРОВАН (РАБОТАЕТ НА ЛЮБОМ РАССТОЯНИИ)")
print("📡 ESP АКТИВИРОВАН")
