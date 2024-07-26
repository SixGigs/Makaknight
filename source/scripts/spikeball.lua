-- Creating the script constants
local gfx <const> = playdate.graphics

-- Create the Spike ball class
class("Spikeball").extends("Spike")


--- Initialise the spike ball object using the information given
--- @param x      integer The X coordinate to spawn the spike-ball
--- @param y      integer The Y coordinate to spawn the spike-ball
--- @param entity table   The entities that come with the spike-ball
function Spikeball:init(x, y, e)
	Spikeball.super.init(self, x, y, e)

	self.xVelocity = e.fields.xVelocity
	self.yVelocity = e.fields.yVelocity

	self:setCollideRect(4, 4, 8, 8)
end


--- The update method for the spike-ball, it will run every tick
function Spikeball:update()
	local _, _, collisions, length = self:moveWithCollisions(self.x + (self.xVelocity * dt), self.y + (self.yVelocity * dt))
	local hitWall = false

	for i = 1, length do
		local collision = collisions[i]
		if collision.other:getTag() ~= TAGS.Player then
			hitWall = true
		end
	end

	if hitWall then
		self.xVelocity = self.xVelocity * -1
		self.yVelocity = self.yVelocity * -1
	end
end