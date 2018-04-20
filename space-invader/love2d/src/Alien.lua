Alien = Class{}

function Alien:init(params)
  self.x = params.x
  self.y = params.y
  self.frame = params.frame
  self.dead = false
  self.width = 16
  self.height = 16
  self.psystem = love.graphics.newParticleSystem(gTextures.particle, 100)
  self.psystem:setAreaSpread('normal', 2, 2)
  self.psystem:setColors(255, 255, 255, 255, 0, 0, 0, 0)
  self.psystem:setParticleLifetime(1, 3)
  self.psystem:setLinearAcceleration(-10, -10, 10, 10)
end

function Alien:update(dt)
  if self.dead then
    self.psystem:update(dt)
    return
  end
end

function Alien:render()
  if self.dead then
    love.graphics.draw(self.psystem, self.x + self.width / 2, self.y + self.height / 2)
    return
  end

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(
    gTextures.aliens,
    gFrames.aliens[self.frame],
    self.x,
    self.y
  )
end

function Alien:detectBulletHit(bullet, cb)
  local collided = detectAABBCollision(self, bullet)
  if collided then
    self.dead = true
    bullet.hit = true
    gSounds.explode:stop()
    gSounds.explode:play()
    self.psystem:emit(100)
    Timer.after(3, function()
      cb(collided)
    end)
  else
    cb(collided)
  end
  return collided
end
