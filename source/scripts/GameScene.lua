-- Create the script constants
local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk

-- Load data for the player and location
local gameData = playdate.datastore.read()


-- Create an array of tags (used to identify the collision objects)
TAGS = {
	Player = 1,
	Hazard = 2,
	Pickup = 3
}

-- Create an array of Z indexes for the objects (how far in the foreground they are)
Z_INDEXES = {
	Player = 100,
	Hazard = 20,
	Pickup = 50
}


-- Load the level used for the game
ldtk.load("levels/world.ldtk", false)

-- Create the game scene class
class("GameScene").extends()


--- The initialising method of the game scene class,
--- It loads the level, and spawns the player
function GameScene:init()
	print("Game opened")

	if gameData then
		self:goToLevel(gameData.currentLevel)
		self.spawnX = gameData.spawnX
		self.spawnY = gameData.spawnY
	else
		self:goToLevel("Level_0")
		self.spawnX = 2 * 16
		self.spawnY = 9 * 16
	end

	self.player = Player(self.spawnX, self.spawnY, self)

	if gameData then
		self.player.doubleJumpAbility = gameData.doubleJump
		self.player.dashAbility = gameData.dash
	end
end


--- The reset player method moves the player back to the most recent spawn X & Y coordinates
function GameScene:resetPlayer()
	self.player:moveTo(self.spawnX, self.spawnY)
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
	self.spawnX = spawnX
	self.spawnY = spawnY

	local gameData = {
		currentLevel = level,
		spawnX = spawnX,
		spawnY = spawnY,
		doubleJump = self.player.doubleJumpAbility,
		dash = self.player.dashAbility
	}

	pd.datastore.write(gameData)
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
		end
	end
end