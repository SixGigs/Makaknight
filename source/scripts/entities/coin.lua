local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Coin').extends(AnimatedSprite)



function Coin:init(g, x, y)
	local spin <const> = math.random(1, 5)

	Coin.super.init(self, 'images/entities/animated/coin-table-6-6')

	self:addState(1, 1, 8,  {ts = 1})
	self:addState(2, 9, 16, {ts = 1})
	self:addState(3, 17, 24, {ts = 1})
	self:addState(4, 25, 32, {ts = 1})
	self:addState(5, 33, 40, {ts = 1})
	self:addState('roll', 41, 48, {ts = 1})
	self:addState('flat', 6, 6)
	self:playAnimation()

	self.speed = 60
	self.gravity = g
	self.xVelocity = math.random(-self.speed, self.speed)
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.yVelocity = -280
	self.weight = 1

	self:changeState(spin)

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
	--self:handleState()
	self:handleMovementAndCollisions()
	self:applyGravity()
end



function Coin:handleMovementAndCollisions()
	local _, _, collisions, length = self:moveWithCollisions(self.x + (self.xVelocity * DELTA_TIME), self.y + (self.yVelocity * DELTA_TIME))

	self.touchingGround = false
	self.touchingWall = false

	for i = 1, length do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		local collisionObject <const> = collision.other
		local collisionTag <const> = collisionObject:getTag()

		if collisionType == gfx.sprite.kCollisionTypeSlide then
			if collision.normal.y == -1 then
				if self.yVelocity > 90 then
					local low <const> = math.floor(self.yVelocity / 2, 0.5)
					local high <const> = math.floor(self.yVelocity, 0.5)
	
					self.yVelocity = -math.random(low, high)
					self.xVelocity = math.random(-self.speed, self.speed)

					self:changeState(math.random(1, 5))
				else
					if self.currentState ~= 'flat' then
						self.xVelocity = 0
	
						self:changeState('flat')
					end

					self.yVelocity = 0
				end
			elseif collision.normal.y == 1 then
				self.touchingCeiling = true
			end

			if collision.normal.x ~= 0 then
				self.touchingWall = true
			end
		end

		if collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		end
	end

	-- Make the coin spin the direction it is travelling in horizontally
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- If the coin velocity is greater than 90 and was flat it goes faster
	if self.yVelocity > 60 and self.currentState == 'flat' then
		self:changeState(math.random(1, 5))
	end
end



function Coin:handleCollision(e)
	local collisionTag <const> = e:getTag()

	if collisionTag == TAGS.Player then
		if not e.dead then
			if e.currentState ~= 'dash' and e.currentState ~= 'dive' then
				local text <const> = '$ ' .. tostring(GAME.playerCoins)
				GAME.playerCoins = GAME.playerCoins + 1
				Text(text, 'right', 0)
				self:remove()
			end
		end
	end
end



function Coin:applyGravity()
	self.yVelocity = self.yVelocity + (self.gravity * DELTA_TIME)
end