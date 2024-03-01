-- Create constants for the playdate and playdate.graphics
-- Also create constants for the LDtk library and game data
local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk
local gd <const> = pd.datastore.read()

-- This table stores entity tags used for collisions
TAGS = {
	Player = 1,
	Hazard = 2,
	Pickup = 3,
	Flag = 4,
	Prop = 6,
	Door = 7
}

-- This table stores the Z axis of each entity
Z_INDEXES = {
	Hazard = 20,
	Door = 30,
	Prop = 40,
	Pickup = 50,
	Flag = 70,
	Player = 100
}

-- A table of levels which use the cave background
local caveLevels <const> = {
	'3',
	'6',
	'7',
	'17',
	'21',
	'22',
	'23',
	'24'
}

-- A table of levels which use the desert background
local desertLevels <const> = {
	'0',
	'1',
	'2',
	'4',
	'5',
	'8',
	'9',
	'10',
	'11',
	'12',
	'13',
	'14',
	'15',
	'16',
	'18',
	'19',
	'20',
	'25',
	'26',
	'27',
	'28',
	'29',
	'30',
	'31',
	'32',
	'33',
	'34',
	'35',
	'36',
	'37'
}

-- A table of props that exist in the game
local props <const> = {
	"Lightrock",
	"Deadtree",
	"Tallcactus",
	"Darkrock"
}

-- Load the level used for the game
ldtk.load("levels/world.ldtk", false)

--- The initialising method of the game scene class
class("Game").extends()



--- Create the game class
function Game:init()
	-- Load the game if there is a save file and create a game if there isn't	
	if gd then self:load() else self:create() end

	-- Go to the level specified from the load or create and create the player
	self:goToLevel(self.level)
	self.player = Player(self.levelX, self.levelY, self, self.face)
end


--- This method is responsible for loading rooms in the level. This includes the first room and any rooms the player enters
--- @param direction string Contains in text form, the direction from the current level to load the next level piece
function Game:enterRoom(direction)
	-- Use the LDtk library to find the neighbouring level in the direction given, and go to it
	local level <const> = ldtk.get_neighbours(self.level, direction)[1]
	self:goToLevel(level)

	-- Add the player to the new level
	self.player:add()

	-- Create a local X and Y, and use them to spawn the player
	local x, y
	if direction == "north" then
		x, y = self.player.x, 228
	elseif direction == "south" then
		x, y = self.player.x, 0
	elseif direction == "east" then
		x, y = 0, self.player.y
	elseif direction == "west" then
		x, y = 400, self.player.y
	end

	-- Move the player to the new X and Y
	self.player:moveTo(x, y)
end


--- This function is called when the player enters a door, and is used to create the level they are travelling to
--- @param level string  Contains the name of the level we want to travel to as a string
--- @param x     integer Contains the X coordinate to spawn the player after moving to the new level
--- @param y     integer Contains the Y coordinate to spawn the player after moving to the new level
function Game:enterDoor(level, x, y)
	if level ~= self.level then
		self:goToLevel(level)
		self.player:add()
		self.player:moveTo(x, y)
	else
		self.player:moveTo(x, y)
	end
end


--- This function contains all the details on how to load a room, and spawning all the hazards/objects inside that room
--- @param level  string  Contains the name of the level to load as a string
function Game:goToLevel(level)
	-- Remove all playdate sprite objects to give us a blank slate
	gfx.sprite.removeAll()

	-- Update local level attribute and build the new tile map
	self.level = level
	for layer_name, layer in pairs(ldtk.get_layers(level)) do
		if layer.tiles then
			local tilemap <const> = ldtk.create_tilemap(level, layer_name)
			local layerSprite <const> = gfx.sprite.new()

			layerSprite:setTilemap(tilemap)
			layerSprite:setCenter(0, 0)
			layerSprite:moveTo(0, 0)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			local emptyTiles <const> = ldtk.get_empty_tileIDs(level, "Solid", layer_name)
			if emptyTiles then
				gfx.sprite.addWallSprites(tilemap, emptyTiles)
			end
		end
	end

	-- Now the new tile map has been created, spawn all the entities
	for _, entity in ipairs(ldtk.get_entities(level)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name

		-- Match the entity name to a script
		if entityName == "Spike" then
			Spike(entityX, entityY)
		elseif entityName == "Spikeball" then
			Spikeball(entityX, entityY, entity)
		elseif entityName == "Ability" then
			Ability(entityX, entityY, entity)
		elseif entityName == "Flag" then
			Flag(entityX, entityY, entity, self)
		elseif entityName == "Door" then
			Door(entityX, entityY, entity)
		else
			Prop(entityX, entityY, entityName)
		end
	end

	-- Load the background for the new level
	self:loadBackground(level)
end


--- Load the background for the level sent into the function
--- @param level string The name of the 
function Game:loadBackground(level)
	-- Are we giving the level a cave background?
	for index, value in ipairs(caveLevels) do
		if 'Level_'..value == level then
			local backgroundImage <const> = gfx.image.new("levels/cave-background-400-240")
			gfx.sprite.setBackgroundDrawingCallback(function()
				backgroundImage:draw(0, 0)
			end)
		end
	end

	-- Are we giving the level a desert background?
	for index, value in ipairs(desertLevels) do
		if 'Level_'..value == level then
			local backgroundImage <const> = gfx.image.new("levels/desert-background-400-240")
			gfx.sprite.setBackgroundDrawingCallback(function()
				backgroundImage:draw(0, 0)
			end)
		end
	end
end


--- The reset player method moves the player back to the most recent spawn X & Y coordinates
function Game:resetPlayer()
	if self.level ~= self.spawn then
		self:goToLevel(self.spawn)
		self.player:add()
		self.player:moveTo(self.spawnX, self.spawnY)
		self.player:changeToRespawnState()
	else
		self.player:moveTo(self.spawnX, self.spawnY)
		self.player:changeToRespawnState()
	end
end


--- Create all the game data
function Game:create()
	self.spawn = "Level_0"
	self.spawnX = 12 * 16 + 8
	self.spawnY = 8 * 16
	self.level = self.spawn
	self.levelX = self.spawnX
	self.levelY = self.spawnY
	self.flag = 0
	self.face = 0
end


--- Save the current game data into the save file
function Game:save()
	local saveData = {
		spawn = self.spawn,
		spawnX = self.spawnX,
		spawnY = self.spawnY,
		level = self.level,
		levelX = self.player.x,
		levelY = self.player.y,
		flag = self.flag,
		face = self.player.globalFlip,
	}

	pd.datastore.write(saveData)
end


--- Load the game from the JSON save file
function Game:load()
	self.spawn = gd.spawn
	self.spawnX = gd.spawnX
	self.spawnY = gd.spawnY
	self.level = gd.level
	self.levelX = gd.levelX
	self.levelY = gd.levelY
	self.flag = gd.flag
	self.face = gd.face
end