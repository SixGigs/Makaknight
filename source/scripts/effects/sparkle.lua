local pd <const> = playdate
local gfx <const> = playdate.graphics
local path <const> = 'images/effects/sparkles/'

-- A script local constant array of sparkle tables
local sparkle <const> = {
	[1] = 'sparkle1-table-15-21',
	[2] = 'sparkle2-table-13-23',
	[3] = 'sparkle3-table-21-21',
	[4] = 'sparkle4-table-21-21',
	[5] = 'sparkle5-table-19-26'
}

class('Sparkle').extends(AnimatedSprite)



--- This class is used to create the sparkle particle effect
--- @param  x  integer  The X coordinate to spawn the sparkle at
--- @param  y  integer  The Y coordinate to spawn the sparkle at
function Sparkle:init(x, y)
	-- Local constant used to choose the sparkle animation
	local n <const> = math.random(1, 5)

	-- Initialise the sparkle effect with the AnimatedSprite library
	Sparkle.super.init(self, path .. sparkle[n]) 
	
	-- Make the sparkle effect animation state & play it
	self:addState(1, 1, 7, {ts = 1, l = 1})
	self:playAnimation()

	-- When the animation finishes, delete itself
	self.states[1].onAnimationEndEvent = function(self)
		self:remove()
	end

	-- This gives the sparkle effect a small amount of spawn variation
	x = math.random(math.floor(x - 5, 0.5), math.floor(x + 5, 0.5))
	y = math.random(math.floor(y - 5, 0.5), math.floor(y + 5, 0.5))

	-- Playdate sprite details
	self:setCenter(0.5, 0.5)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Effect)
	self:setTag(TAGS.Effect)
end