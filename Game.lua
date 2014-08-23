local Player = require("Player")
local Map = require("Map")

local Game = class("Game")

function Game:initialize()
	self.players = {}
	table.insert(self.players, Player(1, WIDTH/3, HEIGHT/2, 1))
	table.insert(self.players, Player(2, WIDTH/3*2, HEIGHT/2, -1))

	self.map = Map()
end

function Game:update(dt)
	if dt > 1/20 then dt = 1/20 end

	for i,v in ipairs(self.players) do
		local fart = v:getFart()
		if fart then
			for j,w in ipairs(self.players) do
				if w ~= v then
					w:applyFart(fart)
				end
			end
		end
	end

	for i,v in ipairs(self.players) do
		v:update(dt, self.map)
	end
	
end

function Game:draw()
	love.graphics.scale(SCALE, SCALE)

	self.map:draw()

	for	i,v in ipairs(self.players) do
		v:draw()
	end
end

function Game:keypressed(k)
	for i,v in ipairs(self.players) do
		v:keypressed(k)
	end
end

function Game:keyreleased(k)
	for i,v in ipairs(self.players) do
		v:keyreleased(k)
	end
end

return Game
