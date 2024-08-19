-- Creating the playdate graphics module as a constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the hit box class
class("Wind").extends(gfx.sprite)

--- Initialise the hit box object using the data given
function Wind:init(x, y)		
	-- Create the hit box sprite
	self:moveTo(x, y)
	self:setCollideRect(0, 0, 32, 240)
	self:setTag(TAGS.Wind)
	self:setZIndex(Z_INDEXES.Wind)
	self:add()
end