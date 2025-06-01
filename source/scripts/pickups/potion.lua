local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Potion').extends(Pickup)



--- Initialise the potion object using the data given
--- @param  x  integer  The X coordinate to spawn the potion pickup
--- @param  y  integer  The Y coordinate to spawn the potion pickup
--- @param  e  object   The table of entities related to the potion
function Potion:init(x, y, i, ...)
	-- Load the relevant potion table & get its length
	local e <const> = ...

	-- Initialise the potion using the pickup class
	Potion.super.init(self, x, y, i, e)

	-- Potion properties
	self.weight = 20

	-- Sprite properties
	self:setCollideRect(4, 2, 8, 14)
end