PlayerPotLiftState = Class{__includes = EntityIdleState}

function PlayerPotLiftState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    self.entity:changeAnimation('pot-lift-' .. self.entity.direction)
end

function PlayerPotLiftState:enter(params)
    self.pot = params.pot
    self.pot.x = self.entity.x
    self.pot.y = self.entity.y - self.pot.height / 2
    self.pot.solid = false
    self.pot.state = 'fill'
end

function PlayerPotLiftState:exit()
    self.pot.solid = true
    self.pot.state = 'rest'
end

function PlayerPotLiftState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        projectile = Projectile(
            GAME_OBJECT_DEFS['pot'],
            self.pot.x,
            self.pot.y,
            self.entity.direction,
            self.dungeon
        )
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object == self.pot then
                table.remove(self.dungeon.currentRoom.objects, k)
                break
            end
        end
        table.insert(self.dungeon.currentRoom.projectiles, projectile)
        self.entity.stateMachine:change('idle')
        return
    end

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk', { pot = self.pot })
    end
end

function PlayerPotLiftState:render()
    EntityIdleState.render(self)
    self.pot:render(self.dungeon.currentRoom.adjacentOffsetX, self.dungeon.currentRoom.adjacentOffsetY)
end
