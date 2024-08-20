-- Creating the Playdate Graphics Module as a Constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Wind Class
class("Wind").extends(gfx.sprite)


--- Initialise the Wind Entity Using the Data Given
function Wind:init(x, y)
	self:moveTo(x, y)
	self:setCollideRect(0, 0, 48, 88)
	self:setZIndex(Z_INDEXES.Wind)
	self:setTag(TAGS.Wind)
	self:add()
end