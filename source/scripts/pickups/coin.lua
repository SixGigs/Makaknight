local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Coin').extends(Pickup)



--- Initialise the coin object using the data given
--- @param  x  integer  The X coordinate to spawn the coin pickup
--- @param  y  integer  The Y coordinate to spawn the coin pickup
function Coin:init(x, y, ...)
	-- Choose a random animation & spawn jump height
	local i <const> = 'coin-table-6-6'
	local e <const> = ...

	-- Initialise the AnimatedSprite library
	Coin.super.init(self, x, y, i, e)

	-- Generalised coin class properties
	self.weight = 1

	-- Playdate sprite details
	self:setCollideRect(1, 1, 4, 4)
end