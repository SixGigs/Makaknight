-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Butterfly Class
class("Butterfly").extends(Animal)


--- The Butterfly Class Creates a Flying Butterfly
--- @param  x  integer  The X Coordinate to Create the Butterfly at
--- @param  y  integer  The Y Coordinate to Create the Butterfly at
--- @param  e  table    The Entity Data Being Passed into the Class
function Butterfly:init(x, y, e)
	-- Initialise the Butterfly Class
	Butterfly.super.init(self, x, y, e)

	-- Butterfly Animation Settings
	self:addState("a", 1, 4, {ts = 3})
	self:playAnimation()

	self.weight = 1

	-- Butterfly Collision Box
	self:setCollideRect(1, 1, 2, 2)
end


--- Handle the possible ground events for the Animal
function Butterfly:handleState()
	if self.timer then
		return
	end
	
	-- Set a Timer to Make the Directional Change Random
	self.timer = true
	pd.timer.performAfterDelay(math.random(50, 150), function()
		local xSpeed <const> = math.random(-self.speed, self.speed)
		local ySpeed <const> = math.random(-self.speed, self.speed)

		self.xVelocity = xSpeed
		self.yVelocity = ySpeed
		self.timer = false
	end)
end