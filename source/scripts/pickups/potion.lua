local gfx <const> = playdate.graphics
class('Potion').extends(AnimatedSprite)



--- Initialise the pickup object using the data given
--- @param  x  integer  The X coordinate to spawn the ability pick-up
--- @param  y  integer  The Y coordinate to spawn the ability pick-up
--- @param  e  object   The table of entities related to the ability
function Potion:init(x, y, e)
	-- Initialise the class
	Potion.super.init(self, gfx.imagetable.new('images/pickups/' .. string.lower(e.name) .. '-table-16-16'))

	-- Potion properties
	self.id = e.iid
	self.restore_hp = e.fields.restore_hp and e.fields.restore_hp or 0
	self.restore_sp = e.fields.restore_sp and e.fields.restore_sp or 0
	self.restore_mp = e.fields.restore_mp and e.fields.restore_mp or 0

	-- If the potion ID is on the don't spawn list, hide the potion
	if g.picked_items[self.id] then
		self:setVisible(false)
	end

	-- Sprite properties
	self:setCollideRect(2, 12, 12, 4)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
	self:add()
end



--- This method handles the ability being picked up by the player
--- @param player table The player is passed into this function to manage the pick-up
function Potion:pickUp(e)
	if not self:isVisible() then
		return
	end

	e.hp = e.hp + self.restore_hp
	if e.hp > 100 then
		e.hp = 100
	end

	e.sp = e.sp + self.restore_sp
	if e.sp > 100 then
		e.sp = 100
	end

	e.mp = e.mp + self.restore_mp
	if e.mp > 100 then
		e.mp = 100
	end

	g.picked_items[self.id] = true
	self:setVisible(false)
end