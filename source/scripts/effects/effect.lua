local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Effect').extends(AnimatedSprite)



function Effect:init(x, y)
	-- Local constants
	local n <const> = math.random(1, 5)
	local i <const> = 'images/effects/sparkles/'
	local t <const> = {
		[1] = 'sparkle1-table-15-21',
		[2] = 'sparkle2-table-13-23',
		[3] = 'sparkle3-table-21-21',
		[4] = 'sparkle4-table-21-21',
		[5] = 'sparkle5-table-19-26'
	}

	x = math.random(math.floor(x - 5, 0.5), math.floor(x + 5, 0.5))
	y = math.random(math.floor(y - 5, 0.5), math.floor(y + 5, 0.5))

	Effect.super.init(self, i .. t[n])

	self:addState(1, 1, 7, {ts = 1, l = 1})
	self:playAnimation()

	self.states[1].onAnimationEndEvent = function(self)
		self:remove()
	end

	self:setCenter(0.5, 0.5)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Effect)
	self:setTag(TAGS.Effect)
end