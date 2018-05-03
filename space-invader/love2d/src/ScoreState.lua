ScoreState = Class{__includes = BaseState}

function ScoreState:init()
end

function ScoreState:enter(params)
  gSounds.random:stop()
  gSounds.random:play()

  self.score = params.score
  self.highscore = params.highscore
  self.newHighscore = self.score > self.highscore

  if self.newHighscore then
    love.filesystem.setIdentity(FILE_IDENTITY)
    love.filesystem.write(FILENAME, tostring(self.score))
    self.highscore = self.score
  end
end

function ScoreState:exit()
end

function ScoreState:update(dt)
  if
    love.keyboard.wasPressed('space') or
    love.keyboard.wasPressed('enter') or
    love.keyboard.wasPressed('return') then
    gStateMachine:change('start', {
      highscore = self.highscore,
    })
  end
end

function ScoreState:render()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf(
    'Highscore : ' .. tostring(self.highscore),
    0,
    20,
    VIRTUAL_WIDTH,
    'center'
  )

  if self.newHighscore then
    love.graphics.printf(
      'A NEW HIGHSCORE !',
      0,
      VIRTUAL_HEIGHT / 2,
      VIRTUAL_WIDTH,
      'center'
    )
  else
    love.graphics.printf(
      'Your score : ' .. tostring(self.score),
      0,
      VIRTUAL_HEIGHT / 2,
      VIRTUAL_WIDTH,
      'center'
    )
  end

end
