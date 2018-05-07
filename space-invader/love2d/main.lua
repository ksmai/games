require 'src/Dependencies'

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle('Space Invader')
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    resize = true,
    fullscreen = false,
  })
  love.keyboard.keysPressed = {}
  gStateMachine:change('start')
  gSounds['music']:setLooping(true)
  gSounds['music']:play()
end

function love.keypressed(key)
  if love.keyboard.isDown('escape') then
    love.event.quit()
  end

  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  Timer.update(dt)
  gStateMachine:update(dt)
  love.keyboard.keysPressed = {}
end

function love.draw()
  push:start()
  gStateMachine:render()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.printf(
    'FPS: ' .. tostring(love.timer.getFPS()),
    0,
    0,
    VIRTUAL_WIDTH,
    'right'
  )
  push:finish()
end
