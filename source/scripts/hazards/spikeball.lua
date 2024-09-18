local gfx <const> = playdate.graphics
class('Spikeball').extends(AnimatedSprite)

--- Initialise the Spike-ball object using the information given
--- @param  x  integer  The X coordinate to spawn the Spike-ball
--- @param  y  integer  The Y coordinate to spawn the Spike-ball
--- @param  e  table    The entities that come with the Spike-ball
function Spikeball:init(x, y, e)
	Spikeball.super.init(self, gfx.imagetable.new('images/hazards/animated/spikeball-table-23-23'))

	self:addState('i', 1, 2, {ts = 60})
	self:playAnimation()

	self.damage = e.fields.damage
	self.xVelocity = e.fields.xVelocity * 30
	self.yVelocity = e.fields.yVelocity * 30
	self.overlapTags = {
		[TAGS.Player] = true,
		[TAGS.GUI] = true
	}

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:setCollideRect(4, 4, 15, 15)
	self:add()
end


--- Set the collision response for the Spike-ball
--- @param  e  table  The entity the Spike-ball collided with
function Spikeball:collisionResponse(e)
	local tag <const> = e:getTag()
	if self.overlapTags[tag] then
		return gfx.sprite.kCollisionTypeOverlap
	end
end


--- The update method for the Spike-ball, it will run every tick
function Spikeball:update()
	local _, _, collisions, length <const> = self:moveWithCollisions(
		self.x + (self.xVelocity * dt), 
		self.y + (self.yVelocity * dt)
	)

	-- Bounce off walls
	for i = 1, length do
		local collision = collisions[i]
		if not self.overlapTags[collision.other:getTag()] then
			self.xVelocity = self.xVelocity * -1
			self.yVelocity = self.yVelocity * -1
		end
	end

	self:updateAnimation()
end