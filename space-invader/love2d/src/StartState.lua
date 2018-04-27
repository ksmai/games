StartState = Class{__includes = BaseState}

local MAX_ALPHA = 255
local MIN_ALPHA = 128

function StartState:init()
  self.instructionAlpha = MAX_ALPHA
  self.tween = self:tweenAlphaDown()
end

function StartState:enter(params)
  if params and params.highscore then
    self.highscore = params.highscore
    self.hasHighscore = true
  else
    love.filesystem.setIdentity(FILE_IDENTITY)
    self.hasHighscore = love.filesystem.isFile(FILENAME)
    if self.hasHighscore then
      highscore = ''
      for line in love.filesystem.lines(FILENAME) do
        highscore = highscore .. line
      end
      self.highscore = tonumber(highscore)
    end
  end
end

function StartState:exit()
  self.tween:remove()
end

function StartState:update(dt)
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('play', {
      highscore = self.highscore or 0,
      level = 1,
      lives = 3,
      score = 0,
    })
  end
end

function StartState:render()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('SPACE INVADER', 0, 20, VIRTUAL_WIDTH, 'center')

  if self.hasHighscore then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf(
      'Highscore: ' .. tostring(self.highscore),
      0,
      20 + gFonts['large']:getHeight() + 3,
      VIRTUAL_WIDTH,
      'center'
    )
  end

  love.graphics.setColor(255, 255, 255, self.instructionAlpha)
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Press enter to start', 0, 180, VIRTUAL_WIDTH, 'center')
end

function StartState:tweenAlphaUp()
  return Timer.tween(0.8, {
    [self] = { instructionAlpha = 255 },
  }):finish(function() self.tween = self:tweenAlphaDown() end)
end

function StartState:tweenAlphaDown()
  return Timer.tween(0.8, {
    [self] = { instructionAlpha = 128 },
  }):finish(function() self.tween = self:tweenAlphaUp() end)
end
