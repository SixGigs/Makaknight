local pd <const> = playdate
local gfx <const> = playdate.graphics
class('FragileBlock').extends(AnimatedSprite)


--- Initialise the FragileBlock object using the data given
--- @param  x  integer  The X coordinate to spawn the FragileBlock pick-up
--- @param  y  integer  The Y coordinate to spawn the FragileBlock pick-up
--- @param  e  object   The entity object related to the FragileBlock
function FragileBlock:init(x, y, e)
	FragileBlock.super.init(self, gfx.imagetable.new('images/hazards/fragileblock-table-32-32'))

	self:addState('solid', 1, 1)
	self:addState('cracking', 2, 6, {ts = 1, l = 1, na = 'breaking'})
	self:addState('breaking', 7, 11, {ts = 2, l = 1, na = 'broken'})
	self:addState('broken', 12, 12)
	self:playAnimation()

	local timer <const> = e.fields.respawn * 1000
	self.states['breaking'].onAnimationEndEvent = function(self) 
		pd.timer.performAfterDelay(timer, function()
			self:changeState('solid')
		end)
	end

	self:setCenter(0.25, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Fragile)
	self:setTag(TAGS.Fragile)
	self:setCollideRect(8, 0, 16, 16)
	self:add()
end


--- Handle Collisions with the FragileBlock
--- @param  e  object  The entity colliding with the block
function FragileBlock:handleCollision(e, collision)
	if collision.normal.y == -1 then
		if self.currentState == 'solid' and e.weight >= 50 then
			local newState = e.weight >= 100 and 'breaking' or 'cracking'
			self:changeState(newState)
		end
	else
		if e.xVelocity >= 75 or e.xVelocity <= -75 then
			self:changeState('breaking')
		end
	end
end