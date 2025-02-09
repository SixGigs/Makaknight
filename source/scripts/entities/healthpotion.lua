local gfx <const> = playdate.graphics
class('Healthpotion').extends(AnimatedSprite)



--- Initialise the pickup object using the data given
--- @param x      integer The X coordinate to spawn the ability pick-up
--- @param y      integer The Y coordinate to spawn the ability pick-up
--- @param e table   The table of entities related to the ability
function Healthpotion:init(x, y, e)
	-- Initialise the class
	Healthpotion.super.init(self, gfx.imagetable.new('images/pickups/healthpotion-table-16-16'))

	-- If the ability has been picked up don't spawn it
	self.id = e.iid
	if g.picked_items[self.id] then
		self:setVisible(false)
	end

	-- Animation settings
	self:addState(0, 1, 11, {ts = 2})
	self:playAnimation()

	-- Properties
	self.heals = e.fields.heals

	-- Sprite properties
	self:setCollideRect(4, 4, 8, 8)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
	self:add()
end


--- This method handles the ability being picked up by the player
--- @param player table The player is passed into this function to manage the pick-up
function Healthpotion:pickUp(player)
	if not self:isVisible() then
		return
	end

	player.hp = player.hp + self.heals
	if player.hp > 100 then
		player.hp = 100
	end

	g.picked_items[self.id] = true
	self:setVisible(false)
end