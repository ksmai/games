AlienArmy = Class{}

local HORIZONTAL_SPACE = 5

function AlienArmy:init(params)
  self.x = params.x
  self.y = params.y
  self.leftBound = params.leftBound
  self.rightBound = params.rightBound
  self.bottomBound = params.bottomBound
  self.rows = params.rows
  self.cols = params.cols
  self.shootRate = params.shootRate
  self.shootSpeed = params.shootSpeed
  self.moveThreshold = params.moveThreshold
  self.moveTimer = 0
  self.movingRight = true
  self.movingDown = false
  self:generate(self.rows, self.cols)
  self.width = self.cols * 16 + (self.cols - 1) * HORIZONTAL_SPACE
  self.remainingAliens = self.rows * self.cols
end

function AlienArmy:update(dt)
  self.moveTimer = self.moveTimer + dt
  while self.moveTimer > self.moveThreshold do
    self.moveTimer = self.moveTimer - self.moveThreshold

    if self.movingDown then
      self.y = self.y + 10
      self.movingDown = not self.movingDown
      local bottomAlien = self:getBottomAlien()
      if bottomAlien and bottomAlien.y + bottomAlien.height > self.bottomBound then
        self.y = self.y + self.bottomBound - bottomAlien.y - bottomAlien.height
      end
    elseif self.movingRight then
      self.x = self.x + 5
      if self.x + self.width >= self.rightBound then
        self.movingRight = not self.movingRight
        self.movingDown = not self.movingDown
        self.x = self.rightBound - self.width
      end
    else
      self.x = self.x - 5
      if self.x <= self.leftBound then
        self.movingRight = not self.movingRight
        self.movingDown = not self.movingDown
        self.x = self.leftBound
      end
    end
  end

  for y, row in pairs(self.aliens) do
    for x, alien in pairs(row) do
      alien.x = (x - 1) * (alien.width + HORIZONTAL_SPACE) + self.x
      alien.y = (y - 1) * alien.height + self.y
      alien:update(dt)
    end
  end

  self:generateShoots(dt)
end

function AlienArmy:render()
  for y, row in pairs(self.aliens) do
    for x, alien in pairs(row) do
      alien:render()
    end
  end
end

function AlienArmy:generate(rows, cols)
  self.aliens = {}
  local usedFrames = {}
  for y = 1, rows do
    local row = {}
    local frame
    table.insert(self.aliens, row)
    repeat
      frame = math.random(#gFrames.aliens)
    until not usedFrames[frame]
    usedFrames[frame] = true
    for x = 1, cols do
      table.insert(row, Alien({
        x = (x - 1) * (16 + 5) + self.x,
        y = (y - 1) * 16 + self.y,
        frame = frame,
      }))
    end
  end
end

function AlienArmy:getBottomAliens()
  local bottomAliens = {}
  for x = 1, self.cols do
    for y = self.rows, 1, -1 do
      local alien = self.aliens[y][x]
      if not alien.dead then
        table.insert(bottomAliens, alien)
        break
      end
    end
  end

  return bottomAliens
end

function AlienArmy:generateShoots(dt)
  for k, alien in pairs(self:getBottomAliens()) do
    if math.random() < self.shootRate * dt / 100 then
      Event.dispatch('alienShoot', {
        x = alien.x + alien.width / 2,
        y = alien.y + alien.height,
        dy = self.shootSpeed,
      })
      gSounds['shoot2']:setVolume(0.3)
      gSounds['shoot2']:stop()
      gSounds['shoot2']:play()
    end
  end
end

function AlienArmy:detectBulletHit(bullet)
  for y = #self.aliens, 1, -1 do
    for x, alien in pairs(self.aliens[y]) do
      if not alien.dead and alien:detectBulletHit(bullet, function(hit)
        if hit then
          self.remainingAliens = self.remainingAliens - 1
          if self.remainingAliens == 0 then
            Event.dispatch('allAliensDead')
          end
        end
      end) then
        return alien
      end
    end
  end

  return nil
end

function AlienArmy:getBottomAlien()
  for y = #self.aliens, 1, -1 do
    for x, alien in pairs(self.aliens[y]) do
      if not alien.dead then
        return alien
      end
    end
  end

  return nil
end
