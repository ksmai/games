Paddle = Class{}

function Paddle:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dx = 0
end

function Paddle:update(dt)
  self.x = math.max(0, math.min(GAME_WIDTH - self.width, self.x + self.dx * dt))
end

function Paddle:render()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
