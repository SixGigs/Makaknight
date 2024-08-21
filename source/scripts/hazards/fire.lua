-- Creating the Playdate Graphics Module as a Constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Fan Class
class("Fire").extends(AnimatedSprite)


--- Initialise the Fan Object Using the Data Given
--- @param  x  integer  The X coordinate to spawn the Fan
--- @param  y  integer  The Y coordinate to spawn the Fan
--- @param  e  table    The entity that come with the Fan
function Fire:init(x, y, time)
	-- Initialise the Fan Class
	Fire.super.init(self, gfx.imagetable.new("images/hazards/fire-table-16-16"))

	local seconds <const> = self:millisecondsToSeconds(time)

	-- Fan Animation Settings
	self:addState("burn", 1, 4)
	self:playAnimation()

	-- Fan Attributes
	self.damage = 20

	-- Fan Properties
	self:setCollideRect(0, 0, 16, 16)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:add()

	-- Delete After Set Amount of Time
	pd.timer.performAfterDelay(seconds, function()
		self:remove()
	end)
end


function Fire:millisecondsToSeconds(time)
	return time * 1000
end