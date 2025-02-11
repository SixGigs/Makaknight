local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Wipe').extends(gfx.sprite)



function Wipe:init(transition)
	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
	local transitionSprite = gfx.sprite.new(filledRect)
	local transitionTimer

	if transition == 'out' then
		startValue = -1
		endValue = 400
	else
		startValue = 400
		endValue = -1
	end

	transitionTimer = pd.timer.new(1000, startValue, endValue, pd.easingFunctions.inOutCubic)

	transitionTimer.updateCallback = function(timer)
		transitionSprite:setClipRect(0, 0, timer.value, 240)
	end

	transitionSprite:moveTo(200, 120)
	transitionSprite:setClipRect(0, 0, startValue, 240)
	transitionSprite:setZIndex(32767)
	transitionSprite:setIgnoresDrawOffset()
	transitionSprite:add()
end