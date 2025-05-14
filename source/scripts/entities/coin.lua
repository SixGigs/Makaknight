local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Coin').extends(AnimatedSprite)



function Coin:init(g, x, y)
	local animation <const> = math.random(1, 5)
	local jump <const> = math.random(180, 240)

	-- Initialise the AnimatedSprite library
	Coin.super.init(self, 'images/entities/animated/coin-table-6-6')

	-- Add coin animation states & start playing
	self:addState(1, 1, 8,  {ts = 1})
	self:addState(2, 9, 16, {ts = 1})
	self:addState(3, 17, 24, {ts = 1})
	self:addState(4, 25, 32, {ts = 1})
	self:addState(5, 33, 40, {ts = 1})
	self:addState('roll', 41, 48, {ts = 1})
	self:addState('flat', 6, 6)
	self:changeState(animation)
	self:playAnimation()

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
	self.overlapTags = {
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
	self.spinStates = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true
	}

	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Coin)
	self:setTag(TAGS.Coin)
	self:setCollideRect(1, 1, 4, 4)
end



function Coin:collisionResponse(e)
	local tag <const> = e:getTag()

	if self.overlapTags[tag] then
		if tag == TAGS.Fragile or tag == TAGS.Half then
			return e:collision(self)
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	return gfx.sprite.kCollisionTypeSlide
end



function Coin:update()
	self:updateAnimation()
	self:handleState()
	self:handleMovementAndCollisions()
end



function Coin:handleState()
	if self.spinStates[self.currentState] then
		if self.touchingGround then
			if self.yVelocity > 90 then
				local low <const> = math.floor(self.yVelocity / 2, 0.5)
				local high <const> = math.floor(self.yVelocity, 0.5)

				self.yVelocity = -math.random(low, high)
				self.xVelocity = math.random(-self.speed, self.speed)

				local n <const> = math.random(0, 1)
				if n == 1 then
					Effect(self.x, self.y)
				end

				self:changeState(math.random(1, 5))
			else
				if self.currentState ~= 'flat' then
					self.xVelocity = 0
					self:changeState('flat')
				end

				self.yVelocity = 0
			end
		end

		self:applyGravity()
	else
		if self.timer then
			if self.ticker > 0 then
				self.ticker = self.ticker - (30 * DELTA_TIME)
			else
				Effect(self.x, self.y)
				self.timer = false
			end

			return
		end

		self.timer = true
		self.ticker = math.random(GAME.fps * 2, GAME.fps * 3)
	end
end



function Coin:handleMovementAndCollisions()
	local xMovement <const> = self.x + (self.xVelocity * DELTA_TIME)
	local yMovement <const> = self.y + (self.yVelocity * DELTA_TIME)
	local _, _, collisions, length <const> = self:moveWithCollisions(xMovement, yMovement)

	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	local depleted = false

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
		depleted = true
	elseif self.x > 406 then
		depleted = true
	elseif self.y < -10 then
		depleted = true
	elseif self.y > 262 then
		depleted = true
	end

	-- If the coin is removed then remove
	if depleted then self:remove() end
end



function Coin:handleCollision(e)
	local collisionTag <const> = e:getTag()

	if collisionTag == TAGS.Player then
		if not e.dead then
			if e.currentState ~= 'dash' and e.currentState ~= 'dive' then
				GAME.playerCoins = GAME.playerCoins + 1

				local text <const> = '$ ' .. tostring(GAME.playerCoins)
				Text(text, 'right', 0)

				Effect(self.x, self.y)
				self:remove()
			end
		end
	end
end



function Coin:applyGravity()
	self.yVelocity = self.yVelocity + (self.gravity * DELTA_TIME)

	if self.touchingCeiling then
		self.yVelocity = 0
	end
end