local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local GameOver = {}

function GameOver:enter(from, scoreData)
    -- Extract the score from the table or use 0 if not available
    self.score = (scoreData and scoreData.score) or 0
    self.title = i18n('gameover.title', {default = "Game Over"})
    self.options = {
        i18n('gameover.return_to_hub', {default = "Return to Hub"}), 
        i18n('gameover.try_again', {default = "Try Again"})
    }
    self.selected = 1
end

function GameOver:update(dt)
    -- 游戏结束界面逻辑更新（如有需要）
end

function GameOver:draw()
    -- 绘制背景
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 绘制标题
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")
    
    -- 绘制分数（如果有的话）
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(i18n('gameover.score', {self.score, default = "Score: %d"}), 0, 150, love.graphics.getWidth(), "center")
    
    -- 绘制选项
    for i, option in ipairs(self.options) do
        local color = i == self.selected and {1, 1, 0} or {1, 1, 1}
        love.graphics.setColor(unpack(color))
        love.graphics.printf(option, 0, 200 + i * 30, love.graphics.getWidth(), "center")
    end
    
    -- 恢复颜色
    love.graphics.setColor(1, 1, 1)
end

function GameOver:keypressed(key)
    if key == "up" then
        self.selected = self.selected > 1 and self.selected - 1 or #self.options
    elseif key == "down" then
        self.selected = self.selected < #self.options and self.selected + 1 or 1
    elseif key == "return" or key == "space" then
        if self.selected == 1 then
            -- 返回大厅
            Gamestate.switch(require 'src.states.hub')
        elseif self.selected == 2 then
            -- 重新开始游戏
            Gamestate.switch(require 'src.states.run')
        end
    end
end

return GameOver