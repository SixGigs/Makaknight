-- Create constants for the playdate and playdate.graphics
-- Also create constants for the LDtk library and game data
local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk
local menu <const> = pd.getSystemMenu()

-- This table stores entity tags used for collisions
TAGS = {
	Player = 1, Hazard = 2, Pickup = 3, Flag = 4,
	Prop = 6, Door = 7, Animal = 8, Hitbox = 9,
	Crown = 10, Bar = 11
}

-- This table stores the Z axis of each entity
Z_INDEXES = {
	Hazard = 20, Door = 30, Prop = 40, Pickup = 50,
	Flag = 70, Animal = 110, Player = 100, Hitbox = 1000,
	Crown = 120, Bar = 1000
}

-- Load the level used for the game
ldtk.load("levels/world.ldtk", false)


--- The initialising method of the game scene class
class("World").extends(gfx.sprite)

--- Create the game class
function World:init()
	-- Load/Create the game
	self:load()

	-- Add a FPS tick box to the pause menu
	local fiftyHertz = false
	if self.fps == 50 then fiftyHertz = true end

	menu:addCheckmarkMenuItem("50 FPS", fiftyHertz, function(status)
		if status ~= nil then
			if status then
				self.fps = 50
			else
				self.fps = 30
			end

			pd.display.setRefreshRate(self.fps)
		end
	end)

	-- Add the Quick save option to the pause menu
	menu:addMenuItem("Quick Save", function() self:save(true) end)

	-- Go to the level specified from the load or create and create the player
	self:goToLevel(self.level)
	self.player = Player(self.levelX, self.levelY, self)
	pd.display.setRefreshRate(self.fps)
end


--- This method is responsible for loading rooms in the level. This includes the first room and any rooms the player enters
--- @param direction string Contains in text form, the direction from the current level to load the next level piece
function World:enterRoom(direction)
	-- If there is no neighbouring level die unless its north in which case just don't move
	local level <const> = ldtk.get_neighbours(self.level, direction)[1]
	if not level then
		if direction == "north" then return else return self.player:die() end
	end
	
	-- Use the LDtk library to find the neighbouring level in the direction given, and go to it
	local oldLevel <const> = self.level
	local level <const> = ldtk.get_neighbours(oldLevel, direction)[1]
	ldtk.release_level(oldLevel)

	-- Load the new level, remove the old level, and add the player
	self:goToLevel(level)
	self.player:add()

	-- Create a local X and Y, and use them to spawn the player
	local x, y
	if direction == "north" then
		x, y = self.player.x, 200
	elseif direction == "south" then
		x, y = self.player.x, 24
	elseif direction == "east" then
		x, y = 8, self.player.y
	elseif direction == "west" then
		x, y = 392, self.player.y
	end

	-- Move the player to the new X and Y
	self.player:moveTo(x, y)
end


--- This function is called when the player enters a door, and is used to create the level they are travelling to
--- @param level string  Contains the name of the level we want to travel to as a string
--- @param x     integer Contains the X coordinate to spawn the player after moving to the new level
--- @param y     integer Contains the Y coordinate to spawn the player after moving to the new level
function World:enterDoor(level, x, y)
	if level ~= self.level then
		self:goToLevel(level)
		self.player = Player(x, y, self)
	else
		self.player:moveTo(x, y)
	end
end


--- This function contains all the details on how to load a room, and spawning all the hazards/objects inside that room
--- @param level  string  Contains the name of the level to load as a string
function World:goToLevel(level)
	ldtk.load_level(level) -- Load the next level
	gfx.sprite.removeAll() -- Remove all playdate sprites

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
		if entityName == "Floorspike" or entityName == "Roofspike" or entityName == "Spearspike" or entityName == "Stalagmite" or entityName == "Stalactite" then
			Spike(entityX, entityY, entity)
		elseif entityName == "Spikeball" then
			Spikeball(entityX, entityY, entity)
		elseif entityName == "Ability" then
			Ability(entityX, entityY, entity)
		elseif entityName == "Flag" then
			Flag(entityX, entityY, entity, self)
		elseif entityName == "Door0" or entityName == "Door1" or entityName == "Door2" or entityName == "Door3" or entityName == "Door4" then
			Door(entityX, entityY, entity)
		elseif entityName == "Lizard" or entityName == "Snake" or entityName == "Butterfly" then
			Animal(entityX, entityY + 8, entity)
		elseif entityName == "Crown" then
			Crown(entityX, entityY)
		else
			Prop(entityX, entityY, entityName)
		end
	end

	self:loadBackground(level) -- Load the background
	self:loadHealthBar() -- Load the health bar

	playdate.resetElapsedTime() -- Reset time elapsed to stop player jumping when changing rooms
end


--- Load the background for the level sent into the function
--- @param level string The name of the 
function World:loadBackground(level)
	local bg <const> = LDtk.get_background(level)
	if bg then
		local background <const> = gfx.image.new("levels/"..bg)
		gfx.sprite.setBackgroundDrawingCallback(function()
			background:draw(0, 0)
		end)
	end
end


function World:updateHealthBar()
	self:deleteHealthBar()
	self:loadHealthBar()
end


--- Load the health bar for the player with their current hit points
function World:loadHealthBar()
	if self.player then
		self.bar = Bar(2, 2, self.player.hp)
	else
		self.bar = Bar(2, 2, self.hp)
	end
end


--- Delete the health bar
function World:deleteHealthBar()
	self.bar:remove()
end


--- The reset player method moves the player back to the most recent spawn X & Y coordinates
function World:resetPlayer()
	if self.level ~= self.spawn then
		self:goToLevel(self.spawn)
		self.player:add()
		self.player:moveTo(self.spawnX, self.spawnY)
		self.player:changeToSpawnState()
	else
		self.player:moveTo(self.spawnX, self.spawnY)
		self.player:changeToSpawnState()
		self:updateHealthBar()
	end
end


--- Load the game from the JSON save file and restore game attributes
function World:load()
	local gd <const> = pd.datastore.read()

	self.spawn = (gd and (gd.spawn and gd.spawn or "Level_0") or "Level_0")
	self.spawnX = (gd and (gd.spawnX and gd.spawnX or 12 * 16 + 8) or 12 * 16 + 8)
	self.spawnY = (gd and (gd.spawnY and gd.spawnY or 8 * 16) or 8 * 16)
	self.level = (gd and (gd.level and gd.level or self.spawn) or self.spawn)
	self.levelX = (gd and (gd.levelX and gd.levelX or self.spawnX) or self.spawnX)
	self.levelY = (gd and (gd.levelY and gd.levelY or self.spawnY) or self.spawnY)
	self.flag = (gd and (gd.flag and gd.flag or 0) or 0)
	self.face = (gd and (gd.face and gd.face or 0) or 0)
	self.fps = (gd and (gd.fps and gd.fps or 30) or 30)
	self.hp = (gd and (gd.hp and gd.hp or 100) or 100)
end


--- Save the current game data into the save file
function World:save(quickSave)
	local data <const> = {
		spawn = self.spawn,
		spawnX = self.spawnX,
		spawnY = self.spawnY,
		level = (quickSave and self.level or self.spawn),
		levelX = (quickSave and self.player.x or self.spawnX),
		levelY = (quickSave and self.player.y or self.spawnY),
		flag = self.flag,
		face = self.player.globalFlip,
		fps = self.fps,
		hp = self.player.hp
	}

	pd.datastore.write(data)
end


--- Unsets menu items
function World:unsetMenu()
	menu:removeAllMenuItems()
end