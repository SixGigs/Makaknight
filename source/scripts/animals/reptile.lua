-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Reptile class
class("Reptile").extends(Animal)


function Reptile:init(x, y, e)
	-- Super initialise the Reptile class
	Reptile.super.init(self, x, y, e)

	self:addState("idle", 1, 1)
	self:addState("blep", 2, 4, {ts = 3})
	self:addState("walk", 5, 8, {ts = 3})
	self:playAnimation()
	
	-- Physics properties
	self.gravity = 900
	self.touchingGround = false
end


--- Handles the changing states of the Animal
function Reptile:handleState()
	self:applyGravity()
	self:handleGroundInput()
end


--- Handle the possible ground events for the Animal
function Reptile:handleGroundInput()
	if self.timerActive then
		return
	end

	self.timerActive = true
	pd.timer.performAfterDelay(math.random(500, 2000), function()
		local action <const> = math.random(1, 2)

		if action == 1 then
			self:changeToBlepState()
		elseif action == 2 then
			self:changeToWalkState(math.random(0, 1))
		end

		self.timerActive = false
	end)
end


--- Have the Animal flick its tongue
function Reptile:changeToBlepState()
	self.xVelocity = 0
	self:changeState("blep")
	pd.timer.performAfterDelay(200, function()
		self:changeState("idle")
	end)
end


--- Have the Animal walk in a given direction for a while
function Reptile:changeToWalkState(direction)
	if direction == 0 then
		self.xVelocity = -self.speed
		self.globalFlip = 1
	else
		self.xVelocity = self.speed
		self.globalFlip = 0
	end

	self:changeState("walk")
	pd.timer.performAfterDelay(math.random(200, 600), function()
		self.xVelocity = 0
		self:changeState("idle")
	end)
end


--- Applies gravity to the Animal
function Reptile:applyGravity()
	self.yVelocity = self.yVelocity + (self.gravity * dt)
	if self.touchingGround then
		self.yVelocity = 0
	end
end