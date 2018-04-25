Bullet = Class{}

function Bullet:init(params)
  self.x = params.x
  self.y = params.y
  self.dy = params.dy
  self.width = params.width
  self.height = params.height
  self.hit = false
end

function Bullet:update(dt)
  self.y = self.y + self.dy * dt
end

function Bullet:render()
  if self.hit then
    return
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle(
    'fill',
    self.x - self.width / 2,
    self.y - self.height / 2,
    self.width,
    self.height
  )
end
