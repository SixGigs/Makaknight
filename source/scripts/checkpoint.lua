-- Creating the script constants
local pd <const> = playdate
local gfx <const> = playdate.graphics


-- Create the checkpoint class
class('Checkpoint').extends(AnimatedSprite)

--- Checkpoints are created using this method
---@param x      integer The X coordinate to spawn the checkpoint
---@param y      integer The Y coordinate to spawn the checkpoint
---@param entity table   The list of entities the checkpoint has
function Checkpoint:init(x, y, entity)
	-- Initialise the state machine
	local gd <const> = pd.datastore.read()
	local checkpointImageTable <const> = gfx.imagetable.new("images/check-table-64-48")
	Checkpoint.super.init(self, checkpointImageTable)

	-- States
	self:addState("inactive", 1, 1)
	self:addState("activating", 2, 9, {tickStep = 1.5})
	self:addState("active", 10, 14, {tickStep = 3})
	self:addState("deactivating", 15, 24, {tickStep = 1.5})
	self:playAnimation()

	-- Sprite Properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Checkpoint)
	self:setTag(TAGS.Checkpoint)
	self:setCollideRect(28, 21, 7, 27)

	-- Let's save those checkpoint fields
	self.id = entity.fields.id
	if gd then
		if self.id == gd.checkpoint then
			self.checked = true
			self:changeState("active")
		else
			self.checked = false
			self:changeState("inactive")
		end
	else
		self.checked = false
		self:changeState("inactive")
	end
end


--- If the flag is touched let's activate it
function Checkpoint:hit()
	if self.checked == false then
		self.checked = true
		self:changeState("activating")
		pd.timer.performAfterDelay(325, function()
			self:changeState("active")
		end)
	end
end


--- Turn the flag back to an inactive state
function Checkpoint:deactivate()
	self.checked = false
	self:changeState("deactivating")
	pd.timer.performAfterDelay(325, function()
		self:changeState("inactive")
	end)
end