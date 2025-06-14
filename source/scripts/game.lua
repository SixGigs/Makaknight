local pd <const> = playdate
local gfx <const> = pd.graphics
local menu <const> = pd.getSystemMenu()
class('Game').extends()



function Game:init()
	self:load()

	self.transitionTime = 1000
	self.transitioning = false
	self.won = false

	if DEBUG then
		menu:addMenuItem('Reset', function()
			self:reset()
		end)
	end

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
	if self.transitioning then
		return
	end

	self.newScene = nextScene
	self.sceneArgs = ...
	self:startTransition(transition)
end



-- Starts and handles the transition
function Game:startTransition(transition)
	if transition == "fade" then
		Fade('out')
	else
		Wipe('out')
	end

	local transitionTimer = pd.timer.new(self.transitionTime, 0, 400)

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

		if transition == 'fade' then
			Fade('in')
		else
			Wipe('in')
		end

		transitionTimer = pd.timer.new(self.transitionTime, 0, 400)

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



--- Load save file data if the save file (game data) exists
function Game:load()
	local gd <const> = pd.datastore.read()

	self.playerSpawnLevel = (gd and (gd.spawn and gd.spawn or nil) or nil)
	self.playerSpawnX = (gd and (gd.spawnX and gd.spawnX or nil) or nil)
	self.playerSpawnY = (gd and (gd.spawnY and gd.spawnY or nil) or nil)
	self.playerLevel = (gd and (gd.level and gd.level or self.playerSpawnLevel) or self.playerSpawnLevel)
	self.playerXVelocity = (gd and (gd.xVelocity and gd.xVelocity or 0) or 0)
	self.playerYVelocity = (gd and (gd.yVelocity and gd.yVelocity or 0) or 0)
	self.playerState = (gd and (gd.state and gd.state or 'idle') or 'idle')
	self.playerFacing = (gd and (gd.face and gd.face or 0) or 0)
	self.playerHP = (gd and (gd.hp and gd.hp or 100) or 100)
	self.playerSP = (gd and (gd.sp and gd.sp or 100) or 100)
	self.playerMP = (gd and (gd.mp and gd.mp or 100) or 100)
	self.playerMaxHP = (gd and (gd.maxHP and gd.maxHP or 100) or 100)
	self.playerMaxSP = (gd and (gd.maxSP and gd.maxSP or 100) or 100)
	self.playerMaxMP = (gd and (gd.maxMP and gd.maxMP or 100) or 100)
	self.playerCoins = (gd and (gd.coins and gd.coins or 0) or 0)
	self.depletedEntities = (gd and (gd.depletedEntities and gd.depletedEntities or {}) or {})
	self.extinctEntities = (gd and (gd.extinctEntities and gd.extinctEntities or {}) or {})
	self.playerX = (gd and (gd.levelX and gd.levelX or self.playerSpawnX) or self.playerSpawnX)
	self.playerY = (gd and (gd.levelY and gd.levelY or self.playerSpawnY) or self.playerSpawnY)
	self.checkpoint = (gd and (gd.flag and gd.flag or 0) or 0)
	self.worldX = (gd and (gd.worldX and gd.worldX or 0) or 0)
	self.worldY = (gd and (gd.worldY and gd.worldY or 0) or 0)
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
		xVelocity = self.playerXVelocity,
		yVelocity = self.playerYVelocity,
		state = self.playerState,
		flag = self.checkpoint,
		face = self.playerFacing,
		fps = self.fps,
		hp = self.playerHP,
		sp = self.playerSP,
		mp = self.playerMP,
		maxHP = self.playerMaxHP,
		maxSP = self.playerMaxSP,
		maxMP = self.playerMaxMP,
		coins = self.playerCoins,
		depletedEntities = self.depletedEntities,
		extinctEntities = self.extinctEntities,
		worldX = self.worldX,
		worldY = self.worldY
	}

	pd.datastore.write(data)
end



function Game:emptySpawnList()
	self.depletedEntities = {}

	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Animal) or sprite:isa(Pickup) then
			if not sprite:isVisible() then
				sprite:reset()
			end
		end
	end
end



function Game:reset()
	local data <const> = {}
	pd.datastore.write(data)

	self:switchScene(World, 'fade')
end