local Player = require("Player")
local Map = require("Map")

local Game = class("Game")

function Game:initialize()
	self.points = {0,0}
	self.players = {}

	self.map = Map()

	self:restart()
end

function Game:restart()
	self.players[1] = Player(1, WIDTH/3, HEIGHT/2, 1)
	self.players[2] = Player(2, WIDTH/3*2, HEIGHT/2, -1)
end

function Game:update(dt)
	if dt > 1/20 then dt = 1/20 end

	self.map:update(dt)	

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

	if self.players[1].y > HEIGHT+64 then
		self.points[2] = self.points[2] + 1
		self:restart()
	elseif self.players[2].y > HEIGHT+64 then
		self.points[1] = self.points[1] + 1
		self:restart()
	end
end

function Game:draw()
	love.graphics.scale(SCALE, SCALE)

	self.map:draw()

	for	i,v in ipairs(self.players) do
		v:draw()
	end

	love.graphics.print("Player 1: "..self.points[1], 8, 8)
	love.graphics.print("Player 2: "..self.points[2], 8, 24)
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
