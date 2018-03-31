Ball = Class{}

function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dx = 0
  self.dy = 0
end

function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

function Ball:collides(paddle)
  if
    self.x + self.width < paddle.x or
    self.x > paddle.x + paddle.width or
    self.y + self.height < paddle.y or
    self.y > paddle.y + paddle.height
  then
    return false
  end

  return true
end

function Ball:reset()
  self.x = GAME_WIDTH / 2 - self.width / 2
  self.y = GAME_HEIGHT / 2 - self.height / 2
  local sign = playerServing and -1 or 1
  self.dy = sign * 200
  self.dx = math.random(1, 100)
end

function Ball:render()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
