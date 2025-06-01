local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Firefly').extends(Animal)



--- The Butterfly Class Creates a Flying Butterfly
--- @param  x  integer  The X Coordinate to Create the Butterfly at
--- @param  y  integer  The Y Coordinate to Create the Butterfly at
--- @param  e  table    The Entity Data Being Passed into the Class
function Firefly:init(x, y, e)
	local i <const> = 'images/animals/firefly-table-10-10'

	Firefly.super.init(self, x, y, i, e)

	self:addState(0, 7, 8, {ts = 1})
	self:playAnimation()

	self:setCollideRect(1, 2, 8, 8)
end



--- Handle the possible ground events for the Animal
function Firefly:handleState()
	if self.timer then
		return
	end

	-- Set a Timer to Make the Directional Change Random
	self.timer = true
	pd.timer.performAfterDelay(math.random(150, 300), function()
		local xSpeed <const> = math.random(-self.speed, self.speed)
		local ySpeed <const> = math.random(-self.speed, self.speed)

		self.xVelocity = xSpeed
		self.yVelocity = ySpeed
		self.timer = false
	end)
end