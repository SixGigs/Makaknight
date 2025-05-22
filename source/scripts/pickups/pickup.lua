local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Pickup').extends(AnimatedSprite)

-- An array of tags potions can overlap
local overlapTags <const> = {
	[TAGS.Animal] = true,
	[TAGS.Door] = true,
	[TAGS.Fragile] = true,
	[TAGS.Gui] = true,
	[TAGS.Half] = true,
	[TAGS.Hitbox] = true,
	[TAGS.Pickup] = true,
	[TAGS.Player] = true,
	[TAGS.Wind] = true
}



--- This class is inherited to create pickup items
--- @param  x  integer  The X coordinate of the pickup
--- @param  y  integer  The Y coordinate of the pickup
--- @param  i  string   The pickup image table path
function Pickup:init(x, y, i)
	-- Initialise the AnimatedSprite library
	Pickup.super.init(self, gfx.imagetable.new(i))

	-- Pickup class properties
	self.ticker = 0
	self.timer = false
	self.pickedUp = false
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false

	-- Playdate sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
end



--- This method runs every tick to update pickups
function Pickup:update()
	if not self:isVisible() then
		return
	end

	if self.pickedUp and self:isVisible() then
		GAME.depletedEntities[self.id] = true
		self:setVisible(false)
	end

	self:updateAnimation()
	self:handleState()
	self:handleSparkle()
	self:handleMovementAndCollisions()
end



--- This method handles complex pickup collisions
function Pickup:collisionResponse(e)
	local tag <const> = e:getTag()

	if overlapTags[tag] then
		if tag == TAGS.Fragile or tag == TAGS.Half then
			return e:collision(self)
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	return gfx.sprite.kCollisionTypeSlide
end



--- This method handles pickup movement and collisions
function Pickup:handleMovementAndCollisions()
	local xMovement <const> = self.x + (self.xVelocity * DELTA_TIME)
	local yMovement <const> = self.y + (self.yVelocity * DELTA_TIME)
	local _, _, collisions, length <const> = self:moveWithCollisions(xMovement, yMovement)

	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false

	for i = 1, length do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		local collisionObject <const> = collision.other
		local collisionTag <const> = collisionObject:getTag()

		-- Let's test the collision type
		if collisionType == gfx.sprite.kCollisionTypeSlide then
			if collision.normal.y == -1 then
				self.touchingGround = true
			elseif collision.normal.y == 1 then
				self.touchingCeiling = true
			end

			if collision.normal.x ~= 0 then
				self.touchingWall = true
			end
		end

		-- Match collision to collision tag
		if collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Fragile then
			collisionObject:handleCollision(self, collision)
		elseif collisionTag == TAGS.Roaster then
			if self.touchingGround then
				collisionObject:handleCollision(self)
			end
		end
	end

	-- Change the pickups direction with xVelocity
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- Hide the pickup if it bounces off screen
	if self.x < -6 then
		self.pickedUp = true
	elseif self.x > 406 then
		self.pickedUp = true
	elseif self.y < -10 then
		self.pickedUp = true
	elseif self.y > 262 then
		self.pickedUp = true
	end
end



--- This method creates sparkles for active pickups
function Pickup:handleSparkle()
	if not self.timer then
		self.timer = true
		self.ticker = math.random(GAME.fps, GAME.fps * 3)
		return
	end
	
	self.ticker = self.ticker - (30 * DELTA_TIME)
	
	if self.ticker <= 0 then
		Sparkle(self.x, self.y)
		self.timer = false
	end
end



--- Applies gravity to the pickup
function Pickup:applyGravity()
	self.yVelocity = self.yVelocity + (GRAVITY * DELTA_TIME)

	if self.touchingCeiling then
		self.yVelocity = 0
	end
end