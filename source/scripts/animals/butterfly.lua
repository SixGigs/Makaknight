local pd <const> = playdate
local gfx <const> = playdate.graphics
class("Butterfly").extends(Animal)



--- The Butterfly Class Creates a Flying Butterfly
--- @param  x  integer  The X Coordinate to Create the Butterfly at
--- @param  y  integer  The Y Coordinate to Create the Butterfly at
--- @param  e  table    The Entity Data Being Passed into the Class
function Butterfly:init(x, y, e)
	local i <const> = 'images/animals/butterfly-table-4-4'

	Butterfly.super.init(self, x, y, i, e)

	self:addState(0, 1, nil, {ts = 2})
	self:playAnimation()

	-- Set the butterflies initial direction
	local xSpeed <const> = math.random(-self.speed, self.speed)
	local ySpeed <const> = math.random(-self.speed, self.speed)
	self.xVelocity = xSpeed
	self.yVelocity = ySpeed

	-- Whenever the butterfly finishes an animation, change direction
	self.states[0].onLoopFinishedEvent = function(self)
		local xSpeed <const> = math.random(-self.speed, self.speed)
		local ySpeed <const> = math.random(-self.speed, self.speed)
		self.xVelocity = xSpeed
		self.yVelocity = ySpeed
	end

	self:setCollideRect(1, 1, 2, 2)
end