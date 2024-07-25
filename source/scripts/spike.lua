-- Creating the playdate graphics module as a constant
local gfx <const> = playdate.graphics

-- Create the spike class
class("Spike").extends(gfx.sprite)


--- Initialise the spike object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Spike:init(x, y, e)
	local spikeImage <const> = gfx.image.new("images/hazards/" .. e.name) -- Open the spike image as a local constant

	self.damage = e.fields.damage

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)

	if e.name == "Stalactite" or e.name == "Roofspike" then
		self:setCollideRect(2, 1, 12, 2)
	else
		self:setCollideRect(2, 14, 12, 2)
	end

	self:setImage(spikeImage)
	self:add()
end