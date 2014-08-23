local Player = class("Player")
local Animation = require("Animation")
local Resources = require("Resources")
local Fart = require("Fart")

local PLAYER_COLORS = {
	[1] = {255,0,0},
	[2] = {0,0,255}
}

local CONTROLS = {
	[1] = {up = "up", right = "right", down = "down", left = "left", fart = "rctrl"},
	[2] = {up = "w", right = "d", down = "s", left = "a", fart = "lctrl"}
}

local GRAVITY = 500
local ACCELERATION  = 400
local FRICTION = 200
local MAX_SPEED = 100
local JUMP_POWER = 200
local CHARGE_SPEED = 4
local MAX_JUMPS = 4

function Player:initialize(id, x, y, dir)
	self.id = id
	self.x, self.y = x, y
	self.xspeed, self.yspeed = 0, 0
	self.dir = dir
	self.grounded = false
	self.jumps = MAX_JUMPS
	self.charge = 0
	self.fart = nil

	self.anims = {}
	local walkimg = Resources.static:getImage("data/run" .. self.id .. ".png")
	self.anims.walk = Animation(walkimg, 12, 15, 0.15, 6, 7.5)
	local chargeimg = Resources.static:getImage("data/charge" .. self.id .. ".png")
	self.anims.charge = Animation(chargeimg, 12, 15, 0.15, 6, 7.5)
	self.anims.charge:setLoop(false)
	local idleimg = Resources.static:getImage("data/idle" .. self.id .. ".png")
	self.anims.idle = Animation(idleimg, 12, 15, 1, 6, 7.5)
	self.anim = self.anims.walk

	self.cone = Resources.static:getImage("data/cone" .. self.id .. ".png")
end

function Player:update(dt, map)
	-- Input
	self.anim = self.anims.idle
	if love.keyboard.isDown(CONTROLS[self.id].right) then
		if self.charge == 0 and math.abs(self.xspeed) < MAX_SPEED then
			self.xspeed = self.xspeed + dt*ACCELERATION
		end
		self.dir = 1
		self.anim = self.anims.walk
	end
	if love.keyboard.isDown(CONTROLS[self.id].left) then
		if self.charge == 0 and math.abs(self.xspeed) < MAX_SPEED then
			self.xspeed = self.xspeed - dt*ACCELERATION
		end
		self.dir = -1
		self.anim = self.anims.walk
	end

	if love.keyboard.isDown(CONTROLS[self.id].fart) and self.charge > 0 then
		self.charge = self.charge + dt
		if self.charge > 1 then
			self:makeFart()
		end
		self.anim = self.anims.charge
	end

	-- Physics
	self.yspeed = self.yspeed + GRAVITY*dt
	self.grounded = false
	local oldy = self.y
	self.y = self.y + self.yspeed*dt
	for i,v in ipairs(map:getBoxes()) do
		if v:collide(self.x-5, self.y-7.5, 10, 15) then
			self.y = oldy
			self.yspeed = self.yspeed/2
			self.grounded = true
			break
		end
	end

	if self.xspeed < 0 then
		self.xspeed = self.xspeed + math.min(-self.xspeed, FRICTION*dt)
	else
		self.xspeed = self.xspeed - math.min(self.xspeed, FRICTION*dt)
	end
	local oldx = self.x
	self.x = self.x + self.xspeed*dt
	for i,v in ipairs(map:getBoxes()) do
		if v:collide(self.x-5, self.y-7.5, 10, 15) then
			self.x = oldx
			self.xspeed = self.xspeed/2
			break
		end
	end

	-- Charge jumps
	if self.grounded then
		self.jumps = math.min(MAX_JUMPS, self.jumps + CHARGE_SPEED*dt)
	end

	self.anim:update(dt)
end

function Player:keypressed(k)
	if k == CONTROLS[self.id].up and self.jumps >= 1 and self.charge == 0 then
		self.yspeed = -JUMP_POWER
		self.jumps = self.jumps-1
	elseif k == CONTROLS[self.id].fart then
		self.anims.charge:reset()
		self.charge = 0.0001
	end
end

function Player:keyreleased(k)
	if k == CONTROLS[self.id].fart then
		self:makeFart()
	end
end

function Player:draw()
	self.anim:draw(self.x, self.y, 0, self.dir, 1)

	if self.charge > 0 then
		local fdir = self:getFartDirection()
		love.graphics.draw(self.cone, self.x, self.y, fdir, 1, 1, -10, 38)
	end

	love.graphics.setColor(0, 0, 0)
	local jf = math.floor(self.jumps)
	for i=1, jf do
		local angle = 1.5*math.pi - (jf-1)/2*math.pi/8 + (i-1) * math.pi/8
		local cx = self.x + math.cos(angle)*20
		local cy = self.y + math.sin(angle)*20
		love.graphics.rectangle("fill", cx-2, cy-2, 4, 4)
	end
	love.graphics.setColor(255,255,255)
end

function Player:makeFart()
	local fdir = self:getFartDirection()
	self.fart = Fart(self.x, self.y, fdir, math.min(1, self.charge))
	self.charge = 0
end

function Player:applyFart(fart)
	local dx = self.x - fart.x
	local dy = self.y - fart.y
	local dist = math.sqrt(dx^2 + dy^2)
	local angle = math.atan2(dy, dx)
	if math.abs(angle - fart.dir) < math.pi/8 and dist < Fart.static.RANGE then
		local power = Fart.static.POWER * fart.charge
		self.xspeed = self.xspeed + math.cos(angle) * power
		self.yspeed = self.yspeed + math.sin(angle) * power
		if fart.charge > 0.8 then
			self.jumps = math.max(0, self.jumps - 1)
		end
	end
end

function Player:getFartDirection()
	local fdir = 0
	if self.dir == -1 then
		fdir = math.pi
		if love.keyboard.isDown(CONTROLS[self.id].up) then
			fdir = fdir + math.pi/4
		elseif love.keyboard.isDown(CONTROLS[self.id].down) then
			fdir = fdir - math.pi/4
		end
	else
		if love.keyboard.isDown(CONTROLS[self.id].up) then
			fdir = fdir - math.pi/4
		elseif love.keyboard.isDown(CONTROLS[self.id].down) then
			fdir = fdir + math.pi/4
		end
	end
	return fdir
end

function Player:getFart()
	local fart = self.fart
	self.fart = nil
	return fart
end

return Player
