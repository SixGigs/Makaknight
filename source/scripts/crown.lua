local gfx <const> = playdate.graphics
class('Crown').extends(AnimatedSprite)

--- The prop class is used to spawn entities that are decoration
--- @param  x  integer The X coordinate to spawn the spike
--- @param  y  integer The Y coordinate to spawn the spike
function Crown:init(x, y, e)
	-- Find and open the image to use as a prop
	Crown.super.init(self, gfx.imagetable.new("images/entities/crown-table-48-48"))

	-- Crown states, sprites, and animation speeds
	self:addState("spin", 1, 32, {ts = 1})
	self:playAnimation()

	-- A possible level & coordinate to move the player to
	self.level = e.fields.level
	self.exitX = e.fields.exitX * 16 + 16
	self.exitY = e.fields.exitY * 16 + 8

	-- Crown properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Crown)
	self:setTag(TAGS.Crown)
	self:setCollideRect(8, 8, 32, 32)
	self:add()
end