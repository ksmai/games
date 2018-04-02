--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = shiny
    if self.shiny then
      self.shinyAlpha = 0
      self.shinyIncreasing = true
    end
end

function Tile:update(dt)
  if self.shiny then
    if self.shinyIncreasing then
      self.shinyAlpha = self.shinyAlpha + 128 * dt
      if self.shinyAlpha > 128 then
        self.shinyAlpha = 128
        self.shinyIncreasing = false
      end
    else
      self.shinyAlpha = self.shinyAlpha - 128 * dt
      if self.shinyAlpha < 0 then
        self.shinyAlpha = 0
        self.shinyIncreasing = true
      end
    end
  end
end

--[[
    Function to swap this tile with another tile, tweening the two's positions.
]]
function Tile:swap(tile)

end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    --draw shiny
    if self.shiny then
      love.graphics.setColor(255, 255, 255, self.shinyAlpha)
      love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32, 6)
    end
end
