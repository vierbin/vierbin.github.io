-- Музыкальная плита с волновыми эффектами в Roblox
-- Используйте через Command Bar: loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Конфигурация плиты
local PLATE_SIZE = 20 -- Размер плиты (20x20 кубиков)
local CUBE_SIZE = Vector3.new(4, 1, 4) -- Размер каждого кубика
local MUSIC_ID = "rbxassetid://122400781295647" -- ID музыки
local WAVE_SPEED = 2 -- Скорость волн
local MAX_HEIGHT = 10 -- Максимальная высота кубиков

-- Переменные для плиты
local musicPlate = {}
local cubes = {}
local sound = nil
local isPlaying = false
local waveTime = 0

-- Создание основной модели плиты
local function createPlateModel()
    local model = Instance.new("Model")
    model.Name = "MusicPlate"
    model.Parent = Workspace
    
    -- Создание базовой платформы
    local basePart = Instance.new("Part")
    basePart.Name = "BasePlate"
    basePart.Size = Vector3.new(PLATE_SIZE * CUBE_SIZE.X, 1, PLATE_SIZE * CUBE_SIZE.Z)
    basePart.Position = Vector3.new(0, -2, 0)
    basePart.Anchored = true
    basePart.Material = Enum.Material.Neon
    basePart.BrickColor = BrickColor.new("Really black")
    basePart.Parent = model
    
    return model
end

-- Создание сетки кубиков
local function createCubeGrid(model)
    cubes = {}
    
    for x = 1, PLATE_SIZE do
        cubes[x] = {}
        for z = 1, PLATE_SIZE do
            local cube = Instance.new("Part")
            cube.Name = "Cube_" .. x .. "_" .. z
            cube.Size = CUBE_SIZE
            cube.Material = Enum.Material.Neon
            cube.Anchored = true
            cube.CanCollide = false
            
            -- Позиционирование кубика
            local posX = (x - PLATE_SIZE/2 - 0.5) * CUBE_SIZE.X
            local posZ = (z - PLATE_SIZE/2 - 0.5) * CUBE_SIZE.Z
            cube.Position = Vector3.new(posX, 0, posZ)
            
            -- Начальный цвет
            cube.BrickColor = BrickColor.new("Dark blue")
            
            cube.Parent = model
            cubes[x][z] = cube
        end
    end
end

-- Создание и настройка звука
local function setupSound(model)
    sound = Instance.new("Sound")
    sound.Name = "MusicSound"
    sound.SoundId = MUSIC_ID
    sound.Volume = 0.8
    sound.Looped = true
    sound.Parent = model
    
    -- Настройка анализатора звука
    local analyzer = Instance.new("EqualizerSoundEffect")
    analyzer.HighGain = 1
    analyzer.MidGain = 1
    analyzer.LowGain = 1
    analyzer.Parent = sound
    
    return sound
end

-- Функция для получения громкости звука (симуляция)
local function getSoundLoudness()
    if sound and sound.IsPlaying then
        -- В Roblox нет прямого доступа к анализу частот,
        -- поэтому используем синусоидальную симуляцию с вариациями
        local time = tick()
        local baseLoudness = math.sin(time * 2) * 0.5 + 0.5
        local variation = math.sin(time * 5) * 0.3 + math.sin(time * 8) * 0.2
        return math.max(0, math.min(1, baseLoudness + variation))
    end
    return 0
end

-- Создание волнового эффекта
local function createWaveEffect()
    if not cubes or #cubes == 0 then return end
    
    waveTime = waveTime + RunService.Heartbeat:Wait() * WAVE_SPEED
    local loudness = getSoundLoudness()
    
    for x = 1, PLATE_SIZE do
        for z = 1, PLATE_SIZE do
            if cubes[x] and cubes[x][z] then
                local cube = cubes[x][z]
                
                -- Расчет расстояния от центра
                local centerX, centerZ = PLATE_SIZE/2, PLATE_SIZE/2
                local distance = math.sqrt((x - centerX)^2 + (z - centerZ)^2)
                
                -- Создание волнового эффекта
                local wave = math.sin(waveTime + distance * 0.5) * loudness
                local height = wave * MAX_HEIGHT
                
                -- Обновление позиции кубика
                local currentPos = cube.Position
                cube.Position = Vector3.new(currentPos.X, height, currentPos.Z)
                
                -- Изменение цвета в зависимости от высоты
                local colorIntensity = (height + MAX_HEIGHT) / (MAX_HEIGHT * 2)
                local hue = (colorIntensity * 0.7) % 1 -- Переход от синего к красному
                cube.Color = Color3.fromHSV(hue, 0.8, 0.8 + colorIntensity * 0.2)
                
                -- Добавление свечения
                if not cube:FindFirstChild("PointLight") then
                    local light = Instance.new("PointLight")
                    light.Brightness = 1
                    light.Range = 8
                    light.Color = cube.Color
                    light.Parent = cube
                else
                    cube.PointLight.Color = cube.Color
                    cube.PointLight.Brightness = colorIntensity + 0.3
                end
            end
        end
    end
end

-- Главная функция инициализации
local function initializeMusicPlate()
    -- Создание модели
    local model = createPlateModel()
    musicPlate.model = model
    
    -- Создание кубиков
    createCubeGrid(model)
    
    -- Настройка звука
    musicPlate.sound = setupSound(model)
    
    print("Музыкальная плита создана! Используйте команды:")
    print("startMusic() - запустить музыку и эффекты")
    print("stopMusic() - остановить музыку")
    print("destroyPlate() - удалить плиту")
end

-- Функции управления через Command Bar
function startMusic()
    if musicPlate.sound then
        musicPlate.sound:Play()
        isPlaying = true
        
        -- Запуск анимации
        RunService.Heartbeat:Connect(function()
            if isPlaying then
                createWaveEffect()
            end
        end)
        
        print("Музыка запущена!")
    else
        print("Ошибка: звук не найден!")
    end
end

function stopMusic()
    if musicPlate.sound then
        musicPlate.sound:Stop()
        isPlaying = false
        print("Музыка остановлена!")
    end
end

function destroyPlate()
    if musicPlate.model then
        musicPlate.model:Destroy()
        isPlaying = false
        cubes = {}
        print("Плита удалена!")
    end
end

-- Дополнительные функции настройки
function setWaveSpeed(speed)
    WAVE_SPEED = speed or 2
    print("Скорость волн установлена:", WAVE_SPEED)
end

function setMaxHeight(height)
    MAX_HEIGHT = height or 10
    print("Максимальная высота установлена:", MAX_HEIGHT)
end

function changeMusicId(newId)
    if musicPlate.sound then
        musicPlate.sound.SoundId = "rbxassetid://" .. tostring(newId)
        print("ID музыки изменен на:", newId)
    end
end

-- Автоматический запуск при загрузке
initializeMusicPlate()

-- Экспорт функций для глобального доступа
_G.startMusic = startMusic
_G.stopMusic = stopMusic
_G.destroyPlate = destroyPlate
_G.setWaveSpeed = setWaveSpeed
_G.setMaxHeight = setMaxHeight
_G.changeMusicId = changeMusicId

print("=== МУЗЫКАЛЬНАЯ ПЛИТА ГОТОВА ===")
print("Команды для Command Bar:")
print("startMusic() - запустить")
print("stopMusic() - остановить") 
print("setWaveSpeed(число) - скорость волн")
print("setMaxHeight(число) - высота волн")
print("destroyPlate() - удалить плиту")