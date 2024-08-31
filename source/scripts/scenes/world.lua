local pd <const> = playdate
local gfx <const> = playdate.graphics
local menu <const> = pd.getSystemMenu()
local ldtk <const> = LDtk

-- Entity type tables
local hazards <const> = {
	["Floorspike"] = true,
	["Roofspike"] = true,
	["Spearspike"] = true,
	["Stalagmite"] = true,
	["Stalactite"] = true
}

-- Door type tables
local doors <const> = {
	["Door0"] = true,
	["Door1"] = true,
	["Door2"] = true,
	["Door3"] = true,
	["Door4"] = true
}

-- Reptile type tables
local reptiles <const> = {
	["Lizard"] = true,
	["Snake"] = true
}

-- A global table of entity tags
TAGS = {
	Player = 1, Hazard = 2, Pickup = 3, Flag = 4,
	Prop = 6, Door = 7, Animal = 8, Hitbox = 9,
	Crown = 10, GUI = 11, Bubble = 12, Fragileblock = 13,
	Wind = 14, Roaster = 15, Spike = 16, Halftile = 17
}

-- A global table of entity indexes
Z_INDEXES = {
	Hazard = 20, Door = 30, Prop = 40, Pickup = 50,
	Flag = 70, Animal = 110, Player = 100, Hitbox = 1000,
	Crown = 120, GUI = 1000, Bubble = 50, Fragileblock = 100,
	Wind = 500, Roaster = 100, Background = -10
}

ldtk.load('levels/world.ldtk', false) -- Load the level used for the game


--- The initialising method of the game scene class
class('World').extends(gfx.sprite)

--- Create the game class
function World:init()
	self:load() -- Load/Create the game

	-- Add a FPS tick box to the pause menu
	local fiftyHertz = false
	if self.fps == 50 then fiftyHertz = true end

	menu:addCheckmarkMenuItem('50 FPS', fiftyHertz, function(status)
		if status ~= nil then
			self.fps = (status and 50 or 30)
			pd.display.setRefreshRate(self.fps)
		end
	end)

	-- Add the Quick save option to the pause menu
	menu:addMenuItem('Quick Save', function() self:save(true) end)

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
		if direction == 'north' then return else return self.player:die() end
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
	if direction == 'north' then
		x, y = self.player.x, 200
	elseif direction == 'south' then
		x, y = self.player.x, 24
	elseif direction == 'east' then
		x, y = 8, self.player.y
	elseif direction == 'west' then
		x, y = 392, self.player.y
	end

	self.player:moveTo(x, y) -- Move the player to the new X and Y

	if self.width > screenWidth then
		if direction == 'west' then
			self.x = self.width - screenWidth
			self.player:moveBy(self.x, 0)
			self:adjustLevel(self.x)
		end
	end
end


--- This function is called when the player enters a door, and is used to create the level they are travelling to
--- @param  level  string   Contains the name of the level we want to travel to as a string
--- @param  x      integer  Contains the X coordinate to spawn the player after moving to the new level
--- @param  y      integer  Contains the Y coordinate to spawn the player after moving to the new level
function World:enterDoor(level, x, y)
	if level ~= self.level then
		local oldLevel <const> = self.level
		ldtk.release_level(oldLevel)
		self:goToLevel(level)
		self.player:moveTo(x, y)
		self.player:add()
	else
		self.player:moveTo(x, y)
	end
end


--- This function contains all the details on how to load a room, and spawning all the hazards/objects inside that room
--- @param  level  string  Contains the name of the level to load as a string
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

			local emptyTiles <const> = ldtk.get_empty_tileIDs(level, 'Solid', layer_name)
			if emptyTiles then
				gfx.sprite.addWallSprites(tilemap, emptyTiles)
			end

			local emptyTiles <const> = ldtk.get_empty_tileIDs(level, 'Half', layer_name)
			if emptyTiles then
				halfTiles = gfx.tilemap.getCollisionRects(tilemap, emptyTiles)
				for _, tile in pairs(halfTiles) do
					if tile.h > 1 then
						for i = tile.h, 1, -1 do
							local x <const> = tile.x * 16
							local y <const> = (tile.y + (i - 1)) * 16
							local w <const> = tile.w * 16
							local h <const> = 16

							local halfRect = pd.geometry.rect.new(x, y, w, h)

							local halfTile = gfx.sprite.addEmptyCollisionSprite(halfRect)
							halfTile:setTag(TAGS.Halftile)
							halfTile:setZIndex(layer.zIndex)
							halfTile:add()
						end
					else
						tile.x = tile.x * 16
						tile.y = tile.y * 16
						tile.w = tile.w * 16
						tile.h = tile.h * 16

						local halfTile = gfx.sprite.addEmptyCollisionSprite(tile)
						halfTile:setTag(TAGS.Halftile)
						halfTile:setZIndex(layer.zIndex)
						halfTile:add()
					end
				end
			end
		end
	end

	-- Now the new tile map has been created, spawn all the entities
	for _, entity in ipairs(ldtk.get_entities(level)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name

		-- Match the entity name to a script
		if hazards[entityName] then
			Spike(entityX, entityY, entity)
		elseif doors[entityName] then
			Door(entityX, entityY, entity)
		elseif reptiles[entityName] then
			Reptile(entityX, entityY + 8, entity)
		elseif entityName == "Butterfly" then
			Butterfly(entityX, entityY + 8, entity)
		elseif entityName == "Spikeball" then
			Spikeball(entityX, entityY, entity)
		elseif entityName == "Bubble" then
			Bubble(entityX, entityY, entity)
		elseif entityName == "DoubleJump" then
			Ability(entityX, entityY, entity)
		elseif entityName == "Flag" then
			Flag(entityX, entityY, entity, self)
		elseif entityName == "Fragileblock" then
			Fragileblock(entityX, entityY, entity)
		elseif entityName == "Crown" then
			Crown(entityX, entityY, entity)
		elseif entityName == "Fan" then
			Fan(entityX, entityY, entity)
			Wind(entityX - 8, entityY - 80, 70)
		elseif entityName == "Roaster" then
			Roaster(entityX, entityY, entity)
		else
			Prop(entityX, entityY, entityName)
		end
	end

	-- Save the Width and Height of the Level
	local level_size <const> = LDtk.get_size(level)
	self.width = level_size["width"]
	self.height = level_size["height"]

	self.x, self.y = 0 -- Create level X and Y

	-- Load the Background and Health Bar
	self:loadBackground(level)
	self:loadHealthBar()

	pd.resetElapsedTime() -- Reset time elapsed to stop player accelerating when changing rooms
end


--- Load the background for the level sent into the function
--- @param level string The name of the 
function World:loadBackground(level)
	local bg <const> = LDtk.get_background(level)

	if bg then
		local pos <const> = LDtk.get_background_position(level)

		if pos == "Repeat" then
			local bgAmount = self.width / screenWidth
			bgAmount = math.floor(bgAmount + 0.9)
			local nextBackground = 0

			for i = 1, bgAmount do
				Background(nextBackground, 0, bg)
				nextBackground = nextBackground + screenWidth
			end
		else
			Background(0, 0, bg)
		end
	end
end


--- Load the health bar for the player with their current hit points
function World:loadHealthBar()
	if self.player then
		self.bar = Bar(2, 2, self.player.hp)
	else
		self.bar = Bar(2, 2, self.hp)
	end
end


--- Update the Health Bar to Reflect Current Player Hit Points
function World:updateHealthBar()
	self.bar:remove()
	self:loadHealthBar()
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


--- This Function is Called by the Player to Update the World X Coordinate
function World:update()
	self.x = self.x + self.player.xVelocity * dt
	self:adjustLevel(self.player.xVelocity * dt)
end


--- Adjust the level X value to keep the player on the screen
--- @param  xAmount  integer  The amount to move the level by
function World:adjustLevel(xAmount)
	xAmount = self:levelCorrection(xAmount)

	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Bar) then
			return
		end

		sprite:moveBy(-xAmount, 0)
	end
end


--- Check if the Level X Amount needs Correction
--- @param  xAmount  The Amount to Move the Level
function World:levelCorrection(xAmount)
	if self.x > self.width - screenWidth then
		local xCorrection <const> = self.x - (self.width - screenWidth)
		xAmount = xAmount - xCorrection
		self.x = self.width - screenWidth
	end

	if self.x < 0 then
		local xCorrection <const> = xAmount - self.x
		xAmount = xCorrection
		self.x = 0
	end

	return xAmount
end


--- Unsets menu items
function World:unsetMenu()
	menu:removeAllMenuItems()
end


--- Load the game from the JSON save file and restore game attributes
function World:load()
	local gd <const> = pd.datastore.read()

	self.spawn = (gd and (gd.spawn and gd.spawn or "Level_0") or "Level_0")
	self.spawnX = (gd and (gd.spawnX and gd.spawnX or 3 * 16 + 8) or 3 * 16 + 8)
	self.spawnY = (gd and (gd.spawnY and gd.spawnY or 8 * 16) or 9 * 16)
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