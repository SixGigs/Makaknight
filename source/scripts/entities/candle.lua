local gfx <const> = playdate.graphics
class('Candle').extends(AnimatedSprite)

--- The Prop class is used to spawn decoration entities
--- @param  x  integer  The X coordinate to spawn the spike
--- @param  y  integer  The Y coordinate to spawn the spike
--- @param  n  string   The name of the Prop to create as a prop
function Candle:init(x, y, n)
	local i <const> = gfx.imagetable.new('images/entities/animated/' .. n .. '-table-16-8')
	Candle.super.init(self, i)

	self:addState(0, 1, 4, {ts = 4})
	self:playAnimation()

	self:setCenter(0, 0)
	self:moveTo(x, y + 8)
	self:setZIndex(Z_INDEXES.Prop)
	self:setTag(TAGS.Prop)
	self:add()
end