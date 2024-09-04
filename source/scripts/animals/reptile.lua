-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Reptile class
class("Reptile").extends(Animal)


--- The Reptile Class Create a Reptile
--- @param  x  integer  The X Coordinate to Create the Reptile at
--- @param  y  integer  The Y Coordinate to Create the Reptile at
--- @param  e  object   The Entity Data Being Passed into the Class
function Reptile:init(x, y, e)
	Reptile.super.init(self, x, y, e)

	self:addState("idle", 1, 1)
	self:addState("blep", 2, 4, {ts = 3})
	self:addState("walk", 5, 8, {ts = 3})
	self:playAnimation()

	self.gravity = 900
	self.weight = 2

	self:setCollideRect(3, 5, 10, 3)
end


--- Handles the changing states of the Reptile
function Reptile:handleState()
	self:applyGravity()
	self:handleGroundInput()
end


--- Handle the possible ground events for the Reptile
function Reptile:handleGroundInput()
	if self.timer then
		return
	end

	self.timer = true
	pd.timer.performAfterDelay(math.random(500, 2000), function()
		local action <const> = math.random(1, 2)

		if action == 1 then
			self:changeToBlepState()
		elseif action == 2 then
			self:changeToWalkState(math.random(0, 1))
		end

		self.timer = false
	end)
end


--- Have the Reptile flick its tongue
function Reptile:changeToBlepState()
	self.xVelocity = 0
	self:changeState("blep")
	pd.timer.performAfterDelay(200, function()
		self:changeState("idle")
	end)
end


--- Have the Reptile Walk in a Given Direction for a While
--- @param  direction  integer  Zero for Left and One for Right
function Reptile:changeToWalkState(direction)
	if direction == 1 then
		self.xVelocity = self.speed
	else
		self.xVelocity = -self.speed
	end

	self:changeState("walk")
	pd.timer.performAfterDelay(math.random(200, 600), function()
		self.xVelocity = 0
		self:changeState("idle")
	end)
end


--- Applies Gravity to the Reptile
function Reptile:applyGravity()
	self.yVelocity = self.yVelocity + (self.gravity * dt)
	if self.touchingGround then
		self.yVelocity = 0
	end
end