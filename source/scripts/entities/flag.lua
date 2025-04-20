-- Create playdate and playdate.graphics as constant
local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Flag').extends(AnimatedSprite)



--- Checkpoints are created using this method
--- @param x      integer The X coordinate to spawn the checkpoint
--- @param y      integer The Y coordinate to spawn the checkpoint
--- @param entity table   The list of entities the checkpoint has
--- @param gameManager table The game manager passed into the object
function Flag:init(x, y, entity)
	-- Initialise the state machine using the flag sprite sheet
	local i <const> = gfx.imagetable.new('images/entities/animated/flag-table-64-48')
	Flag.super.init(self, i)

	-- Set states in the state machine
	self:addState('down', 1, 1)
	self:addState('raise', 2, 9, {ts = 1.5, l = 1, na = 'up'})
	self:addState('up', 10, 14, {ts = 3})
	self:addState('lower', 15, 24, {ts = 1.5, l = 1, na = 'down'})
	self:playAnimation()

	-- Save the ID of the flag as an attribute
	self.id = entity.iid

	-- If the ID of the checkpoint in the save file matches the flag ID,
	-- The flag spawns up, if not then the flag spawns down
	if self.id == GAME.checkpoint then
		self:changeState('up')
	else
		self:changeState('down')
	end

	-- Flag properties
	self:setCenter(0.375, 0)
	self:setCollideRect(29, 15, 5, 33)
	self:setZIndex(Z_INDEXES.Flag)
	self:setTag(TAGS.Flag)
	self:moveTo(x, y)
end



--- Hoist the flag. This method is called from the player when they collide with the flag
--- TODO: Can we get this method called from this object using the update? If when updating the player collides with self?
function Flag:hoist()
	-- Change the flag state to raise
	if self.currentState == 'down' then
		self:changeState('raise')
	end

	-- Update the game properties
	GAME.checkpoint = self.id
	GAME.playerSpawnLevel = GAME.playerLevel
	GAME.playerSpawnY = self.y + 8
	GAME.playerSpawnX = (GAME.playerFacing == 0 and self.x - 8 or self.x + 24)

	-- Respawn all depleted entities
	GAME:emptySpawnList()	
end



--- Lower the flag. This method is called from the player when any collision is recorded against a flag
--- TODO: Can we get this method called from this object using the update? Get any existing checkpoints and deactivate them?
function Flag:lower()
	if self.currentState == 'up' then
		self:changeState('lower')
	end
end