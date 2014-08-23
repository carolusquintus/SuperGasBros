local Box = class("Box")

function Box:initialize(x, y, w, h)
	self.x, self.y = x, y
	self.w, self.h = w, h
end

function Box.static:collide(a, b)
	if a.x > b.x+b.w or a.x+a.w < b.x
	or a.y > b.y+b.h or a.y+a.h < b.y then
		return false
	else
		return true
	end
end

function Box:collide(x, y, w, h)
	if self.x > x+w or self.x+self.w < x
	or self.y > y+h or self.y+self.h < y then
		return false
	else
		return true
	end
end

return Box
