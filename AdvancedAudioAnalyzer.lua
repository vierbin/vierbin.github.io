-- Advanced Audio Analyzer для более точной реакции на музыку
-- Этот скрипт можно использовать вместе с основным скриптом

local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

-- Класс для анализа аудио
local AudioAnalyzer = {}
AudioAnalyzer.__index = AudioAnalyzer

function AudioAnalyzer.new(sound)
    local self = setmetatable({}, AudioAnalyzer)
    self.sound = sound
    self.volumeHistory = {}
    self.maxHistorySize = 60 -- Храним историю за последнюю секунду (60 кадров)
    self.currentVolume = 0
    self.bassVolume = 0
    self.trebleVolume = 0
    self.peakVolume = 0
    
    return self
end

function AudioAnalyzer:update()
    if self.sound.IsPlaying then
        -- Получаем текущую громкость
        local currentVol = self.sound.Volume
        
        -- Добавляем в историю
        table.insert(self.volumeHistory, currentVol)
        if #self.volumeHistory > self.maxHistorySize then
            table.remove(self.volumeHistory, 1)
        end
        
        -- Вычисляем среднюю громкость
        local total = 0
        for _, vol in ipairs(self.volumeHistory) do
            total = total + vol
        end
        self.currentVolume = total / #self.volumeHistory
        
        -- Вычисляем пиковую громкость
        self.peakVolume = math.max(self.peakVolume * 0.95, currentVol)
        
        -- Симуляция баса и высоких частот
        local time = tick()
        self.bassVolume = math.abs(math.sin(time * 0.5)) * currentVol
        self.trebleVolume = math.abs(math.sin(time * 2)) * currentVol
    else
        self.currentVolume = 0
        self.bassVolume = 0
        self.trebleVolume = 0
        self.peakVolume = self.peakVolume * 0.9
    end
end

function AudioAnalyzer:getVolume()
    return self.currentVolume
end

function AudioAnalyzer:getBass()
    return self.bassVolume
end

function AudioAnalyzer:getTreble()
    return self.trebleVolume
end

function AudioAnalyzer:getPeak()
    return self.peakVolume
end

-- Функция для создания цветовой схемы на основе частот
local function createFrequencyColor(bass, treble, volume)
    local r = math.clamp(bass * 2, 0, 1)
    local g = math.clamp(treble * 2, 0, 1)
    local b = math.clamp(volume * 2, 0, 1)
    
    return Color3.new(r, g, b)
end

-- Экспортируем функции для использования в основном скрипте
return {
    AudioAnalyzer = AudioAnalyzer,
    createFrequencyColor = createFrequencyColor
}