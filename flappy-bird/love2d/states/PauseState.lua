PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
  self.previousState = params.previousState
  self.previousScrolling = scrolling
  scrolling = false
  sounds.music:pause()
end

function PauseState:exit()
  scrolling = self.previousScrolling
  sounds.music:resume()
end

function PauseState:update(dt)
  if love.keyboard.wasPressed('p') then
    gStateMachine:transition(self.previousState)
  end
end

function PauseState:render()
  self.previousState:render()
  love.graphics.setColor(0, 0, 0, 170)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 15, VIRTUAL_HEIGHT / 2 - 15, 10, 30)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 15, 10, 30)

  love.graphics.setFont(smallFont)
  love.graphics.print('Press \'p\' to continue', 8, VIRTUAL_HEIGHT - 24)
end
