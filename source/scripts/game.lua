local pd <const> = playdate
local gfx <const> = pd.graphics
local menu <const> = pd.getSystemMenu()
class('Game').extends()



function Game:init()
	self:load()

	self.transitionTime = 1000
	self.transitioning = false
	self.won = false

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
		Fade('out')
		transitionTimer = pd.timer.new(self.transitionTime, 0, 400)
	else
		transitionTimer = self:wipeTransition(0, 400)
	end

	transitionTimer.timerEndedCallback = function()
		self:loadNewScene()

		if self.won then
			self.playerHP = self.playerMaxHP
			self.playerSP = self.playerMaxSP
			self.playerMP = self.playerMaxMP
			self.playerLevel = self.playerSpawnLevel
			self.playerX = self.playerSpawnX
			self.playerY = self.playerSpawnY

			self.depletedEntities = {}
			self.won = false
		end

		if transition == "fade" then
			Fade('in')
			transitionTimer = pd.timer.new(self.transitionTime, 0, 400)
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



--- Removes all timers and all sprites ready for the next scene
function Game:cleanupScene()
	self:removeAllTimers()
	gfx.sprite.removeAll()
	gfx.setDrawOffset(0, 0)
end



--- Deletes all running timers
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



--- Load save file data if the save file (game data) exists
function Game:load()
	local gd <const> = pd.datastore.read()

	self.playerSpawnLevel = (gd and (gd.spawn and gd.spawn or "Level_0") or "Level_0")
	self.playerSpawnX = (gd and (gd.spawnX and gd.spawnX or 12 * 16 + 8) or 12 * 16 + 8)
	self.playerSpawnY = (gd and (gd.spawnY and gd.spawnY or 8 * 16) or 9 * 16)
	self.playerLevel = (gd and (gd.level and gd.level or self.playerSpawnLevel) or self.playerSpawnLevel)
	self.playerFacing = (gd and (gd.face and gd.face or 0) or 0)
	self.playerHP = (gd and (gd.hp and gd.hp or 100) or 100)
	self.playerSP = (gd and (gd.sp and gd.sp or 100) or 100)
	self.playerMP = (gd and (gd.mp and gd.mp or 100) or 100)
	self.playerMaxHP = (gd and (gd.maxHP and gd.maxHP or 100) or 100)
	self.playerMaxSP = (gd and (gd.maxSP and gd.maxSP or 100) or 100)
	self.playerMaxMP = (gd and (gd.maxMP and gd.maxMP or 100) or 100)
	self.depletedEntities = (gd and (gd.depletedEntities and gd.depletedEntities or {}) or {})
	self.playerX = (gd and (gd.levelX and gd.levelX or self.playerSpawnX) or self.playerSpawnX)
	self.playerY = (gd and (gd.levelY and gd.levelY or self.playerSpawnY) or self.playerSpawnY)
	self.checkpoint = (gd and (gd.flag and gd.flag or 0) or 0)
	self.worldX = (gd and (gd.worldX and gd.worldX or 0) or 0)
	self.fps = (gd and (gd.fps and gd.fps or 30) or 30)

	pd.display.setRefreshRate(self.fps)
end



--- Save the game, this is global so it can execute on console exit or sleep
function Game:save()
	local data <const> = {
		spawn = self.playerSpawnLevel,
		spawnX = self.playerSpawnX,
		spawnY = self.playerSpawnY,
		level = self.playerLevel,
		levelX = self.playerX,
		levelY = self.playerY,
		flag = self.checkpoint,
		face = self.playerFacing,
		fps = self.fps,
		hp = self.playerHP,
		sp = self.playerSP,
		mp = self.playerMP,
		maxHP = self.playerMaxHP,
		maxSP = self.playerMaxSP,
		maxMP = self.playerMaxMP,
		deletedEntities = self.depletedEntities,
		worldX = self.worldX
	}

	pd.datastore.write(data)
end



function Game:emptySpawnList()
	self.depletedEntities = {}

	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Pickup) then
			sprite:setVisible(true)
		elseif sprite:isa(Animal) then
			if not sprite:isVisible() then
				sprite.hp = sprite.maxHP
				sprite:moveTo(sprite.spawn_x, sprite.spawn_y)
				sprite:setVisible(true)
			end
		end
	end
end