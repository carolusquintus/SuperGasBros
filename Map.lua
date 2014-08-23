local Map = class("Map")

local Resources = require("Resources")
local Box = require("Box")

function Map:initialize()
	self.boxes = {}

	local data = require("map1")
	for i,v in ipairs(data) do
		table.insert(self.boxes, Box(v.x, v.y, v.w, v.h))
	end
	self.box = Resources.static:getImage("data/box.png")
end

function Map:draw()
	for i,v in ipairs(self.boxes) do
		for ix=0,math.floor(v.w/16)-1 do
			for iy=0,math.floor(v.h/16)-1 do
				love.graphics.draw(self.box, v.x+ix*16, v.y+iy*16)
			end
		end
	end
end

function Map:getBoxes()
	return self.boxes
end

return Map
