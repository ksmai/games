push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'
Event = require 'lib/knife.event'

require 'src/Util'

VIRTUAL_WIDTH = 288
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 768

gFonts = {
  small = love.graphics.newFont('font/font.ttf', 8),
  medium = love.graphics.newFont('font/font.ttf', 8),
  large = love.graphics.newFont('font/font.ttf', 16),
}

gTextures = {
  aliens = love.graphics.newImage('textures/aliens.png'),
  ships = love.graphics.newImage('textures/ships.png'),
  particle = love.graphics.newImage('textures/particle.png'),
}

gFrames = {
  aliens = generateQuads(gTextures['aliens'], 16, 16),
  ships = generateQuads(gTextures['ships'], 16, 16),
}

gSounds = {
  explode = love.audio.newSource('sounds/explode.wav', 'static'),
  shoot = love.audio.newSource('sounds/shoot.wav', 'static'),
  shoot2 = love.audio.newSource('sounds/shoot2.wav', 'static'),
  random = love.audio.newSource('sounds/random.wav', 'static'),
  music = love.audio.newSource('sounds/music.wav', 'static'),
}
