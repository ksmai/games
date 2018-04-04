--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

local ALLOWED_COLORS = {
  1,
  5,
  6,
  9,
  10,
  15,
  16
}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.level = level
    self.maxVariety = math.min(6, math.max(1, math.floor(math.sqrt(self.level))))
    self.matches = {}

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, ALLOWED_COLORS[math.random(#ALLOWED_COLORS)], math.random(self.maxVariety), math.random(128) == 1))
        end
    end

    while self:calculateMatches() or not self:hasMoves() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

function Board:getTileFromMouseXY(x, y)
  gameX, gameY = push:toGame(x, y)
  row = math.floor((gameY - self.y) / 32) + 1
  col = math.floor((gameX - self.x) / 32) + 1
  if row > 0 and row <= #self.tiles then
    if col > 0 and col <= #self.tiles[row] then
      return self.tiles[row][col]
    end
  end

  return nil
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                        if self.tiles[y][x2].shiny then
                          match = self.tiles[y]
                          break
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].shiny then
                  match = self.tiles[y]
                  break
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                        if self.tiles[y2][x].shiny then
                          for i, tile in pairs(self.tiles[y2]) do
                            if tile ~= self.tiles[y2][x] then
                              table.insert(match, tile)
                            end
                          end
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].shiny then
                  for i, tile in pairs(self.tiles[y]) do
                    if tile ~= self.tiles[y][x] then
                      table.insert(match, tile)
                    end
                  end
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

function Board:canMoveUp(x, y)
  if y <= 1 then
    return false
  elseif
    x > 2 and
    self.tiles[y][x].color == self.tiles[y - 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y - 1][x - 2].color
  then
    return true
  elseif
    x > 1 and
    x < 8 and
    self.tiles[y][x].color == self.tiles[y - 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y - 1][x + 1].color
  then
    return true
  elseif
    x < 7 and
    self.tiles[y][x].color == self.tiles[y - 1][x + 1].color and
    self.tiles[y][x].color == self.tiles[y - 1][x + 2].color
  then
    return true
  elseif
    y > 3 and
    self.tiles[y][x].color == self.tiles[y - 2][x].color and
    self.tiles[y][x].color == self.tiles[y - 3][x].color
  then
    return true
  else
    return false
  end
end

function Board:canMoveDown(x, y)
  if y > 7 then
    return false
  elseif
    x > 2 and
    self.tiles[y][x].color == self.tiles[y + 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y + 1][x - 2].color
  then
    return true
  elseif
    x > 1 and
    x < 8 and
    self.tiles[y][x].color == self.tiles[y + 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y + 1][x + 1].color
  then
    return true
  elseif
    x < 7 and
    self.tiles[y][x].color == self.tiles[y + 1][x + 1].color and
    self.tiles[y][x].color == self.tiles[y + 1][x + 2].color
  then
    return true
  elseif
    y < 6 and
    self.tiles[y][x].color == self.tiles[y + 2][x].color and
    self.tiles[y][x].color == self.tiles[y + 3][x].color
  then
    return true
  else
    return false
  end
end

function Board:canMoveLeft(x, y)
  if x < 2 then
    return false
  elseif
    y > 2 and
    self.tiles[y][x].color == self.tiles[y - 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y - 2][x - 1].color
  then
    return true
  elseif
    y > 1 and
    y < 8 and
    self.tiles[y][x].color == self.tiles[y - 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y + 1][x - 1].color
  then
    return true
  elseif
    y < 7 and
    self.tiles[y][x].color == self.tiles[y + 1][x - 1].color and
    self.tiles[y][x].color == self.tiles[y + 2][x - 1].color
  then
    return true
  elseif
    x > 3 and
    self.tiles[y][x].color == self.tiles[y][x - 2].color and
    self.tiles[y][x].color == self.tiles[y][x - 3].color
  then
    return true
  else
    return false
  end
end

function Board:canMoveRight(x, y)
  if x > 7 then
    return false
  elseif
    y > 2 and
    self.tiles[y][x].color == self.tiles[y - 1][x + 1].color and
    self.tiles[y][x].color == self.tiles[y - 2][x + 1].color
  then
    return true
  elseif
    y > 1 and
    y < 8 and
    self.tiles[y][x].color == self.tiles[y - 1][x + 1].color and
    self.tiles[y][x].color == self.tiles[y + 1][x + 1].color
  then
    return true
  elseif
    y < 7 and
    self.tiles[y][x].color == self.tiles[y + 1][x + 1].color and
    self.tiles[y][x].color == self.tiles[y + 2][x + 1].color
  then
    return true
  elseif
    x < 6 and
    self.tiles[y][x].color == self.tiles[y][x + 2].color and
    self.tiles[y][x].color == self.tiles[y][x + 3].color
  then
    return true
  else
    return false
  end
end

function Board:hasMoves()
  hasMoves = false
  for y = 1, #self.tiles do
    for x = 1, #self.tiles[y] do
      if
        self:canMoveLeft(x, y) or
        self:canMoveRight(x, y) or
        self:canMoveUp(x, y) or
        self:canMoveDown(x, y)
      then
        hasMoves = true
        break
      end
    end
  end

  return hasMoves
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set space back to 0, set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                local tile = Tile(x, y, ALLOWED_COLORS[math.random(#ALLOWED_COLORS)], math.random(self.maxVariety), math.random(128) == 1)
                tile.y = -32
                self.tiles[y][x] = tile

                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:getNewTiles()
    return {}
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end

function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:update(dt)
        end
    end
end
