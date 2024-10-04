-- PlayDate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics
local menu <const> = pd.getSystemMenu()

-- Game manager Class
class("Game").extends()


-- Creates an instance of the Game manager
function Game:init()
	self:load()
	
	self.transitionTime = 1000
	self.transitioning = false

	menu:addCheckmarkMenuItem('50 FPS', (self.fps == 50 and true or false), function(status)
		if status ~= nil then
			self.fps = (status and 50 or 30)
			pd.display.setRefreshRate(self.fps)
		end
	end)
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
			transitionTimer = self:wipeTransition(400, -1)
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


--- Load the Save File if it Exists
function Game:load()
	local gd <const> = pd.datastore.read()

	self.spawn_level = (gd and (gd.spawn and gd.spawn or "Level_0") or "Level_0")
	self.player_spawn_x = (gd and (gd.spawnX and gd.spawnX or 3 * 16 + 8) or 3 * 16 + 8)
	self.player_spawn_y = (gd and (gd.spawnY and gd.spawnY or 8 * 16) or 9 * 16)
	self.player_level = (gd and (gd.level and gd.level or self.spawn_level) or self.spawn_level)
	self.player_facing = (gd and (gd.face and gd.face or 0) or 0)
	self.player_hp = (gd and (gd.hp and gd.hp or 100) or 100)
	self.player_sp = (gd and (gd.sp and gd.sp or 100) or 100)
	self.player_x = (gd and (gd.levelX and gd.levelX or self.player_spawn_x) or self.player_spawn_x)
	self.player_y = (gd and (gd.levelY and gd.levelY or self.player_spawn_y) or self.player_spawn_y)
	self.checkpoint = (gd and (gd.flag and gd.flag or 0) or 0)
	self.world_x = (gd and (gd.worldX and gd.worldX or 0) or 0)
	self.fps = (gd and (gd.fps and gd.fps or 30) or 30)

	pd.display.setRefreshRate(self.fps)
end


--- Save the Game
function Game:save()
	local data <const> = {
		spawn = self.spawn_level,
		spawnX = self.player_spawn_x,
		spawnY = self.player_spawn_y,
		level = self.player_level,
		levelX = self.player_x,
		levelY = self.player_y,
		flag = self.checkpoint,
		face = self.player_facing,
		fps = self.fps,
		hp = self.player_hp,
		worldX = self.world_x
	}

	pd.datastore.write(data)
end