function generateQuads(atlas, tileWidth, tileHeight)
  cols = atlas:getWidth() / tileWidth
  rows = atlas:getHeight() / tileHeight
  quads = {}

  for y = 0, rows - 1 do
    for x = 0, cols - 1 do
      table.insert(quads, love.graphics.newQuad(
        x * tileWidth,
        y * tileHeight,
        tileWidth,
        tileHeight,
        atlas:getDimensions()
      ))
    end
  end

  return quads
end

function detectAABBCollision(s, t)
  if s.x + s.width < t.x then
    return false
  elseif s.x > t.x + t.width then
    return false
  elseif s.y > t.y + t.height then
    return false
  elseif s.y + s.height < t.y then
    return false
  else
    return true
  end
end
