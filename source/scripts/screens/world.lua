local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk
class('World').extends(gfx.sprite)

 -- Load the World File Used for the World
ldtk.load('levels/world.ldtk', false)



-- Global collision tag & z-index arrays
TAGS = {
	Player = 1, Hazard = 2, Pickup = 3, Flag = 4,
	Prop = 6, Door = 7, Animal = 8, Hitbox = 9,
	Crown = 10, Gui = 11, Bubble = 12, Fragile = 13,
	Wind = 14, Roaster = 15, Spike = 16, Half = 17,
	Text = 18
}

Z_INDEXES = {
	Hazard = 20, Door = 30, Prop = 40, Pickup = 50,
	Flag = 70, Animal = 110, Player = 100, Hitbox = 1000,
	Crown = 120, Gui = 1000, Bubble = 50, Fragile = 100,
	Wind = 500, Roaster = 100, Background = -10, Transition = 1500,
	Text = 1250, Foreground = 150
}



--- Initialise the World class
function World:init()
	-- Go to the Level Specified in the Save File and Create the Player
	self.gravity = 900
	self.oldLevelName = ''
	self.oldWorldY = 0

	self:goToLevel(GAME.playerLevel)
	self:adjustLevel(GAME.worldX, GAME.worldY)
	self.player = Player(self)
end



--- This method is responsible for loading rooms in the level. This includes the first room and any rooms the player enters
--- @param  direction  string  Contains a Direction From the Current Level to Load the Next Level Piece
function World:enterRoom(direction)
	-- If there is no neighbouring level die unless its north in which case just don't move
	local level <const> = ldtk.get_neighbours(GAME.playerLevel, direction)[1]
	if not level then
		if direction == 'north' then
			return
		elseif direction == 'east' then
			self.player:moveTo(0, self.player.y - 2)
			return
		elseif direction == 'west' then
			self.player:moveTo(400, self.player.y - 2)
			return
		else
			self.player.hp = 0
			return
		end
	end

	-- Use the LDtk library to find the neighbouring level in the direction given, and go to it
	local oldLevel <const> = GAME.playerLevel
	local level <const> = ldtk.get_neighbours(oldLevel, direction)[1]
	ldtk.release_level(oldLevel)

	-- Load the new level, remove the old level, and add the player
	self:goToLevel(level)
	self.player:add()

	-- Reset the Game World Coordinate Properties
	if direction == 'east' then
		GAME.worldX = 0
	end

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

	-- Move the player to the new X and Y
	self.player:moveTo(x, y)

	if self.width > SCREEN['width'] then
		if direction == 'west' then
			GAME.worldX = self.width - SCREEN['width']
			self.player:moveBy(GAME.worldX, 0)
			self:adjustLevel(GAME.worldX, 0)
		end
	end

	if self.height > SCREEN['height'] then
		local worldDiff <const> = self.oldWorldY - self.worldY
		GAME.worldY = worldDiff
		self.player:moveBy(0, GAME.worldY)
		self:adjustLevel(0, GAME.worldY)
	else
		GAME.worldY = 0
	end
end



--- This function is called when the player enters a door, and is used to create the level they are travelling to
--- @param  level  string   Contains the name of the level we want to travel to as a string
--- @param  x      integer  Contains the X coordinate to spawn the player after moving to the new level
--- @param  y      integer  Contains the Y coordinate to spawn the player after moving to the new level
function World:enterDoor(level, x, y)
	if level ~= GAME.playerLevel then
		Fade('out')

		pd.timer.performAfterDelay(500, function()
			local oldLevel <const> = GAME.playerLevel
			ldtk.release_level(oldLevel)
			self:goToLevel(level)
			self.player:add()

			Fade('in')
		end)
	end

	pd.timer.performAfterDelay(500, function()
		self.player:moveTo(x, y)
		self.player:changeState('exit')

		if self.width > SCREEN['width'] then
			if direction == 'west' then
				GAME.worldX = self.width - SCREEN['width']
				self.player:moveBy(GAME.worldX, 0)
				self:adjustLevel(GAME.worldX, 0)
			end
		end

		if self.height > SCREEN['height'] then
			local worldDiff <const> = self.oldWorldY - self.worldY
			GAME.worldY = worldDiff
			self.player:moveBy(0, GAME.worldY)
			self:adjustLevel(0, GAME.worldY)
		else
			GAME.worldY = 0
		end
	end)
end



--- This method checks if a table contains a value
--- @param  tab  table   The table which you wish to check for a value
--- @param  val  string  The value you wish to query the table with
function World:has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end



--- This function contains all the details on how to load a room, and spawning all the hazards/objects inside that room
--- @param  level  string  Contains the name of the level to load as a string
function World:goToLevel(level)	
	ldtk.load_level(level) -- Load the next level
	gfx.sprite.removeAll() -- Remove all playdate sprites

	-- Save the Width and Height of the Level
	local levelSize <const> = LDtk.get_size(level)
	self.width = levelSize['width']
	self.height = levelSize['height']

	-- World coordinates
	local worldCoords <const> = LDtk.get_world_coords(level)
	self.oldWorldY = self.worldY
	self.worldY = worldCoords['worldY']

	-- Update local level attribute and build the new tile map
	GAME.playerLevel = level
	for layer_name, layer in pairs(ldtk.get_layers(level)) do
		if layer.tiles then
			local tilemap <const> = ldtk.create_tilemap(level, layer_name)
			local layerSprite <const> = gfx.sprite.new()

			if layer_name == 'Foreground' then
				layer.zIndex = Z_INDEXES.Foreground
			end

			layerSprite:setTilemap(tilemap)
			layerSprite:setCenter(0, 0)
			layerSprite:moveTo(0, 0)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			-- Draw Solid Walls
			local emptyTiles <const> = ldtk.get_empty_tileIDs(level, 'Solid', layer_name)
			if emptyTiles then
				self:addFullWallSprites(tilemap, emptyTiles)
			end

			-- Draw Half Walls
			local emptyTiles <const> = ldtk.get_empty_tileIDs(level, 'Half', layer_name)
			if emptyTiles then
				self:addHalfWallSprites(tilemap, emptyTiles)
			end
		end
	end

	-- Now the new tile map has been created, spawn all the entities
	for _, entity in ipairs(ldtk.get_entities(level)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name
		local entityTags = entity.tags

		-- Match the entity name to a script
		if self:has_value(entityTags, 'Spike') then
			Spike(entityX, entityY, entity)
		elseif self:has_value(entityTags, 'Door') then
			Door(entityX, entityY, entity)
		elseif self:has_value(entityTags, 'Reptile') then
			Reptile(self, entityX, entityY + 8, entity)
		elseif entityName == 'Healthpotion' then
			Healthpotion(entityX, entityY, entity)
		elseif entityName == 'Staminapotion' then
			Staminapotion(entityX, entityY, entity)
		elseif entityName == 'Manapotion' then
			Manapotion(entityX, entityY, entity)
		elseif entityName == "Butterfly" then
			Butterfly(entityX, entityY + 8, entity)
		elseif entityName == 'Firefly' then
			Firefly(entityX, entityY + 4, entity)
		elseif entityName == 'Spikeball' then
			Spikeball(entityX, entityY, entity)
		elseif entityName == 'Bubble' then
			Bubble(entityX, entityY, entity)
		elseif entityName == 'Flag' then
			Flag(entityX, entityY, entity)
		elseif entityName == 'Fragile' then
			Block(entityX, entityY, entity)
		elseif entityName == 'Crown' then
			Crown(entityX, entityY)
		elseif entityName == 'Fan' then
			Fan(entityX, entityY, entity)
			Wind(entityX - 8, entityY - 80, entity.fields.strength)
		elseif entityName == 'Roaster' then
			Roaster(entityX, entityY, entity)
		else
			Prop(entityX, entityY, entityName)
		end
	end

	-- Load the Background & Name
	self:loadBackground(level)
	self:loadName(level)

	-- Load the status bars
	self.health = Bar('health', 2, 2)
	self.stamina = Bar('stamina', 2, 18)
	self.mana = Bar('mana', 2, 34)

	pd.resetElapsedTime() -- Reset time elapsed to stop player accelerating when changing rooms
end



function World:addFullWallSprites(tilemap, emptyTiles)
	Fulls = gfx.tilemap.getCollisionRects(tilemap, emptyTiles)
	for _, tile in pairs(Fulls) do
		tile.x = tile.x * 16
		tile.y = tile.y * 16
		tile.w = tile.w * 16
		tile.h = tile.h * 16

		if tile.x == 0 then
			tile.x = -32
			tile.w = tile.w + 32
		elseif tile.x + tile.w == self.width then
			tile.w = tile.w + 32
		end

		if tile.y == 0 then
			tile.y = -64
			tile.h = tile.h + 64
		elseif tile.y + tile.h == 240 then
			tile.h = tile.h + 16
		end

		gfx.sprite.addEmptyCollisionSprite(tile.x, tile.y, tile.w, tile.h)
	end
end



--- This Method is Used to Create Half Tile Hit Boxes for the Player to Interact With
--- @param  tilemap     The Map of Tiles Used to Create the Rects
--- @param  emptyTiles  The Tiles That are not Half Tiles
function World:addHalfWallSprites(tilemap, emptyTiles)
	Halfs = gfx.tilemap.getCollisionRects(tilemap, emptyTiles)
	for _, tile in pairs(Halfs) do
		if tile.h > 1 then
			for i = tile.h, 1, -1 do
				local x = tile.x * 16
				local y = (tile.y + (i - 1)) * 16
				local w = tile.w * 16
				local h = 16

				if x == 0 then
					x = -32
					w = w + 32
				elseif x + w == self.width then
					w = w + 32
				end

				if y == 0 then
					y = -64
					h = h + 64
				elseif y + h == 240 then
					h = h + 16
				end

				Half(x, y, w, h)
			end
		else
			tile.x = tile.x * 16
			tile.y = tile.y * 16
			tile.w = tile.w * 16
			tile.h = tile.h * 16

			if tile.x == 0 then
				tile.x = -32
				tile.w = tile.w + 32
			elseif tile.x + tile.w == self.width then
				tile.w = tile.w + 32
			end

			if tile.y == 0 then
				tile.y = -64
				tile.h = tile.h + 64
			elseif tile.y + tile.h == 240 then
				tile.h = tile.h + 16
			end

			Half(tile.x, tile.y, tile.w, tile.h)
		end
	end
end



--- Load the background for the level sent into the function
--- @param  level  string  The ID of the level to load the background of
function World:loadBackground(level)
	local bg <const> = LDtk.get_background(level)

	if bg then
		local pos <const> = LDtk.get_background_position(level)

		if pos == 'Repeat' then
			local bgAmount = 0
			local nextBackground = 0

			if self.width >= SCREEN['width'] then
				bgAmount = self.width / SCREEN['width']
				bgAmount = math.floor(bgAmount + 0.9)
				nextBackground = 0
	
				for i = 1, bgAmount do
					Background(nextBackground, 0, bg)
					nextBackground = nextBackground + SCREEN['width']
				end
			end

			if self.height >= SCREEN['height'] then
				bgAmount = self.height / SCREEN['height']
				bgAmount = math.floor(bgAmount + 0.9)
				nextBackground = 0

				for i = 1, bgAmount do
					Background(0, nextBackground, bg)
					nextBackground = nextBackground + SCREEN['height']
				end
			end
		else
			Background(0, 0, bg)
		end
	end
end



--- Load the name for the level sent into the function
--- @param  level  string  The ID of the level to load the name of
function World:loadName(level)
	local name = ldtk.get_custom_data(level, 'name')
	if name and name ~= self.oldLevelName then
		self.oldLevelName = name
		Text(name, 2, 2)
	end
end



--- This Method Moves the Player to Their Spawn Room and Coordinates
function World:resetPlayer()
	if GAME.playerLevel ~= GAME.playerSpawnLevel then
		self:goToLevel(GAME.playerSpawnLevel)
		self.player:add()
		GAME.worldX = 0
	end

	-- Remove any transition sprites
	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Fade) or sprite:isa(Wipe) then
			sprite:remove()
		end
	end

	-- Reset no spawn list to empty
	GAME:emptySpawnList()

	-- Move player to the spawn coordinates and set them to the spawn state
	self.player:moveTo(GAME.playerSpawnX, GAME.playerSpawnY)
	self.player:changeToSpawnState()

	Fade('in')
end



--- This Function is Called by the Player to Update the World X Coordinate
function World:update()
	GAME.worldX = GAME.worldX + self.player.xVelocity * DELTA_TIME
	GAME.worldY = GAME.worldY + self.player.yVelocity * DELTA_TIME
	self:adjustLevel(self.player.xVelocity * DELTA_TIME, self.player.yVelocity * DELTA_TIME)
end



--- Adjust the level X value to keep the player on the screen
--- @param  xAmount  integer  The amount to move the level by
function World:adjustLevel(xAmount, yAmount)
	xAmount, yAmount = self:levelCorrection(xAmount, yAmount)

	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Bar) or sprite:isa(Text) then
			return
		end

		sprite:moveBy(-xAmount, -yAmount)
	end
end



--- Check if the Level X Amount needs Correction
--- @param  xAmount  The Amount to Move the Level
function World:levelCorrection(xAmount, yAmount)
	if GAME.worldX > self.width - SCREEN['width'] then
		local xCorrection <const> = GAME.worldX - (self.width - SCREEN['width'])
		xAmount = xAmount - xCorrection
		GAME.worldX = self.width - SCREEN['width']
	end

	if GAME.worldX < 0 then
		local xCorrection <const> = xAmount - GAME.worldX
		xAmount = xCorrection
		GAME.worldX = 0
	end

	if GAME.worldY > self.height - SCREEN['height'] then
		local yCorrection <const> = GAME.worldY - (self.height - SCREEN['height'])
		yAmount = yAmount - yCorrection
		GAME.worldY = self.height - SCREEN['height']
	end

	if GAME.worldY < 0 then
		local yCorrection <const> = yAmount - GAME.worldY
		yAmount = yCorrection
		GAME.worldY = 0
	end

	return xAmount, yAmount
end
