-- PlayDate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- local fadedRects = {}
-- for i=0,1,0.01 do
-- 	local fadedImage = gfx.image.new(400, 240)
-- 	gfx.pushContext(fadedImage)
-- 
-- 	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
-- 	filledRect:drawFaded(0, 0, i, gfx.image.kDitherTypeBayer8x8)
-- 	gfx.popContext()
-- 	fadedRects[math.floor(i * 100)] = fadedImage
-- end
-- fadedRects[100] = gfx.image.new(400, 240, gfx.kColorBlack)

-- Scene Manager Class
class('SceneManager').extends()

-- Creates an instance of the scene manager
function SceneManager:init()
	self.transitionTime = 1000
	self.transitioning = false
end

---Switch the scene by passing the next scene class and any arguments you like
---The three dots represent no or many arguments can be passed
---@param scene function The class you would like to change to
---@param ...   unknown  Any data you want that scene to have
function SceneManager:switchScene(scene, transition, ...)
	if self.transitioning then
		return
	end

	self.newScene = scene
	self.sceneArgs = ...
	self:startTransition(transition)
end

--- Load the new scene at last
function SceneManager:loadNewScene()
	self:cleanupScene()
	self.newScene(self.sceneArgs)
end

-- Starts and handles the transition
function SceneManager:startTransition(transition)
	local transitionTimer
	if transition == "wipe" then
		transitionTimer = self:wipeTransition(0, 400)
	else
		transitionTimer = self:fadeTransition(0, 1)
	end
	transitionTimer.timerEndedCallback = function()
		self:loadNewScene()
		if transition == "wipe" then
			transitionTimer = self:wipeTransition(400, 0)
		else
			transitionTimer = self:fadeTransition(1, 0)
		end
		transitionTimer .timerEndedCallback = function()
			self.transitioning = false
		end
	end
end

-- Does the "wipe" transition
function SceneManager:wipeTransition(startValue, endValue)
	local transitionSprite = self:createTransitionSprite()
	transitionSprite:setClipRect(0, 0, startValue, 240)

	local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
	transitionTimer.updateCallback = function(timer)
		transitionSprite:setClipRect(0, 0, timer.value, 240)
	end
	return transitionTimer
end

-- Does the "fade" transition
function SceneManager:fadeTransition(startValue, endValue)
	local transitionSprite = self:createTransitionSprite()
	transitionSprite:setImage(self:getFadedImage(startValue))

	local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
	transitionTimer.updateCallback = function(timer)
		transitionSprite:setImage(self:getFadedImage(timer.value))
	end
	return transitionTimer
end

-- Used by the fade transition to optimise the performance
function SceneManager:getFadedImage(alpha)
	return fadedRects[math.floor(alpha * 100)]
end

-- Creates a sprite to transition too and from for the scene change
function SceneManager:createTransitionSprite()
	-- To change this for an image replace "gfx.kColorBlack" with the image
	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
	local transitionSprite = gfx.sprite.new(filledRect)
	transitionSprite:moveTo(200, 120)
	transitionSprite:setZIndex(32767)
	transitionSprite:setIgnoresDrawOffset()
	transitionSprite:add()
	return transitionSprite
end

-- Used by the class to delete all current sprites and timers
function SceneManager:cleanupScene()
	gfx.sprite.removeAll()
	self:removeAllTimers()
	gfx.setDrawOffset(0, 0)
end

-- Deletes all timers in the timers group
function SceneManager:removeAllTimers()
	local allTimers = pd.timer.allTimers()
	for _, timer in ipairs(allTimers) do
		timer:remove()
	end
end