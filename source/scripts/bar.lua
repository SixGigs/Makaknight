-- Playdate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the bar class
class('Bar').extends(gfx.sprite)

function Bar:init(x, y, hp)
	local img <const> = gfx.image.new("images/player/hitpoint")

	gfx.lockFocus(img)
	gfx.drawRect(33, 2, hp, 5)
	gfx.fillRect(33, 6, hp, 8)
	gfx.unlockFocus()

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Bar)
	self:setTag(TAGS.Bar)
	self:setImage(img)
	self:setCollideRect(0, 0, 128, 8)
	self:add()
end