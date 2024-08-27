-- Playdate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the bar class
class('Background').extends(gfx.sprite)

function Background:init(x, y, bg)
	local img <const> = gfx.image.new("levels/" .. bg)

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Background)
	self:setImage(img)
	self:add()
end