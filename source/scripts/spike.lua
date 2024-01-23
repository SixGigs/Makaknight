-- Creating the script constants
local gfx <const> = playdate.graphics
local spikeImage <const> = gfx.image.new("images/spike")

-- Create the spike class
class('Spike').extends(gfx.sprite)

--- Initialise the spike object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Spike:init(x, y)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:setCollideRect(2, 9, 12, 7)
	self:setImage(spikeImage)
	self:add()
end