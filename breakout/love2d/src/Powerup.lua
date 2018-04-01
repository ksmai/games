Powerup = Class{}

function Powerup:init()
  self.width = 16
  self.height = 16
  self.padding = 16
  self.y = 0 - self.height
  self.x = math.random(self.padding, VIRTUAL_WIDTH - self.padding - self.width)
  self.dy = math.random(10, 30)
  self.visible = true
end

function Powerup:update(dt)
  self.y = self.y + self.dy * dt

  if self.y > VIRTUAL_HEIGHT then
    self.visible = false
  end
end

function Powerup:collides(target)
  if self.x > target.x + target.width then
    return false
  elseif self.x + self.width < target.x then
    return false
  elseif self.y > target.y + target.height then
    return false
  elseif self.y + self.height < target.y then
    return false
  end
  return true
end

function Powerup:hit()
  self.visible = false
  gSounds['select']:stop()
  gSounds['select']:play()
end

function Powerup:render()
  if self.visible then
    love.graphics.draw(gTextures.main, gFrames.powerups[1], self.x, self.y)
  end
end
