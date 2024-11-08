local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Crown').extends(AnimatedSprite)

--- The prop class is used to spawn entities that are decoration
--- @param  x  integer The X coordinate to spawn the spike
--- @param  y  integer The Y coordinate to spawn the spike
function Crown:init(x, y)
	-- Find and open the image to use as a prop
	Crown.super.init(self, gfx.imagetable.new('images/entities/animated/crown-table-48-48'))

	-- Crown states, sprites, and animation speeds
	self:addState(0, 1, 32, {ts = 1})
	self:playAnimation()

	-- Properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Crown)
	self:setTag(TAGS.Crown)
	self:setCollideRect(8, 8, 32, 32)
	self:add()
end



function Crown:handleCollision(e)
	if not g.won then
		g.won = true
		g:switchScene(Win, 'fade')
		self:setVisible(false)
	end
end