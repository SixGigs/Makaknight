-- Creating the playdate graphics module as a constant
local gfx <const> = playdate.graphics

-- Create the spike class
class("Spike").extends(gfx.sprite)


--- Initialise the spike object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Spike:init(x, y, entity)
	-- Open the spike image as a constant
	local spikeImage <const> = gfx.image.new("images/hazards/spike")

	self.damage = entity.fields.damage

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:setCollideRect(2, 14, 12, 2)
	self:setImage(spikeImage)
	self:add()
end