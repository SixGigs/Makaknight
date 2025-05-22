local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Coin').extends(Pickup)

-- An array of spinning coin states
local spinStates <const> = {
	[0] = true,
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true
}



--- Initialise the coin object using the data given
--- @param  x  integer  The X coordinate to spawn the coin pickup
--- @param  y  integer  The Y coordinate to spawn the coin pickup
function Coin:init(x, y)
	-- Choose a random animation & spawn jump height
	local i <const> = 'images/pickups/coin-table-6-6'
	local s <const> = math.random(0, 4)
	local j <const> = math.random(180, 240)

	-- Initialise the AnimatedSprite library
	Coin.super.init(self, x, y, i)

	-- Add coin animation states & start playing
	self:addState(0, 1, 8,  {ts = 1})
	self:addState(1, 9, 16, {ts = 1})
	self:addState(2, 17, 24, {ts = 1})
	self:addState(3, 25, 32, {ts = 1})
	self:addState(4, 33, 40, {ts = 1})
	self:addState('flat', 6, 6)
	self:changeState(s)
	self:playAnimation()

	-- Generalised coin class properties
	self.id = 123
	self.speed = 60
	self.xVelocity = math.random(-self.speed, self.speed)
	self.yVelocity = -j
	self.weight = 1

	-- Playdate sprite details
	self:setCollideRect(1, 1, 4, 4)
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

			self:changeState(math.random(0, 4))
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