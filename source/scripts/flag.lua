-- Create playdate and playdate.graphics as constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the checkpoint class
class('Flag').extends(AnimatedSprite)


--- Checkpoints are created using this method
--- @param x      integer The X coordinate to spawn the checkpoint
--- @param y      integer The Y coordinate to spawn the checkpoint
--- @param entity table   The list of entities the checkpoint has
--- @param gameManager table The game manager passed into the object
function Flag:init(x, y, entity, gameManager)
	-- Initialise the state machine using the flag sprite sheet
	Flag.super.init(self, gfx.imagetable.new("images/flag-table-64-48"))

	-- Set states in the state machine
	self:addState("down", 1, 1)
	self:addState("raise", 2, 9, {tickStep = 1.5})
	self:addState("up", 10, 14, {tickStep = 3})
	self:addState("lower", 15, 24, {tickStep = 1.5})
	self:playAnimation()

	-- Save the ID of the flag as an attribute
	self.id = entity.iid
	print(self.id)

	-- If the ID of the checkpoint in the save file matches the flag ID,
	-- The flag spawns up, if not then the flag spawns down
	if self.id == gameManager.flag then
		self.active = true
		self:changeState("up")
	else
		self.active = false
		self:changeState("down")
	end

	-- Flag properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Flag)
	self:setTag(TAGS.Flag)
	self:setCollideRect(29, 21, 5, 27)
end


--- Hoist the flag. This method is called from the player when they collide with the flag
--- TODO: Can we get this method called from this object using the update? If when updating the player collides with self?
function Flag:hoist()
	if self.active == false then
		self.active = true
		self:changeState("raise")
		pd.timer.performAfterDelay(325, function()
			self:changeState("up")
		end)
	end
end


--- Lower the flag. This method is called from the player when any collision is recorded against a flag
--- TODO: Can we get this method called from this object using the update? Get any existing checkpoints and deactivate them?
function Flag:lower()
	if self.active == true then
		self.active = false
		self:changeState("lower")
		pd.timer.performAfterDelay(325, function()
			self:changeState("down")
		end)
	end
end