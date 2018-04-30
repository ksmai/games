PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.started = false
  self.boxOffset = -VIRTUAL_HEIGHT

  gSounds.random:stop()
  gSounds.random:play()
  Timer.tween(0.5, {
    [self] = { boxOffset = 0 },
  }):finish(function()
    Timer.after(2, function()
      Timer.tween(0.5, {
        [self] = { boxOffset = VIRTUAL_HEIGHT },
      }):finish(function()
        self.started = true
      end)
    end)
  end)

  self.shipBullets = {}
  self.alienBullets = {}
  self.eventHandlers = {}
end

function PlayState:enter(params)
  self.highscore = params.highscore
  self.score = params.score
  self.level = params.level
  self.lives = params.lives

  self.alienArmy = params.alienArmy or AlienArmy({
    x = 14,
    y = 16,
    leftBound = 14,
    rightBound = VIRTUAL_WIDTH - 14,
    bottomBound = VIRTUAL_HEIGHT - 10 - 16 - 10,
    moveThreshold = 1.5 - 1.2 * (1 - math.exp(1 - self.level)),
    rows = 5,
    cols = 10,
    shootRate = math.min(50, 10 + (self.level - 1) * 5),
    shootSpeed = 24,
  })

  self.ship = Ship({
    x = VIRTUAL_WIDTH / 2 - 16 / 2,
    y = VIRTUAL_HEIGHT - 10 - 16,
    frame = 42,
    speed = 48,
    shootCooldown = 0.8,
    shootSpeed = 48,
  })

  table.insert(self.eventHandlers, Event.on('allAliensDead', function()
    if self.started then
      gStateMachine:change('play', {
        level = self.level + 1,
        score = self.score,
        highscore = self.highscore,
        lives = self.lives,
      })
      self.started = false
    end
    return false
  end))
  table.insert(self.eventHandlers,   Event.on('shipShoot', function(params)
    bullet = Bullet({
      x = params.x,
      y = params.y,
      dy = params.dy,
      width = 1,
      height = 4,
    })
    table.insert(self.shipBullets, bullet)
    return false
  end))
  table.insert(self.eventHandlers, Event.on('alienShoot', function(params)
    bullet = Bullet({
      x = params.x,
      y = params.y,
      dy = params.dy,
      width = 1,
      height = 4,
    })
    table.insert(self.alienBullets, bullet)
    return false
  end))
end

function PlayState:exit()
  for k, handler in pairs(self.eventHandlers) do
    handler:remove()
  end
end

function PlayState:update(dt)
  if not self.started then
    return
  end

  self.alienArmy:update(dt)
  for k, bullet in pairs(self.alienBullets) do
    bullet:update(dt)
    if not bullet.hit and not self.ship.dead and self.ship:detectBulletHit(bullet) then
      self.lives = self.lives - 1
      self.ship:getHit(function()
        if self.lives > 0 then
          if self.started then
            gStateMachine:change('play', {
              level = self.level,
              score = self.score,
              highscore = self.highscore,
              lives = self.lives,
              alienArmy = self.alienArmy,
            })
            self.started = false
          end
        else
          if self.started then
            gStateMachine:change('score', {
              score = self.score,
              highscore = self.highscore,
            })
            self.started = false
          end
        end
      end)
    end
  end
  for k, bullet in pairs(self.shipBullets) do
    bullet:update(dt)
    if not bullet.hit and not self.ship.dead then
      if self.alienArmy:detectBulletHit(bullet) then
        self.score = self.score + self.level * 100 + 1000
      end
    end
  end

  self.ship:update(dt)
  for i = #self.shipBullets, 1, -1 do
    bullet = self.shipBullets[i]
    if bullet.dy < 0 and bullet.y + bullet.height < 0 then
      table.remove(self.shipBullets, i)
    elseif bullet.dy > 0 and bullet.y > VIRTUAL_HEIGHT then
      table.remove(self.shipBullets, i)
    end
  end
  for i = #self.alienBullets, 1, -1 do
    bullet = self.alienBullets[i]
    if bullet.dy < 0 and bullet.y + bullet.height < 0 then
      table.remove(self.alienBullets, i)
    elseif bullet.dy > 0 and bullet.y > VIRTUAL_HEIGHT then
      table.remove(self.alienBullets, i)
    end
  end
end

function PlayState:render()
  if not self.started then
    local levelText = 'Level : ' .. tostring(self.level)
    local lifeText = 'Lives : ' .. tostring(self.lives)
    local levelWidth = gFonts['medium']:getWidth(levelText)
    local lifeWidth = gFonts['medium']:getWidth(lifeText)
    local contentWidth = math.max(levelWidth, lifeWidth)
    local contentHeight = gFonts['medium']:getHeight() * 2
    local verticalPadding = 5
    local horizontalPadding = 10
    local boxWidth = contentWidth + 2 * horizontalPadding
    local boxHeight = contentHeight + 2 * verticalPadding

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle(
      'fill',
      VIRTUAL_WIDTH / 2 - boxWidth / 2,
      VIRTUAL_HEIGHT / 2 - boxHeight / 2 + self.boxOffset,
      boxWidth,
      boxHeight,
      4
    )
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.print(
      levelText, 
      VIRTUAL_WIDTH / 2 - boxWidth / 2 + horizontalPadding,
      VIRTUAL_HEIGHT / 2 - contentHeight / 2 + self.boxOffset
    )
    love.graphics.print(
      lifeText, 
      VIRTUAL_WIDTH / 2 - boxWidth / 2 + horizontalPadding,
      VIRTUAL_HEIGHT / 2 + self.boxOffset
    )
    return
  end

  self.alienArmy:render()
  for k, bullet in pairs(self.alienBullets) do
    bullet:render()
  end
  if not self.ship.dead then
    for k, bullet in pairs(self.shipBullets) do
      bullet:render()
    end
  end
  self.ship:render()

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf(
    'Level: ' .. tostring(self.level), 
    0, 
    VIRTUAL_HEIGHT - gFonts['medium']:getHeight(),
    VIRTUAL_WIDTH,
    'left'
  )
  love.graphics.printf(
    'Lives: ' .. tostring(self.lives),
    0, 
    VIRTUAL_HEIGHT - gFonts['medium']:getHeight(),
    VIRTUAL_WIDTH,
    'right'
  )
  love.graphics.printf(
    self.score > self.highscore and
      'Highscore : ' .. tostring(self.score) or
      'Highscore : ' .. tostring(self.highscore) .. '   Score : ' ..
      tostring(self.score),
    0,
    0,
    VIRTUAL_WIDTH,
    'center'
  )
end
