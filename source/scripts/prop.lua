-- Create playdate graphics as a constant for props
local gfx <const> = playdate.graphics

-- Create the Prop class
class('Prop').extends(gfx.sprite)

--- The prop class is used to spawn entities that are decoration
--- @param x          integer The X coordinate to spawn the spike
--- @param y          integer The Y coordinate to spawn the spike
--- @param entityName string  The name of the entity to create as a prop
function Prop:init(x, y, name)
	-- Find and open the image to use as a prop
	local image <const> = gfx.image.new("images/"..name)

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	self:setImage(image)
	self:add()
end