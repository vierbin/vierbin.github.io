-- Продвинутая музыкальная плита с реалистичными эффектами
-- Используйте в Roblox Studio через Command Bar

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- Расширенная конфигурация
local CONFIG = {
    PLATE_SIZE = 25, -- Размер плиты (25x25 кубиков)
    CUBE_SIZE = Vector3.new(3, 1, 3),
    MUSIC_ID = "rbxassetid://122400781295647",
    WAVE_SPEED = 3,
    MAX_HEIGHT = 15,
    MIN_HEIGHT = -2,
    FREQUENCY_BANDS = 8, -- Количество частотных полос для симуляции
    PARTICLE_COUNT = 50, -- Количество частиц для эффектов
}

-- Глобальные переменные
local musicPlate = {
    model = nil,
    sound = nil,
    cubes = {},
    particles = {},
    connections = {},
    isActive = false,
    time = 0,
    bassHistory = {},
    trebleHistory = {},
}

-- Симуляция частотного анализа
local FrequencyAnalyzer = {}
FrequencyAnalyzer.__index = FrequencyAnalyzer

function FrequencyAnalyzer.new()
    local self = setmetatable({}, FrequencyAnalyzer)
    self.bands = {}
    self.history = {}
    self.noiseOffset = math.random() * 1000
    
    -- Инициализация частотных полос
    for i = 1, CONFIG.FREQUENCY_BANDS do
        self.bands[i] = {
            frequency = i * 0.5, -- Базовая частота
            amplitude = 0,
            phase = math.random() * math.pi * 2,
            decay = 0.95 + math.random() * 0.04,
        }
        self.history[i] = {}
    end
    
    return self
end

function FrequencyAnalyzer:update(deltaTime)
    self.noiseOffset = self.noiseOffset + deltaTime * 2
    
    for i, band in pairs(self.bands) do
        -- Создание реалистичной симуляции частотного спектра
        local noise = math.noise(self.noiseOffset, i * 0.3, 0) * 0.5 + 0.5
        local sine = math.sin(tick() * band.frequency + band.phase) * 0.3 + 0.7
        local pulse = math.sin(tick() * band.frequency * 2) * 0.2
        
        -- Комбинирование различных волн для создания музыкального эффекта
        band.amplitude = (noise * sine + pulse) * band.decay
        band.amplitude = math.max(0, math.min(1, band.amplitude))
        
        -- Сохранение истории для сглаживания
        table.insert(self.history[i], band.amplitude)
        if #self.history[i] > 10 then
            table.remove(self.history[i], 1)
        end
    end
end

function FrequencyAnalyzer:getBand(index)
    if not self.bands[index] then return 0 end
    
    -- Сглаживание по истории
    local sum = 0
    local count = #self.history[index]
    for _, value in pairs(self.history[index]) do
        sum = sum + value
    end
    
    return count > 0 and (sum / count) or 0
end

function FrequencyAnalyzer:getBass()
    return (self:getBand(1) + self:getBand(2)) / 2
end

function FrequencyAnalyzer:getTreble()
    return (self:getBand(7) + self:getBand(8)) / 2
end

function FrequencyAnalyzer:getMid()
    return (self:getBand(3) + self:getBand(4) + self:getBand(5) + self:getBand(6)) / 4
end

-- Создание основной структуры
local function createMusicPlateModel()
    local model = Instance.new("Model")
    model.Name = "AdvancedMusicPlate"
    model.Parent = Workspace
    
    -- Базовая платформа с эффектами
    local basePart = Instance.new("Part")
    basePart.Name = "BasePlate"
    basePart.Size = Vector3.new(CONFIG.PLATE_SIZE * CONFIG.CUBE_SIZE.X + 10, 2, CONFIG.PLATE_SIZE * CONFIG.CUBE_SIZE.Z + 10)
    basePart.Position = Vector3.new(0, -5, 0)
    basePart.Anchored = true
    basePart.Material = Enum.Material.Glass
    basePart.BrickColor = BrickColor.new("Really black")
    basePart.Transparency = 0.3
    basePart.Parent = model
    
    -- Добавление свечения к базе
    local baseLight = Instance.new("PointLight")
    baseLight.Brightness = 2
    baseLight.Range = 50
    baseLight.Color = Color3.fromRGB(0, 100, 255)
    baseLight.Parent = basePart
    
    return model
end

-- Создание сетки кубиков с улучшенными материалами
local function createAdvancedCubeGrid(model)
    musicPlate.cubes = {}
    
    for x = 1, CONFIG.PLATE_SIZE do
        musicPlate.cubes[x] = {}
        for z = 1, CONFIG.PLATE_SIZE do
            local cube = Instance.new("Part")
            cube.Name = "MusicCube_" .. x .. "_" .. z
            cube.Size = CONFIG.CUBE_SIZE
            cube.Material = Enum.Material.ForceField
            cube.Anchored = true
            cube.CanCollide = false
            cube.TopSurface = Enum.SurfaceType.Smooth
            cube.BottomSurface = Enum.SurfaceType.Smooth
            
            -- Позиционирование
            local posX = (x - CONFIG.PLATE_SIZE/2 - 0.5) * CONFIG.CUBE_SIZE.X
            local posZ = (z - CONFIG.PLATE_SIZE/2 - 0.5) * CONFIG.CUBE_SIZE.Z
            cube.Position = Vector3.new(posX, 0, posZ)
            
            -- Начальные свойства
            cube.BrickColor = BrickColor.new("Bright blue")
            cube.Parent = model
            
            -- Добавление света к каждому кубику
            local light = Instance.new("PointLight")
            light.Brightness = 0.5
            light.Range = 6
            light.Color = Color3.fromRGB(0, 150, 255)
            light.Parent = cube
            
            -- Сохранение исходной позиции
            cube:SetAttribute("OriginalY", 0)
            cube:SetAttribute("GridX", x)
            cube:SetAttribute("GridZ", z)
            
            musicPlate.cubes[x][z] = cube
        end
    end
end

-- Создание системы частиц
local function createParticleSystem(model)
    musicPlate.particles = {}
    
    for i = 1, CONFIG.PARTICLE_COUNT do
        local particle = Instance.new("Part")
        particle.Name = "Particle_" .. i
        particle.Size = Vector3.new(0.5, 0.5, 0.5)
        particle.Material = Enum.Material.Neon
        particle.Anchored = true
        particle.CanCollide = false
        particle.Shape = Enum.PartType.Ball
        
        -- Случайная позиция над плитой
        local randomX = (math.random() - 0.5) * CONFIG.PLATE_SIZE * CONFIG.CUBE_SIZE.X
        local randomZ = (math.random() - 0.5) * CONFIG.PLATE_SIZE * CONFIG.CUBE_SIZE.Z
        particle.Position = Vector3.new(randomX, 20 + math.random() * 10, randomZ)
        
        particle.BrickColor = BrickColor.new("Bright green")
        particle.Parent = model
        
        -- Добавление света к частице
        local light = Instance.new("PointLight")
        light.Brightness = 1
        light.Range = 4
        light.Color = Color3.fromRGB(0, 255, 100)
        light.Parent = particle
        
        musicPlate.particles[i] = particle
    end
end

-- Настройка звука с эффектами
local function setupAdvancedSound(model)
    local sound = Instance.new("Sound")
    sound.Name = "MusicSound"
    sound.SoundId = CONFIG.MUSIC_ID
    sound.Volume = 0.9
    sound.Looped = true
    sound.Parent = model
    
    -- Добавление звуковых эффектов
    local reverb = Instance.new("ReverbSoundEffect")
    reverb.DecayTime = 2
    reverb.Density = 0.7
    reverb.Diffusion = 0.8
    reverb.DryLevel = 0
    reverb.WetLevel = -6
    reverb.Parent = sound
    
    local equalizer = Instance.new("EqualizerSoundEffect")
    equalizer.HighGain = 2
    equalizer.MidGain = 1
    equalizer.LowGain = 3
    equalizer.Parent = sound
    
    return sound
end

-- Продвинутые волновые эффекты
local function updateAdvancedWaveEffects(analyzer, deltaTime)
    if not musicPlate.cubes or not musicPlate.cubes[1] then return end
    
    musicPlate.time = musicPlate.time + deltaTime * CONFIG.WAVE_SPEED
    
    -- Получение частотных данных
    local bass = analyzer:getBass()
    local mid = analyzer:getMid()
    local treble = analyzer:getTreble()
    
    -- Сохранение истории для создания следящих эффектов
    table.insert(musicPlate.bassHistory, bass)
    table.insert(musicPlate.trebleHistory, treble)
    
    if #musicPlate.bassHistory > 20 then
        table.remove(musicPlate.bassHistory, 1)
        table.remove(musicPlate.trebleHistory, 1)
    end
    
    -- Обновление кубиков
    for x = 1, CONFIG.PLATE_SIZE do
        for z = 1, CONFIG.PLATE_SIZE do
            if musicPlate.cubes[x] and musicPlate.cubes[x][z] then
                local cube = musicPlate.cubes[x][z]
                
                -- Расчет расстояния от центра
                local centerX, centerZ = CONFIG.PLATE_SIZE/2, CONFIG.PLATE_SIZE/2
                local distance = math.sqrt((x - centerX)^2 + (z - centerZ)^2)
                local maxDistance = math.sqrt((CONFIG.PLATE_SIZE/2)^2 * 2)
                local normalizedDistance = distance / maxDistance
                
                -- Создание сложных волновых паттернов
                local wavePhase = musicPlate.time + distance * 0.3
                local bassWave = math.sin(wavePhase) * bass * (1 - normalizedDistance * 0.5)
                local midWave = math.sin(wavePhase * 1.5 + math.pi/3) * mid * 0.7
                local trebleWave = math.sin(wavePhase * 2 + math.pi/2) * treble * 0.5
                
                -- Радиальные эффекты
                local radialEffect = math.sin(musicPlate.time * 2 + normalizedDistance * math.pi * 4) * 0.3
                
                -- Комбинированная высота
                local totalHeight = (bassWave + midWave + trebleWave + radialEffect) * CONFIG.MAX_HEIGHT
                totalHeight = math.max(CONFIG.MIN_HEIGHT, math.min(CONFIG.MAX_HEIGHT, totalHeight))
                
                -- Плавное обновление позиции
                local currentPos = cube.Position
                local targetY = totalHeight
                local newY = currentPos.Y + (targetY - currentPos.Y) * deltaTime * 10
                
                cube.Position = Vector3.new(currentPos.X, newY, currentPos.Z)
                
                -- Динамическое изменение цвета
                local heightRatio = (newY - CONFIG.MIN_HEIGHT) / (CONFIG.MAX_HEIGHT - CONFIG.MIN_HEIGHT)
                local hue = (bass * 0.6 + treble * 0.3 + normalizedDistance * 0.1) % 1
                local saturation = 0.8 + mid * 0.2
                local value = 0.7 + heightRatio * 0.3
                
                cube.Color = Color3.fromHSV(hue, saturation, value)
                
                -- Обновление освещения
                if cube:FindFirstChild("PointLight") then
                    local light = cube.PointLight
                    light.Color = cube.Color
                    light.Brightness = 0.5 + heightRatio * 1.5
                    light.Range = 4 + heightRatio * 8
                end
            end
        end
    end
    
    -- Обновление частиц
    for i, particle in pairs(musicPlate.particles) do
        if particle and particle.Parent then
            local currentPos = particle.Position
            
            -- Движение частиц под влиянием музыки
            local particleSpeed = 2 + bass * 8
            local angle = musicPlate.time * 0.5 + i * 0.5
            local radius = 10 + treble * 20
            
            local targetX = math.sin(angle) * radius
            local targetZ = math.cos(angle) * radius
            local targetY = 15 + mid * 15 + math.sin(musicPlate.time * 2 + i) * 5
            
            local newPos = Vector3.new(
                currentPos.X + (targetX - currentPos.X) * deltaTime * particleSpeed,
                currentPos.Y + (targetY - currentPos.Y) * deltaTime * particleSpeed,
                currentPos.Z + (targetZ - currentPos.Z) * deltaTime * particleSpeed
            )
            
            particle.Position = newPos
            
            -- Изменение цвета частиц
            local particleHue = (treble + i * 0.1) % 1
            particle.Color = Color3.fromHSV(particleHue, 0.9, 0.9)
            
            if particle:FindFirstChild("PointLight") then
                particle.PointLight.Color = particle.Color
                particle.PointLight.Brightness = 0.5 + treble * 1.5
            end
        end
    end
end

-- Главная функция инициализации
local function initializeAdvancedMusicPlate()
    -- Очистка предыдущей плиты
    if musicPlate.model then
        musicPlate.model:Destroy()
    end
    
    -- Отключение старых соединений
    for _, connection in pairs(musicPlate.connections) do
        if connection then connection:Disconnect() end
    end
    musicPlate.connections = {}
    
    -- Создание новой плиты
    musicPlate.model = createMusicPlateModel()
    createAdvancedCubeGrid(musicPlate.model)
    createParticleSystem(musicPlate.model)
    musicPlate.sound = setupAdvancedSound(musicPlate.model)
    
    print("🎵 Продвинутая музыкальная плита создана!")
    print("Доступные команды:")
    print("startAdvancedMusic() - запуск с эффектами")
    print("stopAdvancedMusic() - остановка")
    print("destroyAdvancedPlate() - удаление")
end

-- Функции управления
function startAdvancedMusic()
    if not musicPlate.sound then
        print("❌ Ошибка: звук не найден!")
        return
    end
    
    musicPlate.sound:Play()
    musicPlate.isActive = true
    
    -- Создание анализатора частот
    local analyzer = FrequencyAnalyzer.new()
    
    -- Основной цикл обновления
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        if musicPlate.isActive then
            analyzer:update(deltaTime)
            updateAdvancedWaveEffects(analyzer, deltaTime)
        end
    end)
    
    table.insert(musicPlate.connections, connection)
    
    print("🎶 Продвинутая музыка запущена с полными эффектами!")
end

function stopAdvancedMusic()
    if musicPlate.sound then
        musicPlate.sound:Stop()
    end
    
    musicPlate.isActive = false
    
    -- Отключение всех соединений
    for _, connection in pairs(musicPlate.connections) do
        if connection then connection:Disconnect() end
    end
    musicPlate.connections = {}
    
    print("⏹️ Музыка остановлена!")
end

function destroyAdvancedPlate()
    stopAdvancedMusic()
    
    if musicPlate.model then
        musicPlate.model:Destroy()
        musicPlate.model = nil
    end
    
    -- Очистка данных
    musicPlate.cubes = {}
    musicPlate.particles = {}
    musicPlate.bassHistory = {}
    musicPlate.trebleHistory = {}
    
    print("🗑️ Продвинутая плита удалена!")
end

-- Дополнительные функции настройки
function setAdvancedWaveSpeed(speed)
    CONFIG.WAVE_SPEED = speed or 3
    print("⚡ Скорость волн:", CONFIG.WAVE_SPEED)
end

function setAdvancedHeight(height)
    CONFIG.MAX_HEIGHT = height or 15
    print("📏 Максимальная высота:", CONFIG.MAX_HEIGHT)
end

function changeAdvancedMusic(newId)
    if musicPlate.sound then
        musicPlate.sound.SoundId = "rbxassetid://" .. tostring(newId)
        print("🎵 ID музыки изменен на:", newId)
    end
end

-- Автозапуск
initializeAdvancedMusicPlate()

-- Глобальный доступ
_G.startAdvancedMusic = startAdvancedMusic
_G.stopAdvancedMusic = stopAdvancedMusic
_G.destroyAdvancedPlate = destroyAdvancedPlate
_G.setAdvancedWaveSpeed = setAdvancedWaveSpeed
_G.setAdvancedHeight = setAdvancedHeight
_G.changeAdvancedMusic = changeAdvancedMusic

print("🎊 === ПРОДВИНУТАЯ МУЗЫКАЛЬНАЯ ПЛИТА ГОТОВА ===")
print("📋 Команды Command Bar:")
print("   startAdvancedMusic() - запуск")
print("   stopAdvancedMusic() - стоп")
print("   setAdvancedWaveSpeed(число) - скорость")
print("   setAdvancedHeight(число) - высота")
print("   destroyAdvancedPlate() - удалить")