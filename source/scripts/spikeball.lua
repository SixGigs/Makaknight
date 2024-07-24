-- Creating the script constants
local gfx <const> = playdate.graphics

-- Create the Spike ball class
class("Spikeball").extends(gfx.sprite)


--- Initialise the spike ball object using the information given
--- @param x      integer The X coordinate to spawn the spike-ball
--- @param y      integer The Y coordinate to spawn the spike-ball
--- @param entity table   The entities that come with the spike-ball
function Spikeball:init(x, y, entity)
	-- Load the spike ball image as a constant
	local spikeballImage <const> = gfx.image.new("images/hazards/spikeball")

	self.damage = entity.fields.damage

	-- Sprite properties
	self:setZIndex(Z_INDEXES.Hazard)
	self:setImage(spikeballImage)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:add()

	-- Set the object as a hazard and set the collision rectangle
	self:setTag(TAGS.Hazard)
	self:setCollideRect(4, 4, 8, 8)

	self.xVelocity = entity.fields.xVelocity
	self.yVelocity = entity.fields.yVelocity
end


--- The method the spike-ball uses to handle collisions
--- @param  other   table The object being collided with
--- @return unknown table The collision response to use
function Spikeball:collisionResponse(other)
	local tag <const> = other:getTag()
	
	if tag == TAGS.Player or tag == TAGS.Hazard then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeBounce
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