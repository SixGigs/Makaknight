local gfx <const> = playdate.graphics
class('Pickup').extends(gfx.sprite)



--- Initialise the pickup object using the data given
--- @param x      integer The X coordinate to spawn the ability pick-up
--- @param y      integer The Y coordinate to spawn the ability pick-up
--- @param entity table   The table of entities related to the ability
function Pickup:init(x, y, entity)
	-- If the ability has been picked up don't spawn it
	self.id = entity.iid
	if g.picked_items[self.id] then
		self:setVisible(false)
	end

	-- If the ability hasn't been picked let's spawn it
	local abilityImage = gfx.image.new('images/pickups/' .. entity.name)
	assert(abilityImage)

	if entity.name == 'hp' then
		self.heals = entity.fields.heals
	end

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
	self:setCollideRect(4, 4, 8, 8)
	self:setImage(abilityImage)
	self:add()
end


--- This method handles the ability being picked up by the player
--- @param player table The player is passed into this function to manage the pick-up
function Pickup:pickUp(player)
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