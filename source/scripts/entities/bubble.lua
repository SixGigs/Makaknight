local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Bubble').extends(AnimatedSprite)


--- Initialise the Bubble object using the data given
--- @param  x  integer  The X coordinate to spawn the Bubble pick-up
--- @param  y  integer  The Y coordinate to spawn the Bubble pick-up
--- @param  e  object   The table of entities related to the Bubble
function Bubble:init(x, y, e)
	Bubble.super.init(self, gfx.imagetable.new('images/entities/bubble-table-16-16'))

	self:addState('a', 1, 4, {ts = 4})
	self:addState('pop', 5, 5, {ts = 1, l = 1})
	self:playAnimation()

	self.states['pop'].onAnimationEndEvent = function(self) self:setVisible(false) end
	self.timer = e.fields.respawn * 1000

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Bubble)
	self:setTag(TAGS.Bubble)
	self:setCollideRect(0, 4, 16, 16)
	self:add()
end


--- This method handles the Bubble being picked up by the entity
--- @param entity table The entity is passed into this function to manage the pick-up
function Bubble:pop(e)
	if self:isVisible() then
		e.yVelocity = -270

		pd.timer.performAfterDelay(self.timer, function()
			self:changeState('a')
			self:setVisible(true)
		end)

		self:changeState('pop')
	end
end