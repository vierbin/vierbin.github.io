-- Audio Wave Plate Script for Roblox
-- Создает плиту из кубиков, которая реагирует на громкость музыки

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- Настройки плиты
local PLATE_SIZE = 20 -- Размер плиты (20x20 кубиков)
local CUBE_SIZE = 2 -- Размер каждого кубика
local WAVE_SPEED = 2 -- Скорость волн
local MAX_HEIGHT = 5 -- Максимальная высота подъема кубиков

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
music.Volume = 0.5
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

-- Функция для получения громкости музыки
local function getMusicVolume()
    if music.IsPlaying then
        -- Используем простую симуляцию громкости на основе времени
        -- В реальном проекте здесь можно использовать более сложную логику
        return math.abs(math.sin(tick() * 2)) * 0.5 + 0.3
    end
    return 0
end

-- Функция для создания волнового эффекта
local function createWaveEffect()
    local volume = getMusicVolume()
    local time = tick() * WAVE_SPEED
    
    for x = 1, PLATE_SIZE do
        for z = 1, PLATE_SIZE do
            local cube = cubes[x][z]
            if cube then
                -- Создаем волновой паттерн
                local distance = math.sqrt((x - PLATE_SIZE/2)^2 + (z - PLATE_SIZE/2)^2)
                local wave = math.sin(time - distance * 0.5) * volume * MAX_HEIGHT
                
                -- Добавляем случайность для более естественного эффекта
                local noise = math.noise(x * 0.1, z * 0.1, time * 0.5) * volume * 2
                
                local targetHeight = wave + noise
                
                -- Создаем анимацию
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
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
                    0.5 + colorIntensity * 0.5,
                    0.5 + colorIntensity * 0.5,
                    1
                )
                cube.BrickColor = BrickColor.new(color)
            end
        end
    end
end

-- Команды для управления
local function setupCommands()
    local function onChatted(player, message)
        if player.Name == "YourUsername" then -- Замените на ваше имя пользователя
            local args = message:split(" ")
            local command = args[1]:lower()
            
            if command == "/play" then
                music:Play()
                print("Музыка запущена!")
                
            elseif command == "/stop" then
                music:Stop()
                print("Музыка остановлена!")
                
            elseif command == "/volume" then
                local vol = tonumber(args[2]) or 0.5
                music.Volume = math.clamp(vol, 0, 1)
                print("Громкость установлена на: " .. vol)
                
            elseif command == "/speed" then
                local speed = tonumber(args[2]) or 2
                WAVE_SPEED = speed
                print("Скорость волн установлена на: " .. speed)
                
            elseif command == "/height" then
                local height = tonumber(args[2]) or 5
                MAX_HEIGHT = height
                print("Максимальная высота установлена на: " .. height)
                
            elseif command == "/help" then
                print("Доступные команды:")
                print("/play - запустить музыку")
                print("/stop - остановить музыку")
                print("/volume [0-1] - установить громкость")
                print("/speed [число] - установить скорость волн")
                print("/height [число] - установить максимальную высоту")
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            onChatted(player, message)
        end)
    end)
end

-- Запускаем систему
setupCommands()

-- Основной цикл обновления
RunService.Heartbeat:Connect(function()
    createWaveEffect()
end)

-- Автоматически запускаем музыку через 3 секунды
wait(3)
music:Play()
print("Audio Wave Plate создана! Используйте команды в чате для управления.")
print("Команды: /play, /stop, /volume, /speed, /height, /help")