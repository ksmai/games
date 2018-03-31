local push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

DIMENSION_RATIO = 0.8
GAME_WIDTH, GAME_HEIGHT = 600, 800
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_WIDTH, WINDOW_HEIGHT = WINDOW_WIDTH * DIMENSION_RATIO, WINDOW_HEIGHT * DIMENSION_RATIO

PADDLE_SPEED = 300
PADDLE_WIDTH = 100
PADDLE_HEIGHT = 10
BALL_WIDTH = 10
BALL_HEIGHT = BALL_WIDTH
WIN_SCORE = 3

function love.load()
  math.randomseed(os.time())

  defaultFont = love.graphics.newFont('font.ttf', 24)
  fpsFont = love.graphics.newFont('font.ttf', 16)
  scoreFont = love.graphics.newFont('font.ttf', 64)


  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle('Pong')

  push:setupScreen(
    GAME_WIDTH,
    GAME_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    {
      fullscreen = false,
      vsync = true,
      resizable = false
    }
  )

  playerPaddle = Paddle(
    GAME_WIDTH / 2 - PADDLE_WIDTH / 2,
    GAME_HEIGHT - PADDLE_HEIGHT - 50,
    PADDLE_WIDTH,
    PADDLE_HEIGHT
  )
  computerPaddle = Paddle(
    GAME_WIDTH / 2 - PADDLE_WIDTH / 2,
    50,
    PADDLE_WIDTH,
    PADDLE_HEIGHT
  )
  ball = Ball(
    GAME_WIDTH / 2 - BALL_WIDTH / 2,
    GAME_HEIGHT / 2 - BALL_HEIGHT / 2,
    BALL_WIDTH,
    BALL_HEIGHT
  )
  computerScore = 0
  playerScore = 0
  playerServing = true

  gameState = 'start'
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if gameState == 'start' or gameState == 'serve' then
    if key == 'enter' or key == 'return' or key == 'space' then
      gameState = 'play'
      ball:reset()
    end
  elseif gameState == 'end' then
    if key == 'enter' or key == 'return' or key == 'space' then
      gameState = 'start'
      playerScore = 0
      computerScore = 0
    end
  end
end

function love.update(dt)
  if gameState == 'play' then
    if ball.y + ball.height < 0 then
      playerScore = playerScore + 1
      playerServing = false
      if playerScore >= WIN_SCORE then
        gameState = 'end'
      else
        gameState = 'serve'
      end
    elseif ball.y > GAME_HEIGHT then
      computerScore = computerScore + 1
      playerServing = true
      if computerScore >= WIN_SCORE then
        gameState = 'end'
      else
        gameState = 'serve'
      end
    end

    if ball:collides(playerPaddle) or ball:collides(computerPaddle) then
      local sign = math.random(1, 2) == 1 and 1 or -1
      ball.dx = sign * math.random(1, 150)
      ball.dy = -ball.dy * 1.1

      if ball:collides(playerPaddle) then
        ball.y = playerPaddle.y - ball.height
      elseif ball:collides(computerPaddle) then
        ball.y = computerPaddle.y + computerPaddle.height
      end
    end

    if ball.x < 0 then
      ball.x = 0
      ball.dx = -ball.dx
    elseif ball.x + ball.width > GAME_WIDTH then
      ball.x = GAME_WIDTH - ball.width
      ball.dx = -ball.dx
    end

    ball:update(dt)
  end

  if love.keyboard.isDown('left') then
    playerPaddle.dx = -PADDLE_SPEED
  elseif love.keyboard.isDown('right') then
    playerPaddle.dx = PADDLE_SPEED
  else
    playerPaddle.dx = 0
  end

  if computerPaddle.x + computerPaddle.width < ball.x + ball.width / 2 then
    computerPaddle.dx = PADDLE_SPEED
  elseif computerPaddle.x > ball.x + ball.width / 2 then
    computerPaddle.dx = -PADDLE_SPEED
  else
    if computerPaddle.dx > 0 and computerPaddle.x + computerPaddle.width / 2 > ball.x + ball.width / 2 then
      computerPaddle.dx = 0
    elseif computerPaddle.dx < 0 and computerPaddle.x + computerPaddle.width / 2 < ball.x + ball.width / 2 then
      computerPaddle.dx = 0
    end
  end

  playerPaddle:update(dt)
  computerPaddle:update(dt)
end

function love.draw()
  push:start()

  love.graphics.clear(40, 45, 52, 255)

  if gameState == 'start' then
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle('line', GAME_WIDTH / 2 - 160, GAME_HEIGHT / 2 - 40, 320, 80)
    love.graphics.printf(
      'Press Enter to start!',
      0,
      GAME_HEIGHT / 2 - 6,
      GAME_WIDTH,
      'center'
    )
  elseif gameState == 'play' then
    ball:render()
  elseif gameState == 'serve' then
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(255, 255, 255, 255)
    servePlayer = playerServing and 'You' or 'Computer'
    love.graphics.printf(
      servePlayer .. ' serve next!\nPress enter when ready',
      0,
      GAME_HEIGHT / 2,
      GAME_WIDTH,
      'center'
    )
    showScore()
  elseif gameState == 'end' then
    love.graphics.setFont(scoreFont)
    if playerServing then
      verb = 'lose'
      love.graphics.setColor(255, 0, 0, 255)
    else
      verb = 'win'
      love.graphics.setColor(0, 255, 0, 255)
    end
    love.graphics.printf(
      'You ' .. verb .. '!',
      0,
      GAME_HEIGHT / 2 - 32,
      GAME_WIDTH,
      'center'
    )
    showScore()
  end
  playerPaddle:render()
  computerPaddle:render()

  showFPS()

  push:finish()
end

function showFPS()
  love.graphics.setFont(fpsFont)
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 0, 0, GAME_WIDTH, 'right')
end

function showScore()
  love.graphics.setFont(scoreFont)
  if computerScore > playerScore then
    love.graphics.setColor(0, 255, 0, 255)
  elseif computerScore < playerScore then
    love.graphics.setColor(255, 0, 0, 255)
  else
    love.graphics.setColor(255, 255, 255, 255)
  end
  love.graphics.printf(
    tostring(computerScore),
    0,
    GAME_HEIGHT / 4 - 32,
    GAME_WIDTH,
    'center'
  )
  if computerScore < playerScore then
    love.graphics.setColor(0, 255, 0, 255)
  elseif computerScore > playerScore then
    love.graphics.setColor(255, 0, 0, 255)
  else
    love.graphics.setColor(255, 255, 255, 255)
  end
  love.graphics.printf(
    tostring(playerScore),
    0,
    3 * GAME_HEIGHT / 4 - 32,
    GAME_WIDTH,
    'center'
  )
end

function love.resize(w, h)
  push:resize(w, h)
end
