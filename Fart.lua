local Fart = class("Fart")

Fart.static.POWER = 200
Fart.static.RANGE = 230

function Fart:initialize(x, y, dir, charge)
	self.x, self.y = x, y
	self.dir = dir
	self.charge = charge
end

return Fart
