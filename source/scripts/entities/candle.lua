local gfx <const> = playdate.graphics
class('Candle').extends(AnimatedSprite)

--- The Prop class is used to spawn decoration entities
--- @param  x  integer  The X coordinate to spawn the spike
--- @param  y  integer  The Y coordinate to spawn the spike
--- @param  n  string   The name of the Prop to create as a prop
function Candle:init(e)	
	local i <const> = gfx.imagetable.new('images/entities/animated/' .. string.lower(e.name) .. '-table-' .. e.fields.width .. '-' .. e.fields.height)
	local x <const> = e.position.x + e.fields.xOffset
	local y <const> = e.position.y + e.fields.yOffset
	local l <const> = i:getLength()

	Candle.super.init(self, i)

	self:addState(0, 1, l, {ts = e.fields.tickSpeed})
	self:playAnimation()

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	self:setTag(TAGS.Prop)
	self:add()
end