-- Creating the playdate graphics module as a constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the hit box class
class('Hitbox').extends(gfx.sprite)

--- Initialise the hit box object using the data given
function Hitbox:init(x, y, width, height, duration)		
	-- Create the hit box sprite
	self:moveTo(x, y)
	self:setCollideRect(0, 0, width, height)
	self:setTag(TAGS.Hitbox)
	self:setZIndex(Z_INDEXES.Hitbox)
	self:add()

	-- Start a timer to deactivate the hit box after the specified duration
	pd.timer.performAfterDelay(duration, function()
		self:remove()
	end)
end