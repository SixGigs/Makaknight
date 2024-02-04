-- Creating the script constants
local gfx <const> = playdate.graphics

-- Create the light rock class
class('Prop').extends(gfx.sprite)

--- Initialise the tree object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Prop:init(x, y, entity)
	-- If the ability has been picked up don't spawn it
	self.fields = entity.fields

	-- If the ability hasn't been picked let's spawn it
	self.prop = self.fields.prop
	local propImage = gfx.image.new("images/"..self.prop)
	assert(propImage)

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	self:setImage(propImage)
	self:add()
end