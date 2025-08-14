-- Ультра-простая Audio Wave Plate
-- Максимальные эффекты, минимум кода!

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Создаем основную плиту
local plate = Instance.new("Part")
plate.Name = "WavePlate"
plate.Size = Vector3.new(30, 1, 30)
plate.Position = Vector3.new(0, 0, 0)
plate.Anchored = true
plate.Material = Enum.Material.Neon
plate.BrickColor = BrickColor.new("Really blue")
plate.Parent = workspace

-- Музыка
local music = Instance.new("Sound")
music.SoundId = "rbxassetid://122400781295647"
music.Volume = 0.7
music.Looped = true
music.Parent = plate

-- Создаем кубики (12x12 для лучшей производительности)
local cubes = {}
for x = 1, 12 do
    cubes[x] = {}
    for z = 1, 12 do
        local cube = Instance.new("Part")
        cube.Size = Vector3.new(1.8, 1.8, 1.8)
        cube.Position = Vector3.new((x - 6.5) * 2, 0.5, (z - 6.5) * 2)
        cube.Anchored = true
        cube.Material = Enum.Material.Neon
        cube.BrickColor = BrickColor.new("Cyan")
        cube.Parent = workspace
        cubes[x][z] = cube
    end
end

-- Основной эффект
RunService.Heartbeat:Connect(function()
    local time = tick() * 2
    
    for x = 1, 12 do
        for z = 1, 12 do
            local cube = cubes[x][z]
            local distance = math.sqrt((x - 6.5)^2 + (z - 6.5)^2)
            local wave = math.sin(time - distance * 0.4) * 3
            local noise = math.noise(x * 0.3, z * 0.3, time * 0.2) * 2
            
            local height = wave + noise + 0.5
            
            -- Анимация
            local tween = TweenService:Create(cube, TweenInfo.new(0.1), {
                Position = Vector3.new(cube.Position.X, height, cube.Position.Z)
            })
            tween:Play()
            
            -- Цвет
            local intensity = math.clamp(height / 5, 0, 1)
            cube.BrickColor = BrickColor.new(Color3.new(
                0.2 + intensity * 0.8,
                0.2 + intensity * 0.8,
                0.6 + intensity * 0.4
            ))
        end
    end
end)

-- Запускаем музыку
wait(1)
music:Play()
print("🎵 Плита готова! 144 кубика создают волны под музыку!")