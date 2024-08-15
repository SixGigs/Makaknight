-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Butterfly").extends(Animal)


function Butterfly:init(x, y, e)
	Butterfly.super.init(self, x, y, e)

	self:addState("fly", 1, 4, {ts = 3})
	self:playAnimation()
end


--- Handle the possible ground events for the Animal
function Butterfly:handleState()
	if self.timerActive then
		return
	end

	if not self.timer then
		self.timer = true
		pd.timer.performAfterDelay(math.random(50, 150), function()
			local xSpeed <const> = math.random(-self.speed, self.speed)
			local ySpeed <const> = math.random(-self.speed, self.speed)

			self.xVelocity = xSpeed
			self.yVelocity = ySpeed
			self.timer = false
		end)
	end
end