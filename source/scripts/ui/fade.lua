local gfx <const> = playdate.graphics
class('Fade').extends(AnimatedSprite)


function Fade:init(direction)
	Fade.super.init(self, gfx.imagetable.new('images/transitions/fade-table-400-240'))

	self:addState('out', 1, 14, {ts = 1, na = 'blank'})
	self:addState('blank', 15, 15)
	self:addState('in', 15, 29, {ts = 1, l = 1})
	self:playAnimation()

	self.states['in'].onAnimationEndEvent = function(self) self:remove() end

	self:changeState(direction)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(Z_INDEXES.Transition)
	self:add()
end