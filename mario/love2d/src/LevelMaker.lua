--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}
    local map

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    -- whether we should generate a level with lock and key
    local theLock = nil
    local lockAndKey = true
    local lockSpawned = false -- only one lock per level
    local keySpawned = false
    local unlockable = false
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                elseif lockAndKey and not keySpawned and math.random(10000)/10000 <= (x / width) ^ 5 then
                    keySpawned = true
                    table.insert(objects, GameObject{
                      texture = 'keys-and-locks',
                      x = (x - 1) * TILE_SIZE,
                      y = (5 - 1) * TILE_SIZE - 16,
                      width = 16,
                      height = 16,
                      frame = KEYS[math.random(#KEYS)],
                      collidable = true,
                      consumable = true,
                      solid = false,
                      onConsume = function(player, object)
                        gSounds['pickup']:play()
                        for k, obj in pairs(objects) do
                          unlockable = true
                        end
                      end
                    })
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            elseif lockAndKey and not keySpawned and math.random(10000) / 10000 <= (x / width) ^ 5 then
                keySpawned = true
                table.insert(objects, GameObject{
                  texture = 'keys-and-locks',
                  x = (x - 1) * TILE_SIZE,
                  y = (7 - 1) * TILE_SIZE - 16,
                  width = 16,
                  height = 16,
                  frame = KEYS[math.random(#KEYS)],
                  collidable = true,
                  consumable = true,
                  solid = false,
                  onConsume = function(player, object)
                    gSounds['pickup']:play()
                    for k, obj in pairs(objects) do
                      unlockable = true
                    end
                  end
                })
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            elseif lockAndKey and not lockSpawned and math.random(10000)/10000 <= (x / width) ^ 5 then
                lockSpawned = true
                theLock = GameObject{
                  texture = 'keys-and-locks',
                  x = (x - 1) * TILE_SIZE,
                  y = (blockHeight - 1) * TILE_SIZE,
                  width = 16,
                  height = 16,
                  collidable = true,
                  consumable = false,
                  solid = true,
                  onCollide = function(object)
                    gSounds['empty-block']:play()
                    if unlockable then
                      for k, o in pairs(objects) do
                        if o == object then
                          objects[k] = nil
                          theLock = nil
                          local lastGroundTile = map:getEndOfLevelGroundTile()
                          local postX = (lastGroundTile.x - 1) * TILE_SIZE
                          local flagX = postX + 8
                          local flagY = (lastGroundTile.y - 1 - math.random(3)) * TILE_SIZE
                          local postY = (lastGroundTile.y - 1 - 3) * TILE_SIZE
                          local flagFrame = FLAGS[math.random(#FLAGS)]
                          table.insert(objects, GameObject{
                            texture = 'flags',
                            x = postX,
                            y = postY,
                            width = 16,
                            height = 48,
                            frame = POSTS[math.random(#POSTS)],
                            collidable = true,
                            consumable = true,
                            solid = false,

                            onConsume = function(player, object)
                                gSounds['win']:play()
                                gStateMachine:change('play', {
                                  score = player.score,
                                  gameLevel = player.gameLevel + 1,
                                })
                            end
                          })
                          table.insert(objects, GameObject{
                            texture = 'flags',
                            x = flagX,
                            y = flagY,
                            width = 16,
                            height = 16,
                            frame = flagFrame,
                            collidable = true,
                            consumable = true,
                            solid = false,
                            direction = 'right',
                            animation = Animation{
                              frames = { flagFrame, flagFrame + 1, flagFrame + 2 },
                              interval = 0.1
                            },

                            onConsume = function(player, object)
                                gSounds['win']:play()
                                gStateMachine:change('play', {
                                  score = player.score,
                                  gameLevel = player.gameLevel + 1,
                                })
                            end
                          })
                        elseif o.x == postX then
                            objects[k] = nil -- remove other objects at this loaction
                        end
                      end
                    end
                  end,
                  frame = LOCKS[math.random(#LOCKS)]
                }
                table.insert(objects, theLock)
            end
        end
    end

    map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end
