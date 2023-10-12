-- Creating the script constants
local gfx <const> = playdate.graphics
local spikeballImage <const> = gfx.image.new("images/spikeball")

-- Create the spikeball class
class('Spikeball').extends(gfx.sprite)


--- Initialise the spikeball object using the information given
--- @param x      integer The X coordinate to spawn the spikeball
--- @param y      integer The Y coordinate to spawn the spikeball
--- @param entity table   The entities that come with the spikeball
function Spikeball:init(x, y, entity)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setImage(spikeballImage)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:add()

	self:setTag(TAGS.Hazard)
	self:setCollideRect(4, 4, 8, 8)

	local fields = entity.fields
	self.xVelocity = fields.xVelocity
	self.yVelocity = fields.yVelocity
end


--- The method the spikeball uses to handle collisions
--- @param  other   table The object being collided with
--- @return unknown table The collision response to use
function Spikeball:collisionResponse(other)
	if other:getTag() == TAGS.Player then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeBounce
end


--- The update method for the spikeball, it will run every tick
function Spikeball:update()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)
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