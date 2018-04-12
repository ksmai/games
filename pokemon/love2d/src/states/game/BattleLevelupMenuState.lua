BattleLevelupMenuState = Class{__includes = BaseState}

function BattleLevelupMenuState:init(def)
    self.menu = Menu{
      width = 200,
      height = 120,
      x = VIRTUAL_WIDTH - 8 - 200,
      y = VIRTUAL_HEIGHT - 64 - 8 - 120,
      hideCursor = true,
      items = {
        { text = self:generateFormula('HP', def.oldHP, def.newHP) },
        { text = self:generateFormula('Attack', def.oldAttack, def.newAttack) },
        { text = self:generateFormula('Defense', def.oldDefense, def.newDefense) },
        { text = self:generateFormula('Speed', def.oldSpeed, def.newSpeed) },
      }
    }
end

function BattleLevelupMenuState:render()
    self.menu:render()
end

function BattleLevelupMenuState:generateFormula(label, oldValue, newValue)
    return label .. ': ' .. tostring(oldValue) .. ' + ' ..
      tostring(newValue - oldValue) .. ' = ' .. tostring(newValue)
end
