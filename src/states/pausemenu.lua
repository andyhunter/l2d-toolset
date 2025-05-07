local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local PauseMenu = {}

function PauseMenu:enter()
    -- 初始化暂停菜单状态
    self.title = i18n('pausemenu.title', {default = "Game Paused"})
    self.options = {
        i18n('pausemenu.continue', {default = "Continue"}),
        i18n('pausemenu.settings', {default = "Settings"}),
        i18n('pausemenu.mainmenu', {default = "Return to Main Menu"})
    }
    self.selected = 1
end

function PauseMenu:update(dt)
    -- 暂停菜单逻辑更新（如有需要）
end

function PauseMenu:draw()
    -- 绘制前一个状态（游戏画面）
    local previousState = Gamestate.current().prev
    if previousState and previousState.draw then
        previousState:draw()
    end
    
    -- 绘制暂停菜单遮罩
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 绘制暂停菜单
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")
    
    for i, option in ipairs(self.options) do
        local color = i == self.selected and {1, 1, 0} or {1, 1, 1}
        love.graphics.setColor(unpack(color))
        love.graphics.printf(option, 0, 150 + i * 30, love.graphics.getWidth(), "center")
    end
    
    -- 恢复颜色
    love.graphics.setColor(1, 1, 1)
end

function PauseMenu:keypressed(key)
    if key == "escape" then
        -- 继续游戏
        Gamestate.pop()
    elseif key == "up" then
        self.selected = self.selected > 1 and self.selected - 1 or #self.options
    elseif key == "down" then
        self.selected = self.selected < #self.options and self.selected + 1 or 1
    elseif key == "return" or key == "space" then
        if self.selected == 1 then
            -- 继续游戏
            Gamestate.pop()
        elseif self.selected == 2 then
            -- 进入设置
            Gamestate.push(require 'src.states.settings')
        elseif self.selected == 3 then
            -- 返回主菜单
            Gamestate.switch(require 'src.states.mainmenu')
        end
    end
end

return PauseMenu