local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local Hub = {}

function Hub:enter()
    -- Initialize Hub state
    self.title = i18n('hub.title', {default = "Preparation Hub"})
    self.options = {
        i18n('hub.start_run', {default = "Start Run"}), 
        i18n('hub.exit', {default = "Return to Main Menu"})
    }
    self.selected = 1
    self.buffsSelected = false
    
    -- Available buffs/items the player can choose from
    self.buffs = {
        {name = i18n('hub.buffs.health_up.name', {default = "Health Up"}), 
         description = i18n('hub.buffs.health_up.desc', {default = "Increases max health by 25%"}), 
         selected = false},
        {name = i18n('hub.buffs.attack_speed.name', {default = "Attack Speed"}), 
         description = i18n('hub.buffs.attack_speed.desc', {default = "Increases attack speed by 15%"}), 
         selected = false},
        {name = i18n('hub.buffs.critical_hit.name', {default = "Critical Hit"}), 
         description = i18n('hub.buffs.critical_hit.desc', {default = "10% chance to deal double damage"}), 
         selected = false},
        {name = i18n('hub.buffs.regeneration.name', {default = "Regeneration"}), 
         description = i18n('hub.buffs.regeneration.desc', {default = "Slowly recover health over time"}), 
         selected = false}
    }
    
    -- Player can only select up to this many buffs
    self.maxBuffsAllowed = 2
    self.selectedBuffCount = 0
    
    -- Currently highlighted buff (for navigation)
    self.currentBuff = 1
end

function Hub:update(dt)
    -- Update hub logic if needed
end

function Hub:draw()
    -- Draw hub interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.title, 0, 50, love.graphics.getWidth(), "center")
    
    -- Draw buff selection area
    love.graphics.printf(i18n('hub.select_buffs', {self.selectedBuffCount, self.maxBuffsAllowed, 
                              default = "Select Buffs: (%d/%d)"}), 
                        100, 100, 300, "left")
    
    for i, buff in ipairs(self.buffs) do
        local y = 130 + (i - 1) * 60
        
        -- Draw buff selection box
        if i == self.currentBuff then
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("line", 95, y - 5, 500, 50)
        elseif buff.selected then
            love.graphics.setColor(0, 1, 0, 0.3)
            love.graphics.rectangle("fill", 95, y - 5, 500, 50)
        end
        
        -- Draw buff name and description
        love.graphics.setColor(buff.selected and {0, 1, 0} or {1, 1, 1})
        love.graphics.printf(buff.name, 100, y, 300, "left")
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(buff.description, 100, y + 20, 400, "left")
    end
    
    -- Draw options at bottom
    love.graphics.setColor(1, 1, 1)
    for i, option in ipairs(self.options) do
        local color = i == self.selected and {1, 1, 0} or {1, 1, 1}
        love.graphics.setColor(unpack(color))
        love.graphics.printf(option, 0, love.graphics.getHeight() - 100 + i * 30, love.graphics.getWidth(), "center")
    end
    
    -- Instruction text
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(i18n('hub.instructions', 
                        {default = "Use arrow keys to navigate, SPACE to select buffs"}), 
                        0, love.graphics.getHeight() - 40, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
end

function Hub:keypressed(key)
    if key == "up" then
        if self.selected == 1 then
            -- Navigate through buffs
            self.currentBuff = self.currentBuff > 1 and self.currentBuff - 1 or #self.buffs
        else
            self.selected = self.selected - 1
        end
    elseif key == "down" then
        if self.selected == 1 then
            -- Navigate through buffs
            self.currentBuff = self.currentBuff < #self.buffs and self.currentBuff + 1 or 1
        else
            self.selected = self.selected < #self.options and self.selected + 1 or 1
        end
    elseif key == "return" or key == "space" then
        if self.selected == 1 then
            if key == "space" then
                -- Toggle buff selection
                local buff = self.buffs[self.currentBuff]
                if buff.selected then
                    -- Deselect buff
                    buff.selected = false
                    self.selectedBuffCount = self.selectedBuffCount - 1
                elseif self.selectedBuffCount < self.maxBuffsAllowed then
                    -- Select buff if under max limit
                    buff.selected = true
                    self.selectedBuffCount = self.selectedBuffCount + 1
                end
            elseif key == "return" then
                -- Begin the run with selected buffs
                local selectedBuffs = {}
                for _, buff in ipairs(self.buffs) do
                    if buff.selected then
                        table.insert(selectedBuffs, buff)
                    end
                end
                
                -- Start the run with the selected buffs
                Gamestate.switch(require 'src.states.run', {buffs = selectedBuffs})
            end
        elseif self.selected == 2 then
            -- Return to main menu
            Gamestate.switch(require 'src.states.mainmenu')
        end
    elseif key == "escape" then
        -- Return to main menu
        Gamestate.switch(require 'src.states.mainmenu')
    end
end

return Hub