local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Coin').extends(Pickup)



--- Initialise the coin object using the data given
--- @param  x  integer  The X coordinate to spawn the coin pickup
--- @param  y  integer  The Y coordinate to spawn the coin pickup
function Coin:init(x, y)
	-- Choose a random animation & spawn jump height
	local i <const> = 'images/pickups/coin-table-6-6'
	local j <const> = math.random(180, 240)

	-- Initialise the AnimatedSprite library
	Coin.super.init(self, x, y, i, 1)

	-- Generalised coin class properties
	self.id = 123
	self.xVelocity = math.random(-self.speed, self.speed)
	self.yVelocity = -j
	self.weight = 1

	-- Playdate sprite details
	self:setCollideRect(1, 1, 4, 4)
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