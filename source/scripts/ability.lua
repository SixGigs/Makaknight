-- Create the script constants
local gfx <const> = playdate.graphics

-- Create the ability class
class('Ability').extends(gfx.sprite)


--- Initialise the ability object using the data given
--- @param x      integer The X coordinate to spawn the ability pick-up
--- @param y      integer The Y coordinate to spawn the ability pick-up
--- @param entity table   The table of entities related to the ability
function Ability:init(x, y, entity)
	self.fields = entity.fields
	if self.fields.pickedUp then
		return
	end

	self.abilityName = self.fields.ability
	local abilityImage = gfx.image.new("images/"..self.abilityName)
	assert(abilityImage)
	self:setImage(abilityImage)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:add()

	self:setTag(TAGS.Pickup)
	self:setCollideRect(0, 0, self:getSize())
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