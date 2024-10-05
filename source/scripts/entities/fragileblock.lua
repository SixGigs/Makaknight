local pd <const> = playdate
local gfx <const> = playdate.graphics
class('FragileBlock').extends(AnimatedSprite)


--- Initialise the FragileBlock object an X & Y value, and an entity
--- @param  x  integer  The X coordinate used to spawn the fragile block 
--- @param  y  integer  The Y coordinate used to spawn the fragile block
--- @param  e  object   The fragile block entity from LDtk used for details
function FragileBlock:init(x, y, e)
	-- Initialise the object with the animated sprite library
	FragileBlock.super.init(self, gfx.imagetable.new('images/entities/animated/fragileblock-table-32-32'))

	-- Use the respawn frames and seconds set to respawn to calculate the ticks needed to respawn
	local respawnTicks <const> = e.fields.respawn * 30 / 9

	-- Set all the block animated states
	self:addState('solid', 1, 1)
	self:addState('cracking', 2, 6, {ts = 1, l = 1, na = 'breaking'})
	self:addState('breaking', 7, 11, {ts = 2, l = 1, na = 'respawning'})
	self:addState('respawning', 12, 22, {ts = respawnTicks, l = 1, na = 'refilling'})
	self:addState('refilling', 23, 26, {ts = 1, l = 1, na = 'blocked'})
	self:addState('blocked', 27, 28, {ts = 2})
	self:playAnimation()

	-- An on frame change event used to only respawn the block if it is not obstructed
	self.states['blocked'].onFrameChangedEvent = function(self)
		if not self:obstructed() then
			self:changeState('solid')
		end
	end

	-- Attributes used to calculate block breaks
	self.crackWeight = 50
	self.fallSpeedBreak = 400

	-- Attributes used to calculate a buffer if the block is obstructed
	self.bufferTicks = 3
	self.buffer = 0

	-- States in which entities can overlap the block in a collision
	self.overlapStates = {
		['breaking'] = true,
		['respawning'] = true,
		['refilling'] = true,
		['blocked'] = true
	}

	-- Playdate sprite functions used to configure the object
	self:setCenter(0.25, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Fragile)
	self:setTag(TAGS.Fragile)
	self:setCollideRect(8, 0, 16, 16)
	self:add()
end




-- This method runs every tick updating the block animation and buffer
function FragileBlock:update()
	if self.currentState == 'blocked' then
		self.buffer = math.max(self.buffer - (30 * dt), 0)
	end

	self:updateAnimation()
end




--- If this method is called it returns true if the buffer value is greater than zero
function FragileBlock:obstructed() return self.buffer > 0 end




--- Handle Collisions with the FragileBlock
--- @param  e  object  The entity colliding with the block
function FragileBlock:handleCollision(e, collision)
	-- If an entity is colliding with the block while it is refilling or blocked, reset the buffer
	if self.currentState == 'blocked' or self.currentState == 'refilling' then
		if self.overlapStates[self.currentState] then
			self.buffer = self.bufferTicks
		end
	end

	-- If the block is not solid we don't need to calculate for a break, return
	if self.currentState ~= 'solid' then return end

	-- Calculate if the block breaks and how
	if collision.normal.y == -1 and (e.weight >= 50 or e.yVelocity >= 400) then
		local newState = (e.weight >= 100 or e.yVelocity >= 400) and 'breaking' or 'cracking'
		self:changeState(newState)
	elseif collision.normal.y == 1 and e.yVelocity <= -125 or (collision.normal.x ~= 0 or collision.normal.y == 0) then
		self:changeState('breaking')
	end
end




-- This Method is Used to Return a Collision Type
function FragileBlock:collision(e)
	if self.overlapStates[self.currentState] or e.xVelocity >= 200 or e.xVelocity <= -200 or e.yVelocity >= 400 then
		return gfx.sprite.kCollisionTypeOverlap
	else
		return gfx.sprite.kCollisionTypeSlide
	end
end