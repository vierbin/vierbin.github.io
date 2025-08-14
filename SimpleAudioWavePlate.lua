-- Простая Audio Wave Plate для Roblox
-- Работает сразу без команд - просто скопируй и вставь!

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Настройки плиты
local PLATE_SIZE = 15 -- Размер плиты (15x15 кубиков для лучшей производительности)
local CUBE_SIZE = 2 -- Размер каждого кубика
local WAVE_SPEED = 2 -- Скорость волн
local MAX_HEIGHT = 4 -- Максимальная высота подъема кубиков

-- ID музыки
local MUSIC_ID = 122400781295647

-- Создаем основную часть
local plate = Instance.new("Part")
plate.Name = "AudioWavePlate"
plate.Size = Vector3.new(PLATE_SIZE * CUBE_SIZE, 1, PLATE_SIZE * CUBE_SIZE)
plate.Position = Vector3.new(0, 0, 0)
plate.Anchored = true
plate.Material = Enum.Material.Neon
plate.BrickColor = BrickColor.new("Really blue")
plate.Parent = workspace

-- Создаем музыку
local music = Instance.new("Sound")
music.SoundId = "rbxassetid://" .. MUSIC_ID
music.Volume = 0.6
music.Looped = true
music.Parent = plate

-- Массив для хранения кубиков
local cubes = {}

-- Создаем кубики
for x = 1, PLATE_SIZE do
    cubes[x] = {}
    for z = 1, PLATE_SIZE do
        local cube = Instance.new("Part")
        cube.Name = "WaveCube_" .. x .. "_" .. z
        cube.Size = Vector3.new(CUBE_SIZE - 0.1, CUBE_SIZE - 0.1, CUBE_SIZE - 0.1)
        cube.Position = Vector3.new(
            (x - PLATE_SIZE/2 - 0.5) * CUBE_SIZE,
            0.5,
            (z - PLATE_SIZE/2 - 0.5) * CUBE_SIZE
        )
        cube.Anchored = true
        cube.Material = Enum.Material.Neon
        cube.BrickColor = BrickColor.new("Cyan")
        cube.Parent = workspace
        
        cubes[x][z] = cube
    end
end

-- Функция для создания волнового эффекта
local function createWaveEffect()
    local time = tick() * WAVE_SPEED
    
    -- Симуляция громкости на основе времени
    local volume = math.abs(math.sin(time * 0.5)) * 0.7 + 0.3
    
    for x = 1, PLATE_SIZE do
        for z = 1, PLATE_SIZE do
            local cube = cubes[x][z]
            if cube then
                -- Создаем волновой паттерн
                local distance = math.sqrt((x - PLATE_SIZE/2)^2 + (z - PLATE_SIZE/2)^2)
                local wave = math.sin(time - distance * 0.3) * volume * MAX_HEIGHT
                
                -- Добавляем случайность для более естественного эффекта
                local noise = math.noise(x * 0.2, z * 0.2, time * 0.3) * volume * 1.5
                
                local targetHeight = wave + noise
                
                -- Создаем анимацию
                local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(cube, tweenInfo, {
                    Position = Vector3.new(
                        cube.Position.X,
                        math.max(0.5, targetHeight),
                        cube.Position.Z
                    )
                })
                tween:Play()
                
                -- Изменяем цвет в зависимости от высоты
                local colorIntensity = math.clamp(targetHeight / MAX_HEIGHT, 0, 1)
                local color = Color3.new(
                    0.3 + colorIntensity * 0.7,
                    0.3 + colorIntensity * 0.7,
                    0.8 + colorIntensity * 0.2
                )
                cube.BrickColor = BrickColor.new(color)
            end
        end
    end
end

-- Основной цикл обновления
RunService.Heartbeat:Connect(function()
    createWaveEffect()
end)

-- Автоматически запускаем музыку через 2 секунды
wait(2)
music:Play()
print("🎵 Audio Wave Plate создана и работает!")
print("🌊 Плита из " .. (PLATE_SIZE * PLATE_SIZE) .. " кубиков создает волны под музыку!")