local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Potion').extends(Pickup)



--- Initialise the potion object using the data given
--- @param  x  integer  The X coordinate to spawn the potion pickup
--- @param  y  integer  The Y coordinate to spawn the potion pickup
--- @param  e  object   The table of entities related to the potion
function Potion:init(x, y, e)
	-- Load the relevant potion table & get its length
	local p <const> = 'images/pickups/'
	local i <const> = p .. string.lower(e.name) .. '-table-16-16'
	local f <const> = e.name == 'Staminapotion' and 5 or 11

	-- Initialise the potion using the pickup class
	Potion.super.init(self, x, y, i, 2)

	-- Potion properties
	self.id = e.iid
	self.name = e.name
	self.xVelocity = 0
	self.yVelocity = 0
	self.weight = 20

	-- If the potion ID is on the don't spawn list, hide the potion
	if GAME.depletedEntities[self.id] then
		self:setVisible(false)
	end

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
	GAME.depletedEntities[self.id] = true
	self:setVisible(false)
end