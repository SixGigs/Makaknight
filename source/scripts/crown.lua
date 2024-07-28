-- Create playdate graphics as a constant for props
local gfx <const> = playdate.graphics

-- Create the Prop class
class("Crown").extends(AnimatedSprite)

--- The prop class is used to spawn entities that are decoration
--- @param x          integer The X coordinate to spawn the spike
--- @param y          integer The Y coordinate to spawn the spike
--- @param entityName string  The name of the entity to create as a prop
function Crown:init(x, y)
	-- Find and open the image to use as a prop
	Crown.super.init(self, gfx.imagetable.new("images/entities/crown-table-48-48"))

	-- Crown states, sprites, and animation speeds
	self:addState("spin", 1, 32, {ts = 1})
	self:playAnimation()

	-- Crown properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Crown)
	self:setTag(TAGS.Crown)
	self:setCollideRect(16, 16, 16, 16)
	self:add()
end