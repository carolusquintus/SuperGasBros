local Map = class("Map")

local Resources = require("Resources")
local Box = require("Box")

function Map:initialize()
	self.boxes = {}
	self.time = 0

	local data = require("map1")
	for i,v in ipairs(data) do
		table.insert(self.boxes, Box(v.x, v.y, v.w, v.h))
	end
	self.box = Resources.static:getImage("data/box.png")
end

function Map:update(dt)
	self.time = self.time + dt
end

function Map:draw()
	for i,v in ipairs(self.boxes) do
		for ix=0,math.floor(v.w/16)-1 do
			for iy=0,math.floor(v.h/16)-1 do
				love.graphics.draw(self.box, v.x+ix*16, v.y+iy*16)
			end
		end
	end

	love.graphics.setColor(227, 55, 0)
	local waves = math.floor(WIDTH / 16)
	for i=0, waves-1 do
		local h = 5 + math.cos(i*16/10+self.time*3)*2+2
		love.graphics.rectangle("fill", i*16, HEIGHT-h, 16, h)
	end
	love.graphics.setColor(255,255,255)
end

function Map:getBoxes()
	return self.boxes
end

return Map
