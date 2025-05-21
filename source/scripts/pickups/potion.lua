local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Potion').extends(AnimatedSprite)

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



--- Initialise the pickup object using the data given
--- @param  x  integer  The X coordinate to spawn the ability pick-up
--- @param  y  integer  The Y coordinate to spawn the ability pick-up
--- @param  e  object   The table of entities related to the ability
function Potion:init(x, y, e)
	-- Load the relevant potion table & get its length
	local image <const> = 'images/pickups/'..string.lower(e.name)..'-table-16-16'
	local table <const> = gfx.imagetable.new(image)
	local loop <const> = table:getLength()

	-- Initialise the AnimatedSprite library
	Potion.super.init(self, image)

	-- Add the potion animation state & start playing
	self:addState(0, 1, loop, {ts = 3})
	self:playAnimation()

	-- Potion properties
	self.id = e.iid
	self.name = e.name
	self.ticker = 0
	self.timer = false
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.xVelocity = 0
	self.yVelocity = 0
	self.weight = 20

	-- If the potion ID is on the don't spawn list, hide the potion
	if GAME.depletedEntities[self.id] then
		self:setVisible(false)
	end

	-- Sprite properties
	self:setCollideRect(4, 8, 8, 8)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
end



-- This method handles collision responses
function Potion:collisionResponse(e)
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



--- This function runs every game tick and handles potion bottle behaviour
function Potion:update()
	self:updateAnimation()
	
	if self:isVisible() then
		self:handleState()
		self:handleMovementAndCollisions()
		self:applyGravity()
	end
end



--- This method handles potion behaviour if the potion is visible
function Potion:handleState()
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



--- This method handles potion movement and collisions
function Potion:handleMovementAndCollisions()
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

		-- Process the collision based on the collision tag
		if collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Fragile then
			collisionObject:handleCollision(self, collision)
		end
	end

	-- Make the potion direction change on xVelocity
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- Hide the potion if it bounces off screen
	if self.x < -6 then
		GAME.depletedEntities[self.id] = true
		self:setVisible(false)
	elseif self.x > 406 then
		GAME.depletedEntities[self.id] = true
		self:setVisible(false)
	elseif self.y < -10 then
		GAME.depletedEntities[self.id] = true
		self:setVisible(false)
	elseif self.y > 262 then
		GAME.depletedEntities[self.id] = true
		self:setVisible(false)
	end
end



--- This method handles the ability being picked up by the player
--- @param  e  table  The player is passed into this function to manage the pick-up
function Potion:handleCollision(e)
	if not self:isVisible() then
		return
	end

	if self.name == 'Healthpotion' then
		e.hp = e.maxHP
	elseif self.name == 'Staminapotion' then
		e.sp = e.maxSP
	else
		e.mp = e.maxMP
	end

	Sparkle(self.x + 8, self.y + 8)
	GAME.depletedEntities[self.id] = true
	self:setVisible(false)
end



--- Applies gravity to the potion
function Potion:applyGravity()
	self.yVelocity = self.yVelocity + (GRAVITY * DELTA_TIME)

	if self.touchingCeiling or self.touchingGround then
		self.yVelocity = 0
	end
end