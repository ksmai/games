--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Projectile = Class{__includes = GameObject}

function Projectile:init(def, x, y, direction, dungeon)
    GameObject.init(self, def, x, y)
    self.dungeon = dungeon
    self.distanceTravelled = 0
    self.direction = direction
    self.state = 'fill'
    self.stopped = false

    if self.direction == 'left' then
        self.dx = -100
        self.dy = -5
        self.ddx = 0
        self.ddy = 20
    elseif self.direction == 'right' then
        self.dx = 100
        self.dy = -5
        self.ddx = 0
        self.ddy = 20
    elseif self.direction == 'up' then
        self.dx = 0
        self.dy = -100
        self.ddx = 0
        self.ddy = 20
    elseif self.direction == 'down' then
        self.dx = 0
        self.dy = 100
        self.ddx = 0
        self.ddy = -20
    end
end

function Projectile:update(dt)
    if self.stopped then
        return
    end

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self.distanceTravelled = self.distanceTravelled + math.sqrt((self.dx * dt) ^ 2 + (self.dy * dt) ^ 2)
    self.dx = self.dx + self.ddx * dt
    self.dy = self.dy + self.ddy * dt

    if self.distanceTravelled > 4 * TILE_SIZE then
        self:stop()
    elseif self.direction == 'left' and self.x < MAP_RENDER_OFFSET_X + TILE_SIZE then
        self:stop()
    elseif self.direction == 'right' and self.x > VIRTUAL_WIDTH - MAP_RENDER_OFFSET_X - TILE_SIZE then
        self:stop()
    elseif self.direction == 'up' and self.y < MAP_RENDER_OFFSET_Y + TILE_SIZE then
        self:stop()
    elseif self.direction == 'down' and self.y > VIRTUAL_HEIGHT - MAP_RENDER_OFFSET_Y - TILE_SIZE then
        self:stop()
    else
        for k, entity in pairs(self.dungeon.currentRoom.entities) do
            if not (
                entity.x + entity.width < self.x or
                entity.x > self.x + self.width or
                entity.y + entity.height < self.y or
                entity.y > self.y + self.height
            ) then
                entity:damage(1)
                self:stop()
            end
        end
    end
end

function Projectile:stop()
    self.stopped = true
end
