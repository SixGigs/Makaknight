-- Create the script constants
local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk
local gd <const> = pd.datastore.read()

-- These tags are used to set collide interactions
TAGS = {
	Player = 1,
	Hazard = 2,
	Pickup = 3,
	Checkpoint = 4
}

-- This array contains how far in the foreground each object type is
Z_INDEXES = {
	Player = 100,
	Hazard = 20,
	Pickup = 50,
	Checkpoint = 70
}

-- Load the level used for the game
ldtk.load("levels/world.ldtk", false)

--- The initialising method of the game scene class,
--- It loads the level, and spawns the player
class("GameScene").extends()
function GameScene:init()
	if gd then
		self.respawnLevel = gd.respawnLevel
		self.level = gd.currentLevel
		self.checkpoint = gd.checkpoint
		self.spawnX = gd.spawnX
		self.spawnY = gd.spawnY
		self.loadX = gd.loadX
		self.loadY = gd.loadY

		self:goToLevel(self.level)
		self.player = Player(self.loadX, self.loadY, self)

		self.player.doubleJumpAbility = gd.doubleJump
		self.player.dashAbility = gd.dash
	else
		self.respawnLevel = "Level_0"
		self.level = "Level_0"
		self.checkpoint = 0
		self.spawnX = 2 * 16
		self.spawnY = 11 * 16
		self.loadX = 2 * 16
		self.loadY = 11 * 16

		self:goToLevel(self.level)
		self.player = Player(self.loadX, self.loadY, self)

		self.player.doubleJumpAbility = false
		self.player.dashAbility = false
	end
end


--- The reset player method moves the player back to the most recent spawn X & Y coordinates
function GameScene:resetPlayer()
	if self.level ~= self.respawnLevel then
		self:goToLevel(self.respawnLevel)
		self.player = Player(self.spawnX, self.spawnY, self)
		self.level = self.respawnLevel
	else
		self.player:moveTo(self.spawnX, self.spawnY)
	end
end


--- This method is responsible for loading rooms in the level. This includes the first room and any rooms the player enters
--- @param direction string Contains in text form, the direction from the current level to load the next level piece
function GameScene:enterRoom(direction)
	local level = ldtk.get_neighbours(self.levelName, direction)[1]
	self:goToLevel(level)
	self.player:add()

	local spawnX, spawnY
	if direction == "north" then
		spawnX, spawnY = self.player.x, 240
	elseif direction == "south" then
		spawnX, spawnY = self.player.x, 0
	elseif direction == "east" then
		spawnX, spawnY = 0, self.player.y
	elseif direction == "west" then
		spawnX, spawnY = 400, self.player.y
	end

	self.player:moveTo(spawnX, spawnY)
	self.level = level
end


--- This function contains all the details on how to load a room, and spawning all the hazards/objects inside that room
--- @param level_name string Contains the name of the level to load as a scring
function GameScene:goToLevel(level_name)
	gfx.sprite.removeAll()

	self.levelName = level_name
	for layer_name, layer in pairs(ldtk.get_layers(level_name)) do
		if layer.tiles then
			local tilemap = ldtk.create_tilemap(level_name, layer_name)
			local layerSprite = gfx.sprite.new()

			layerSprite:setTilemap(tilemap)
			layerSprite:setCenter(0, 0)
			layerSprite:moveTo(0, 0)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)
			if emptyTiles then
				gfx.sprite.addWallSprites(tilemap, emptyTiles)
			end
		end
	end

	for _, entity in ipairs(ldtk.get_entities(level_name)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name
		if entityName == "Spike" then
			Spike(entityX, entityY)
		elseif entityName == "Spikeball" then
			Spikeball(entityX, entityY, entity)
		elseif entityName == "Ability" then
			Ability(entityX, entityY, entity)
		elseif entityName == "Checkpoint" then
			Checkpoint(entityX, entityY, entity)
		end
	end

	self:loadBackground(self.level)
end

function GameScene:saveGame()
	local saveData = {
		respawnLevel = self.respawnLevel,
		currentLevel = self.level,
		checkpoint = self.checkpoint,
		spawnX = self.spawnX,
		spawnY = self.spawnY,
		loadX = self.player.x,
		loadY = self.player.y,
		doubleJump = self.player.doubleJumpAbility,
		dash = self.player.dashAbility
	}

	pd.datastore.write(saveData)
end

function GameScene:loadBackground(level)
	if level ~= "Level_99" then
		local backgroundImage = gfx.image.new("levels/cave-background-400-240")
		gfx.sprite.setBackgroundDrawingCallback(function()
			backgroundImage:draw(0, 0)
		end)
	end
end