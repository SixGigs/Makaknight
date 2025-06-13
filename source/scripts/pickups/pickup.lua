local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Pickup').extends(AnimatedSprite)

-- An array of tags potions can overlap
local overlapTags <const> = {
	[TAGS.Animal] = true,
	[TAGS.Bubble] = true,
	[TAGS.Door] = true,
	[TAGS.Fragile] = true,
	[TAGS.Gui] = true,
	[TAGS.Half] = true,
	[TAGS.Hitbox] = true,
	[TAGS.Hazard] = true,
	[TAGS.Player] = true,
	[TAGS.Wind] = true,
	[TAGS.Pickup] = true
}

-- An array of pickups & their animation speeds
local spinSpeeds <const> = {
	['coin-table-6-6'] = 1,
	['healthpotion-table-16-16'] = 2,
	['staminapotion-table-16-16'] = 2,
	['manapotion-table-16-16'] = 2
}

local flatSpeeds <const> = {
	['coin-table-6-6'] = 15,
	['healthpotion-table-16-16'] = 2,
	['staminapotion-table-16-16'] = 2,
	['manapotion-table-16-16'] = 2
}

-- A pickup MUST have 4 spin states
local spinStates <const> = {
	[0] = true,
	[1] = true,
	[2] = true,
	[3] = true
}



--- This class is inherited to create pickup items
--- @param  x  integer  The X coordinate of the pickup
--- @param  y  integer  The Y coordinate of the pickup
--- @param  i  string   The pickup image table path
--- @param  s  integer  The pickup spin tick speed
function Pickup:init(x, y, i, ...)
	local p <const> = 'images/pickups/'
	local e <const> = ...
	local s <const> = spinSpeeds[i]
	local f <const> = flatSpeeds[i]

	-- Initialise the AnimatedSprite library
	Pickup.super.init(self, p .. i)

	-- Set the pickup image states
	self:addState(0, 1, 8, {ts = s})
	self:addState(1, 9, 16, {ts = s})
	self:addState(2, 17, 24, {ts = s})
	self:addState(3, 25, 32, {ts = s})
	self:addState('shine', 33, 40, {ts = 2, l = 1, na = 'flat'})
	self:addState('flat', 41, nil, {ts = f, l = 3, na = 'shine'}, true)

	-- Spawn a sparkle when the pickup finishes shining
	self.states['shine'].onAnimationEndEvent = function(self)
		Sparkle(self.x + (self.width / 2), self.y + (self.height / 2))
	end

	-- Pickup class properties
	self.speed = 60
	self.invulnFrames = 5
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.spawnX = x
	self.spawnY = y

	-- Additional variables if an entity is given
	if e then	
		self.id = e['iid']
		self.xVelocity = 0
		self.yVelocity = 0

		-- If the pickup is on the don't spawn list, hide the coin
		if GAME.depletedEntities[self.id] then
			self:setVisible(false)
		end
	else
		local j <const> = math.random(180, 240)

		self.xVelocity = math.random(-self.speed, self.speed)
		self.yVelocity = -j
	end

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

	-- Subtract invulnerability frames if the pickup is invulnerable
	if self.invulnFrames > 0 then
		self.invulnFrames = self.invulnFrames - (30 * DELTA_TIME)
	end

	self:updateAnimation()
	self:handleState()
	self:handleMovementAndCollisions()
end



--- This method handles states for pickups
function Pickup:handleState()
	if spinStates[self.currentState] then
		self:handleSpinState()
		self:applyGravity()
	else
		self:handleFlatState()
		self:applyGravity()
	end
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



--- This method handles potions bouncing until it lands
function Pickup:handleSpinState()
	if self.touchingGround then
		if self.yVelocity > 90 then
			local low <const> = math.floor((self.yVelocity / 4) * 3, 0.5)
			local high <const> = math.floor(self.yVelocity, 0.5)

			self.yVelocity = -math.random(low, high)
			self.xVelocity = math.random(-self.speed, self.speed)

			Sparkle(self.x + (self.width / 2), self.y + (self.height / 2))

			self:changeState(math.random(0, #spinStates))
		else
			self.xVelocity = 0
			self.yVelocity = 0
			self:changeState('flat')
		end
	end
end



--- This method handles potions bouncing until it lands
function Pickup:handleFlatState()
	if self.touchingGround then
		self.yVelocity = 0
	end

	if self.yVelocity > 90 then
		self:changeState(0)
	elseif self.yVelocity < 0 then
		self:changeState(math.random(0, #spinStates))
	end
end



--- This method handles pickup movement and collisions
function Pickup:handleMovementAndCollisions()
	local xMov <const> = self.x + (self.xVelocity * DELTA_TIME)
	local yMov <const> = self.y + (self.yVelocity * DELTA_TIME)
	local _, _, collisions, length <const> = self:moveWithCollisions(xMov, yMov)

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
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Bubble then
			collisionObject:handleCollision(self)
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
		self:setVisible(false)
	elseif self.x > 406 then
		self:setVisible(false)
	elseif self.y < -10 then
		self:setVisible(false)
	elseif self.y > 262 then
		self:setVisible(false)
	end
end



--- This method handles entities colliding with the pickup
--- @param  e  table  The entity colliding with the pickup
function Pickup:handleCollision(e)
	if not self:isVisible() then return end

	-- Get the tag of the colliding object
	local collisionTag <const> = e:getTag()
	if collisionTag == TAGS.Player then
		if not e.dead and self.invulnFrames < 0 then
			if self:isa(Healthpotion) then
				e.hp = e.maxHP
			elseif self:isa(Staminapotion) then
				e.sp = e.maxSP
			elseif self:isa(Manapotion) then
				e.mp = e.maxMP
			else
				GAME.playerCoins = GAME.playerCoins + 1
				local text <const> = '$ ' .. tostring(GAME.playerCoins)
				Text(text, 'right', 0)
			end

			Sparkle(self.x + (self.width / 2), self.y + (self.height / 2))

			if self.id then
				GAME.depletedEntities[self.id] = true
				self:setVisible(false)
			else
				self:remove()
			end
		end
	end
end



--- This method is called to reset a pickup
function Pickup:reset()
	self.xVelocity = 0
	self.yVelocity = 0

	self:moveTo(self.spawnX, self.spawnY)
	self:setVisible(true)
end



--- Applies gravity to the pickup
function Pickup:applyGravity()
	self.yVelocity = self.yVelocity + ((GRAVITY + self.weight) * DELTA_TIME)

	if self.touchingCeiling then
		self.yVelocity = 0
	end
end