--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(player, dungeon)
    EntityIdleState.init(self, player)
    self.dungeon = dungeon
end

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    EntityIdleState.update(self, dt)

end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
        return
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
        return
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object.type == 'pot' then
                if math.abs(object.x + object.width / 2 - self.entity.x - self.entity.width / 2) < TILE_SIZE + 5 and math.abs(object.y + object.height / 2 - self.entity.y - self.entity.height / 2) < TILE_SIZE + 5 then
                  self.entity.stateMachine:change('pot-lift', {
                      pot = object
                  })
                  return
                end
            end
        end
    end
end
