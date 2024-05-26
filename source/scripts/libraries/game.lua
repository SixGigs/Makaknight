-- PlayDate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Game manager Class
class('Game').extends()


-- Creates an instance of the Game manager
function Game:init()
	self.transitionTime = 1000
	self.transitioning = false
end


--- Switch the scene by passing the next scene class and any arguments
--- you like, the three dots mean no or many arguments can be passed
--- @param   nextScene   class     The class you would like to change to
--- @param   ...         unknown   Any data you want that scene to have
function Game:switchScene(nextScene, transition, ...)
	if self.transitioning then return end

	self.newScene = nextScene
	self.sceneArgs = ...
	self:startTransition(transition)
end


-- Starts and handles the transition
function Game:startTransition(transition)
	local transitionTimer

	if transition == "fade" then
		transitionTimer = self:fadeTransition(0, 1)
	else
		transitionTimer = self:wipeTransition(0, 400)
	end

	transitionTimer.timerEndedCallback = function()
		self:loadNewScene()

		if transition == "fade" then
			transitionTimer = self:fadeTransition(1, 0)
		else
			transitionTimer = self:wipeTransition(400, 0)
		end

		transitionTimer.timerEndedCallback = function()
			self.transitioning = false
		end
	end
end


--- Clean up any old scene data & create a new instance of the next scene
function Game:loadNewScene()
	self:cleanupScene()
	self.newScene(self.sceneArgs)
end


--- Used by the class to delete all current sprites and timers
function Game:cleanupScene()
	self:removeAllTimers()
	gfx.sprite.removeAll()
	gfx.setDrawOffset(0, 0)
end


--- Deletes all timers in the timers group
function Game:removeAllTimers()
	local allTimers = pd.timer.allTimers()

	for _, timer in ipairs(allTimers) do
		timer:remove()
	end
end


--- Does the "wipe" transition
function Game:wipeTransition(startValue, endValue)
	local transitionSprite = self:createTransitionSprite()
	transitionSprite:setClipRect(0, 0, startValue, 240)

	local transitionTimer = pd.timer.new(
		self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic
	)

	transitionTimer.updateCallback = function(timer)
		transitionSprite:setClipRect(0, 0, timer.value, 240)
	end

	return transitionTimer
end


--- Does the "fade" transition
function Game:fadeTransition(startValue, endValue)
	local transitionSprite = self:createTransitionSprite()
	transitionSprite:setImage(self:getFadedImage(startValue))

	local transitionTimer = pd.timer.new(
		self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic
	)

	transitionTimer.updateCallback = function(timer)
		transitionSprite:setImage(self:getFadedImage(timer.value))
	end

	return transitionTimer
end


--- Used by the fade transition to optimise the performance
function Game:getFadedImage(alpha)
	local fadedImage = gfx.image.new(400, 240)

	gfx.pushContext(fadedImage)
	-- To change this for an image replace "gfx.kColorBlack" with the image
	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
	filledRect:drawFaded(0, 0, alpha, gfx.image.kDitherTypeBayer8x8)
	gfx.popContext()

	return fadedImage
end


--- Creates a sprite to transition too and from for the scene change
function Game:createTransitionSprite()
	-- To change this for an image replace "gfx.kColorBlack" with the image
	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
	local transitionSprite = gfx.sprite.new(filledRect)

	transitionSprite:moveTo(200, 120)
	transitionSprite:setZIndex(32767)
	transitionSprite:setIgnoresDrawOffset()
	transitionSprite:add()

	return transitionSprite
end