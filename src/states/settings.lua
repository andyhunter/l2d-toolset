local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local Config = require 'src.utils.config'
local Audio = require 'src.utils.audio'

local Settings = {}

function Settings:enter(previous)
    -- 保存前一个状态用于返回
    self.previous = previous
    
    -- 初始化设置菜单状态
    self.title = i18n('settings.title', {default = "Settings"})
    
    -- 读取当前设置
    self:loadCurrentSettings()
    
    -- 可用语言
    self.languages = {
        {code = "en", name = "English"},
        {code = "zh-CN", name = "中文"}
    }
    
    -- 找到当前语言
    self.currentLanguageIndex = 1
    local currentLocale = i18n.getLocale()
    for i, lang in ipairs(self.languages) do
        if lang.code == currentLocale then
            self.currentLanguageIndex = i
            break
        end
    end
    
    -- 设置类别
    self.categories = {
        "audio", "graphics", "game", "input"
    }
    self.currentCategory = 1
    
    -- 每个类别的设置选项
    self.categoryOptions = {
        audio = {
            {name = "masterVolume", min = 0, max = 1, step = 0.1},
            {name = "musicVolume", min = 0, max = 1, step = 0.1},
            {name = "sfxVolume", min = 0, max = 1, step = 0.1}
        },
        graphics = {
            {name = "fullscreen", type = "toggle"},
            {name = "vsync", type = "toggle"},
            {name = "showFps", type = "toggle"}
        },
        game = {
            {name = "language", type = "list", options = self.languages, valueField = "code", displayField = "name"},
            {name = "difficulty", type = "list", options = {"easy", "normal", "hard"}},
            {name = "tutorialEnabled", type = "toggle"}
        },
        input = {
            {name = "remapControls", type = "action", action = function() self:openRemapControls() end}
        }
    }
    
    -- 当前选中的选项
    self.selectedOption = 1
    
    -- UI元素大小和位置
    self.ui = {
        padding = 20,
        optionHeight = 30,
        categoryWidth = 150
    }
    
    -- 是否处于重映射模式
    self.isRemapping = false
    self.remappingAction = nil
    
    -- 初始更新选项文本
    self:updateOptionsText()
    
    -- 播放UI音效示例 (在修改音量时使用)
    self.uiSoundPlayed = false
end

function Settings:loadCurrentSettings()
    -- 从配置管理器加载设置
    self.settings = {}
    
    -- 音频设置
    self.settings.audio = {
        masterVolume = Config.get("audio", "masterVolume", 1.0),
        musicVolume = Config.get("audio", "musicVolume", 0.7),
        sfxVolume = Config.get("audio", "sfxVolume", 0.8)
    }
    
    -- 图形设置
    self.settings.graphics = {
        fullscreen = Config.get("graphics", "fullscreen", false),
        vsync = Config.get("graphics", "vsync", true),
        showFps = Config.get("graphics", "showFps", false)
    }
    
    -- 游戏设置
    self.settings.game = {
        language = Config.get("game", "language", "en"),
        difficulty = Config.get("game", "difficulty", "normal"),
        tutorialEnabled = Config.get("game", "tutorialEnabled", true)
    }
    
    -- 输入设置保留空
    self.settings.input = {}
end

-- 生成设置项的显示名称
function Settings:getOptionDisplayName(category, optionName)
    local translationKey = "settings." .. category .. "." .. optionName
    return i18n(translationKey, {default = optionName:gsub("^%l", string.upper)})
end

-- 生成设置项的显示值
function Settings:getOptionDisplayValue(category, option)
    local value = self.settings[category][option.name]
    
    if option.type == "toggle" then
        return value and i18n('settings.yes', {default = "Yes"}) or i18n('settings.no', {default = "No"})
    elseif option.type == "list" then
        if option.options then
            if type(option.options) == "table" and option.options[1] and type(option.options[1]) == "table" then
                -- 复杂选项列表 (有code和name的表)
                for _, opt in ipairs(option.options) do
                    if opt[option.valueField] == value then
                        return opt[option.displayField]
                    end
                end
            else
                -- 简单选项列表 (字符串数组)
                for _, opt in ipairs(option.options) do
                    if opt == value then
                        local translationKey = "settings." .. category .. "." .. option.name .. "." .. opt
                        return i18n(translationKey, {default = opt:gsub("^%l", string.upper)})
                    end
                end
            end
        end
        return tostring(value)
    elseif option.type == "action" then
        local translationKey = "settings." .. category .. "." .. option.name .. ".label"
        return i18n(translationKey, {default = "Press Enter"})
    else
        -- 数值型选项
        if option.name:find("Volume") then
            return math.floor(value * 100) .. "%"
        else
            return tostring(value)
        end
    end
end

function Settings:updateOptionsText()
    -- 设置类别标题文本
    self.categoryTitles = {}
    for i, category in ipairs(self.categories) do
        local translationKey = "settings.categories." .. category
        self.categoryTitles[i] = i18n(translationKey, {default = category:gsub("^%l", string.upper)})
    end
    
    -- 当前类别的选项
    local currentCategory = self.categories[self.currentCategory]
    self.currentOptions = {}
    
    for i, option in ipairs(self.categoryOptions[currentCategory]) do
        local displayName = self:getOptionDisplayName(currentCategory, option.name)
        local displayValue = self:getOptionDisplayValue(currentCategory, option)
        self.currentOptions[i] = displayName .. ": " .. displayValue
    end
    
    -- 添加"返回"选项
    table.insert(self.currentOptions, i18n('settings.back', {default = "Back"}))
end

function Settings:update(dt)
    -- 更新选项文字，以防语言变化
    self:updateOptionsText()
end

function Settings:draw()
    -- 绘制背景
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 绘制标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.title, 0, self.ui.padding, love.graphics.getWidth(), "center")
    
    -- 绘制类别列表 (左侧)
    local categoryX = self.ui.padding
    local categoryY = self.ui.padding * 3
    
    for i, title in ipairs(self.categoryTitles) do
        local color = i == self.currentCategory and {1, 1, 0} or {0.7, 0.7, 0.7}
        love.graphics.setColor(unpack(color))
        love.graphics.printf(title, categoryX, categoryY + (i-1) * self.ui.optionHeight, self.ui.categoryWidth, "left")
    end
    
    -- 绘制分隔线
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.line(categoryX + self.ui.categoryWidth + self.ui.padding, self.ui.padding * 2, 
                      categoryX + self.ui.categoryWidth + self.ui.padding, love.graphics.getHeight() - self.ui.padding)
    
    -- 绘制选项 (右侧)
    local optionsX = categoryX + self.ui.categoryWidth + self.ui.padding * 2
    local optionsY = categoryY
    
    love.graphics.setColor(1, 1, 1)
    for i, option in ipairs(self.currentOptions) do
        local color = i == self.selectedOption and {1, 1, 0} or {1, 1, 1}
        love.graphics.setColor(unpack(color))
        love.graphics.printf(option, optionsX, optionsY + (i-1) * self.ui.optionHeight, 
                           love.graphics.getWidth() - optionsX - self.ui.padding, "left")
    end
    
    -- 如果正在重映射，显示提示
    if self.isRemapping then
        love.graphics.setColor(0, 0, 0, 0.9)
        local w, h = 400, 100
        local x = (love.graphics.getWidth() - w) / 2
        local y = (love.graphics.getHeight() - h) / 2
        
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, w, h)
        
        local message = i18n('settings.remapPrompt', {action = self.remappingAction, default = "Press a key for: " .. self.remappingAction})
        love.graphics.printf(message, x, y + h/3, w, "center")
    end
    
    -- 恢复颜色
    love.graphics.setColor(1, 1, 1)
    
    -- 绘制提示
    local helpText = i18n('settings.help', {default = "↑↓: Navigate  ←→: Change Value  Enter: Select  Esc: Back"})
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(helpText, 0, love.graphics.getHeight() - self.ui.padding * 2, love.graphics.getWidth(), "center")
end

function Settings:returnToPrevious()
    -- 保存设置
    Config.save()
    
    -- 返回上一个状态
    Gamestate.pop()
end

function Settings:openRemapControls()
    -- 添加重映射控制的代码
    -- 这里只是一个简单示例，可以展开为更复杂的重映射界面
    self.isRemapping = true
    self.remappingAction = "jump" -- 示例：重映射跳跃键
end

function Settings:keypressed(key)
    if self.isRemapping then
        -- 处理重映射模式
        if key ~= "escape" then
            local Input = require 'src.utils.input'
            Input.remapControl(self.remappingAction, "key", key)
            -- 播放确认音效
            Audio.playSound("assets/audio/sfx/confirm.wav")
        end
        self.isRemapping = false
        self.remappingAction = nil
        return
    end

    if key == "escape" then
        -- 返回上一个状态，保存设置
        self:returnToPrevious()
    elseif key == "up" then
        -- 向上导航选项
        self.selectedOption = self.selectedOption > 1 and self.selectedOption - 1 or #self.currentOptions
    elseif key == "down" then
        -- 向下导航选项
        self.selectedOption = self.selectedOption < #self.currentOptions and self.selectedOption + 1 or 1
    elseif key == "left" or key == "right" then
        -- 如果是最后一个选项(返回)，则忽略左右键
        if self.selectedOption == #self.currentOptions then
            return
        end
        
        -- 更改当前选项的值
        self:changeOptionValue(key == "right" and 1 or -1)

        -- 播放UI音效作为示例
        if not self.uiSoundPlayed then
            Audio.playSound("assets/audio/sfx/click.wav")
            self.uiSoundPlayed = true
        end
        
    elseif key == "tab" then
        -- 切换设置类别
        self.currentCategory = self.currentCategory % #self.categories + 1
        self.selectedOption = 1
        self:updateOptionsText()
    elseif key == "return" or key == "space" then
        -- 处理选项选择
        if self.selectedOption == #self.currentOptions then
            -- 选择了"返回"选项
            self:returnToPrevious()
        else
            -- 处理特定类型的选项
            local currentCategory = self.categories[self.currentCategory]
            local option = self.categoryOptions[currentCategory][self.selectedOption]
            
            if option.type == "toggle" then
                -- 切换布尔值
                self:changeOptionValue(1)
            elseif option.type == "action" and option.action then
                -- 执行动作函数
                option.action()
            elseif option.type == "list" then
                -- 切换列表值
                self:changeOptionValue(1)
            end
        end
    end
    
    -- 更新选项文本
    self:updateOptionsText()
end

function Settings:changeOptionValue(direction)
    local currentCategory = self.categories[self.currentCategory]
    local option = self.categoryOptions[currentCategory][self.selectedOption]
    local value = self.settings[currentCategory][option.name]
    
    if option.type == "toggle" then
        -- 切换布尔值
        value = not value
    elseif option.type == "list" then
        -- 处理列表选项
        if type(option.options) == "table" then
            if type(option.options[1]) == "table" then
                -- 复杂选项 (如语言列表)
                local currentIndex = 1
                for i, opt in ipairs(option.options) do
                    if opt[option.valueField] == value then
                        currentIndex = i
                        break
                    end
                end
                
                currentIndex = currentIndex + direction
                if currentIndex < 1 then currentIndex = #option.options end
                if currentIndex > #option.options then currentIndex = 1 end
                
                value = option.options[currentIndex][option.valueField]
            else
                -- 简单选项列表 (字符串数组)
                local currentIndex = 1
                for i, opt in ipairs(option.options) do
                    if opt == value then
                        currentIndex = i
                        break
                    end
                end
                
                currentIndex = currentIndex + direction
                if currentIndex < 1 then currentIndex = #option.options end
                if currentIndex > #option.options then currentIndex = 1 end
                
                value = option.options[currentIndex]
            end
        end
    else
        -- 数值型选项
        value = value + (option.step or 0.1) * direction
        if option.min ~= nil then value = math.max(option.min, value) end
        if option.max ~= nil then value = math.min(option.max, value) end
        
        -- 对于音量，确保小数点后只有一位
        if option.name:find("Volume") then
            value = math.floor(value * 10 + 0.5) / 10
        end
    end
    
    -- 更新设置
    self.settings[currentCategory][option.name] = value
    Config.set(currentCategory, option.name, value)
    
    -- 应用改变的设置
    self:applyChangedSetting(currentCategory, option.name, value)
end

function Settings:applyChangedSetting(category, name, value)
    if category == "audio" then
        if name == "masterVolume" then
            Audio.setMasterVolume(value)
        elseif name == "musicVolume" then
            Audio.setMusicVolume(value)
        elseif name == "sfxVolume" then
            Audio.setSfxVolume(value)
        end
    elseif category == "graphics" then
        if name == "fullscreen" then
            love.window.setFullscreen(value)
        elseif name == "vsync" then
            love.window.setVSync(value and 1 or 0)
        end
    elseif category == "game" then
        if name == "language" then
            i18n.setLocale(value)
            if GAME and GAME.setLanguage then
                GAME.setLanguage(value)
            end
        end
    end
    
    -- 立即应用所有设置
    Config.apply()
    
    -- 为了确保设置得到保存，我们立即保存配置
    Config.save()
end

return Settings