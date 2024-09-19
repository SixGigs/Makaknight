local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Bubble').extends(AnimatedSprite)


--- Initialise the Bubble object using the data given
--- @param  x  integer  The X coordinate to spawn the Bubble pick-up
--- @param  y  integer  The Y coordinate to spawn the Bubble pick-up
--- @param  e  object   The table of entities related to the Bubble
function Bubble:init(x, y, e)
	Bubble.super.init(self, gfx.imagetable.new('images/entities/animated/bubble-table-16-16'))

	local respawnTicks <const> = e.fields.respawn * 30 / 8

	self:addState('wobble', 1, 4, {ts = 4})
	self:addState('pop', 5, 6, {ts = 1, l = 1, na = 'respawn'})
	self:addState('respawn', 6, 15, {ts = respawnTicks, l = 1, na = 'refill'})
	self:addState('refill', 16, 19, {ts = 1, l = 1, na = 'wobble'})
	self:playAnimation()

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
	if self.currentState == 'wobble' then
		e.yVelocity = -270
		self:changeState('pop')
	end
end