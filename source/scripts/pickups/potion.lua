local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Potion').extends(Pickup)



--- Initialise the potion object using the data given
--- @param  x  integer  The X coordinate to spawn the potion pickup
--- @param  y  integer  The Y coordinate to spawn the potion pickup
--- @param  e  object   The table of entities related to the potion
function Potion:init(x, y, ...)
	-- Load the relevant potion table & get its length
	local e <const> = ...
	local i <const> = string.lower(e.name) .. '-table-16-16'

	-- Initialise the potion using the pickup class
	Potion.super.init(self, x, y, i, e)

	-- Potion properties
	self.name = e.name
	self.weight = 20

	-- Sprite properties
	self:setCollideRect(4, 2, 8, 14)
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

	if self.id then
		GAME.depletedEntities[self.id] = true
		self:setVisible(false)
	else
		self:remove()
	end
end