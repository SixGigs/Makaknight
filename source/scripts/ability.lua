-- Create the script constants
local gfx <const> = playdate.graphics

-- Create the ability class
class("Ability").extends(gfx.sprite)


--- Initialise the ability object using the data given
--- @param x      integer The X coordinate to spawn the ability pick-up
--- @param y      integer The Y coordinate to spawn the ability pick-up
--- @param entity table   The table of entities related to the ability
function Ability:init(x, y, entity)
	-- If the ability has been picked up don't spawn it
	self.fields = entity.fields
	if self.fields.pickedUp then
		return
	end

	-- If the ability hasn't been picked let's spawn it
	self.abilityName = self.fields.ability
	local abilityImage = gfx.image.new("images/abilities/"..self.abilityName)
	assert(abilityImage)

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
	self:setCollideRect(0, 0, self:getSize())
	self:setImage(abilityImage)
	self:add()
end


--- This method handles the ability being picked up by the player
--- @param player table The player is passed into this function to manage the pick-up
function Ability:pickUp(player)
	if self.abilityName == "DoubleJump" then
		player.doubleJumpAbility = true
	elseif self.abilityName == "Dash" then
		player.dashAbility = true
	end

	self.fields.pickedUp = true
	self:remove()
end