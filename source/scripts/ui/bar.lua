-- Playdate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the bar class
class('Bar').extends(gfx.sprite)

function Bar:init(x, y)
	local img <const> = gfx.image.new("images/ui/bars")

	gfx.lockFocus(img)
	gfx.drawRect(33, 2, g.player_hp, 5)
	gfx.fillRect(33, 6, g.player_hp, 8)
	gfx.drawRect(33, 19, g.player_sp, 4)
	gfx.fillRect(33, 22, g.player_sp, 8)
	gfx.unlockFocus()

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.GUI)
	self:setTag(TAGS.GUI)
	self:setImage(img)
	self:setCollideRect(0, 0, 128, 24)
	self:add()
end