local pd <const> = playdate
local gfx <const> = playdate.graphics

-- An array of tags the coin hit box can overlap with
local overlapTags <const> = {
	[TAGS.Animal] = true,
	[TAGS.Door] = true,
	[TAGS.Hitbox] = true,
	[TAGS.Gui] = true,
	[TAGS.Wind] = true,
	[TAGS.Coin] = true,
	[TAGS.Player] = true,
	[TAGS.Fragile] = true,
	[TAGS.Half] = true
}

-- An array of spinning coin states
local spinStates <const> = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true
}

class('Coin').extends(AnimatedSprite)


--- This class is used to create a coin for the player to collect
--- @param  g  integer  The value of gravity in the current room
--- @param  x  integer  The X coordinate to spawn the coin at
--- @param  y  integer  The Y coordinate to spawn the coin at
function Coin:init(g, x, y)
	-- Choose a random animation & spawn jump height
	local spin <const> = math.random(1, 5)
	local jump <const> = math.random(180, 240)

	-- Initialise the AnimatedSprite library
	Coin.super.init(self, 'images/entities/animated/coin-table-6-6')

	-- Add coin animation states & start playing
	self:addState(1, 1, 8,  {ts = 1})
	self:addState(2, 9, 16, {ts = 1})
	self:addState(3, 17, 24, {ts = 1})
	self:addState(4, 25, 32, {ts = 1})
	self:addState(5, 33, 40, {ts = 1})
	self:addState('flat', 6, 6)
	self:changeState(spin)
	self:playAnimation()

	-- Generalised coin class properties
	self.timer = false
	self.ticker = 0
	self.speed = 60
	self.gravity = g
	self.xVelocity = math.random(-self.speed, self.speed)
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.touchingCeiling = false
	self.yVelocity = -jump
	self.weight = 1

	-- Playdate sprite details
	self:setCollideRect(1, 1, 4, 4)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Coin)
	self:setTag(TAGS.Coin)
end



--- This method handles collision responses
function Coin:collisionResponse(e)
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



--- This function runs every game tick and handles coin behaviour
function Coin:update()
	self:updateAnimation()
	self:handleState()
	self:handleMovementAndCollisions()
end



--- This method handles coin behaviour for each state
function Coin:handleState()
	if spinStates[self.currentState] then
		self:handleSpinState()
		self:applyGravity()
	else
		self:handleFlatState()
	end
end



--- This method handles coin collisions
function Coin:handleMovementAndCollisions()
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
		end
	end

	-- Make the coin direction change on xVelocity
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- Delete the coin if it bounces off screen
	if self.x < -6 then
		self:remove()
	elseif self.x > 406 then
		self:remove()
	elseif self.y < -10 then
		self:remove()
	elseif self.y > 262 then
		self:remove()
	end
end



--- This method handles coin bouncing until the coin lands flat
function Coin:handleSpinState()
	if self.touchingGround then
		if self.yVelocity > 90 then
			local low <const> = math.floor(self.yVelocity / 2, 0.5)
			local high <const> = math.floor((self.yVelocity / 4) * 3, 0.5)

			self.yVelocity = -math.random(low, high)
			self.xVelocity = math.random(-self.speed, self.speed)

			local n <const> = math.random(0, 1)
			if n == 1 then
				Sparkle(self.x, self.y)
			end

			self:changeState(math.random(1, 5))
		else
			self.xVelocity = 0
			self.yVelocity = 0
			self:changeState('flat')
		end
	end
end



--- This method handles the coin when it's flat to see if if sparkles
function Coin:handleFlatState()
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



--- This method is called by an entity when it collides with the coin
function Coin:handleCollision(e)
	local collisionTag <const> = e:getTag()

	-- Collect the coin if the entity is a player
	if collisionTag == TAGS.Player then
		if not e.dead then
			if e.currentState ~= 'dash' and e.currentState ~= 'dive' then
				GAME.playerCoins = GAME.playerCoins + 1

				local text <const> = '$ ' .. tostring(GAME.playerCoins)

				Text(text, 'right', 0)
				Sparkle(self.x, self.y)

				self:remove()
			end
		end
	end
end



--- Applies gravity to the coin
function Coin:applyGravity()
	if self.currentState == 'flat' then
		return
	end

	self.yVelocity = self.yVelocity + (self.gravity * DELTA_TIME)

	if self.touchingCeiling then
		self.yVelocity = 0
	end
end