Ship = Class{}

function Ship:init(params)
  self.x = params.x
  self.y = params.y
  self.frame = params.frame
  self.speed = params.speed
  self.shootCooldown = params.shootCooldown
  self.shootSpeed = params.shootSpeed
  self.dx = 0
  self.cooldown = 0
  self.width = 16
  self.height = 16
  self.dead = false
  self.psystem = love.graphics.newParticleSystem(gTextures.particle, 100)
  self.psystem:setAreaSpread('normal', 2, 2)
  self.psystem:setColors(255, 255, 255, 255, 0, 0, 0, 0)
  self.psystem:setParticleLifetime(1, 3)
  self.psystem:setLinearAcceleration(-10, -10, 10, 10)
end

function Ship:update(dt)
  if self.dead then
    self.psystem:update(dt)
    return
  end

  if love.keyboard.isDown('left') then
    self.dx = -self.speed
  elseif love.keyboard.isDown('right') then
    self.dx = self.speed
  else
    self.dx = 0
  end

  self.x = math.min(VIRTUAL_WIDTH - self.width, math.max(0, self.x + self.dx * dt))
  self.cooldown = math.max(0, self.cooldown - dt)

  if love.keyboard.wasPressed('space') and self.cooldown <= 0 then
    self.cooldown = self.shootCooldown
    Event.dispatch('shipShoot', {
      x = self.x + self.width / 2,
      y = self.y,
      dy = -self.shootSpeed,
    })
    gSounds['shoot']:stop()
    gSounds['shoot']:play()
  end
end

function Ship:render()
  if self.dead then
    love.graphics.draw(self.psystem, self.x + self.width / 2, self.y + self.height / 2)
    return
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(
    gTextures.ships,
    gFrames.ships[self.frame],
    math.floor(self.x),
    self.y
  )
end

function Ship:detectBulletHit(bullet)
  return detectAABBCollision(self, bullet)
end

function Ship:getHit(cb)
  gSounds.explode:stop()
  gSounds.explode:play()
  self.dead = true
  self.psystem:emit(100)
  Timer.after(5, cb)
end
