local gfx <const> = playdate.graphics
class("Spikeball").extends("Spike")

--- Initialise the Spike-ball object using the information given
--- @param  x  integer  The X coordinate to spawn the Spike-ball
--- @param  y  integer  The Y coordinate to spawn the Spike-ball
--- @param  e  table    The entities that come with the Spike-ball
function Spikeball:init(x, y, e)
	Spikeball.super.init(self, x, y, e)

	self.xVelocity = e.fields.xVelocity
	self.yVelocity = e.fields.yVelocity

	self:setCollideRect(4, 4, 8, 8)
end


--- Set the collision response for the Spike-ball
--- @param  e  table  The entity the Spike-ball collided with
function Spikeball:collisionResponse(e)
	local tag <const> = e:getTag()
	if tag == TAGS.Player then
		return gfx.sprite.kCollisionTypeOverlap
	end
end


--- The update method for the Spike-ball, it will run every tick
function Spikeball:update()
	local _, _, collisions, length = self:moveWithCollisions(
		self.x + (self.xVelocity * dt), 
		self.y + (self.yVelocity * dt)
	)

	-- Bounce off walls
	for i = 1, length do
		local collision = collisions[i]
		if collision.other:getTag() ~= TAGS.Player then
			self.xVelocity = self.xVelocity * -1
			self.yVelocity = self.yVelocity * -1
		end
	end
end