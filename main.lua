class = require("middleclass")
gamestate = require("hump.gamestate")
require("mymath")

local Game = require("Game")

WIDTH = 320
HEIGHT = 240
SCALE = 3

function love.load()
	love.window.setMode(WIDTH*SCALE, HEIGHT*SCALE, {vsync=true})
	love.graphics.setBackgroundColor(142, 220, 107)
	love.graphics.setDefaultFilter("nearest", "nearest")

	gamestate.registerEvents()
	gamestate.switch(Game())
end
