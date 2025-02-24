local gfx <const> = playdate.graphics
class('Background').extends(gfx.sprite)


function Background:init(x, y, bg)
	local i <const> = gfx.image.new('levels/' .. bg)

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Background)
	self:setImage(i)
	self:add()
end