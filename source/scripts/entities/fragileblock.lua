local pd <const> = playdate
local gfx <const> = playdate.graphics
class('FragileBlock').extends(AnimatedSprite)


--- Initialise the FragileBlock object using the data given
--- @param  x  integer  The X coordinate to spawn the FragileBlock pick-up
--- @param  y  integer  The Y coordinate to spawn the FragileBlock pick-up
--- @param  e  object   The entity object related to the FragileBlock
function FragileBlock:init(x, y, e)
	FragileBlock.super.init(self, gfx.imagetable.new('images/hazards/fragileblock-table-32-32'))

	local respawnTicks <const> = e.fields.respawn * 30 / 9

	self:addState('solid', 1, 1)
	self:addState('cracking', 2, 6, {ts = 1, l = 1, na = 'breaking'})
	self:addState('breaking', 7, 11, {ts = 2, l = 1, na = 'broken'})
	self:addState('broken', 12, 21, {ts = respawnTicks, l = 1, na = 'block'})
	self:addState('block', 22, 23, {ts = 2})
	self:playAnimation()

	self.states['block'].onFrameChangedEvent = function(self)
		if not self:obstructed() then
			self:changeState('solid')
		end
	end

	self.obstructedBufferAmount = 3
	self.obstructedBuffer = 0

	self.overlapStates = {
		['breaking'] = true,
		['broken'] = true,
		['block'] = true
	}

	self:setCenter(0.25, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Fragile)
	self:setTag(TAGS.Fragile)
	self:setCollideRect(8, 0, 16, 16)
	self:add()
end


-- This Method Runs Every Tick and Updates the Block Buffer
function FragileBlock:update()
	self.obstructedBuffer = math.max(self.obstructedBuffer - (30 * dt), 0)
	self:updateAnimation()
end


--- These Methods Return True if the Buffer is Greater Than Zero
function FragileBlock:obstructed() return self.obstructedBuffer > 0 end


--- Handle Collisions with the FragileBlock
--- @param  e  object  The entity colliding with the block
function FragileBlock:handleCollision(e, collision)	
	if self.overlapStates[self.currentState] then
		self.obstructedBuffer = self.obstructedBufferAmount
	end

	if self.currentState ~= 'solid' then return end

	if collision.normal.y == -1 and e.weight >= 50 then
		local newState = e.weight >= 100 and 'breaking' or 'cracking'
		self:changeState(newState)
	elseif collision.normal.y == 1 and e.yVelocity <= -125 then
		self:changeState('breaking')
	elseif (collision.normal.x ~= 0 or collision.normal.y == 0) and (math.abs(e.xVelocity) >= 125) then
		self:changeState('breaking')
	end
end


-- This Method is Used to Return a Collision Type
function FragileBlock:collision()
	if self.overlapStates[self.currentState] then
		return gfx.sprite.kCollisionTypeOverlap
	else
		return gfx.sprite.kCollisionTypeSlide
	end
end