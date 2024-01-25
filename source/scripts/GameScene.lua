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
	Checkpoint = 4,
	Ledge = 5
}

-- This array contains how far in the foreground each object type is
Z_INDEXES = {
	Player = 100,
	Hazard = 20,
	Prop = 30,
	Pickup = 50,
	Checkpoint = 70
}

-- Load the level used for the game
ldtk.load("levels/world.ldtk", false)

--- The initialising method of the game scene class
class("GameScene").extends()
function GameScene:init()
	if gd then
		self:loadGame()
	else
		self:createGame()
	end
end


--- Create game data
function GameScene:createGame()
	self.spawnLevel = "Level_0"
	self.currentLevel = "Level_0"
	self.checkpoint = 0
	self.spawnX = 12 * 16
	self.spawnY = 12 * 16
	self.currentX = 12 * 16
	self.currentY = 12 * 16
	self.facing = 0

	self:goToLevel(self.currentLevel)
	self.player = Player(self.currentX, self.currentY, self, self.facing)

	self.player.doubleJumpAbility = false
	self.player.dashAbility = true
end


--- Function used for saving the game
function GameScene:saveGame()
	local saveData = {
		spawnLevel = self.spawnLevel,
		spawnX = self.spawnX,
		spawnY = self.spawnY,
		currentLevel = self.currentLevel,
		currentX = self.player.x,
		currentY = self.player.y,
		checkpoint = self.checkpoint,
		facing = self.player.globalFlip,
		doubleJump = self.player.doubleJumpAbility,
		dash = self.player.dashAbility
	}

	pd.datastore.write(saveData)
end


--- Load game data
function GameScene:loadGame()
	self.spawnLevel = gd.spawnLevel
	self.spawnX = gd.spawnX
	self.spawnY = gd.spawnY
	self.currentLevel = gd.currentLevel
	self.currentX = gd.currentX
	self.currentY = gd.currentY
	self.checkpoint = gd.checkpoint
	self.facing = gd.facing

	self:goToLevel(self.currentLevel)
	self.player = Player(self.currentX, self.currentY, self, self.facing)

	self.player.doubleJumpAbility = gd.doubleJump
	self.player.dashAbility = gd.dash
end


--- The reset player method moves the player back to the most recent spawn X & Y coordinates
function GameScene:resetPlayer()
	if self.currentLevel ~= self.spawnLevel then
		self:goToLevel(self.spawnLevel)
		self.player = Player(self.spawnX, self.spawnY, self, self.facing)
		self.currentLevel = self.spawnLevel
		self.player:changeToRespawnState()
	else
		self.player:moveTo(self.spawnX, self.spawnY)
		self.player:changeToRespawnState()
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
	self.currentLevel = level
end


--- This function contains all the details on how to load a room, and spawning all the hazards/objects inside that room
--- @param level_name string Contains the name of the level to load as a string
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

			local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Ledge", layer_name)
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
			Checkpoint(entityX, entityY, entity, self)
		elseif entityName == "Lightrock" then
			Lightrock(entityX, entityY)
		elseif entityName == "Darkrock" then
			Darkrock(entityX, entityY)
		elseif entityName == "Deadtree" then
			Deadtree(entityX, entityY)
		elseif entityName == "Tallcactus" then
			Tallcactus(entityX, entityY)
		end
	end

	self:loadBackground(level_name)
end


--- Load the background for the level sent into the function
---@param level string The name of the 
function GameScene:loadBackground(level)
	if level == "Level_2" or level == "Level_8" or level == "Level_9" or level == "Level_10" or level == "Level_11" then
		local backgroundImage = gfx.image.new("levels/cave-background-400-240")
		gfx.sprite.setBackgroundDrawingCallback(function()
			backgroundImage:draw(0, 0)
		end)
	elseif level == "Level_0" or level == "Level_1" or level == "Level_3" or level == "Level_4" or level == "Level_5" or level == "Level_6" or level == "Level_7"  or level == "Level_12" or level == "Level_13"  or level == "Level_14" or level == "Level_15" or level == "Level_16"then
		local backgroundImage = gfx.image.new("levels/desert-background-400-240")
		gfx.sprite.setBackgroundDrawingCallback(function()
			backgroundImage:draw(0, 0)
		end)
	end
end