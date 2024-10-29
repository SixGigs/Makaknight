local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Half').extends(gfx.sprite)

function Half:init(x, y, w, h)
	self:moveTo(x, y)
	self:setCollideRect(0, 0, w, h)
	self:setTag(TAGS.Halftile)
	self:setZIndex(0)
	self:add()
end