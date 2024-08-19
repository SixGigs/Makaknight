local gfx <const> = playdate.graphics


class('Fan').extends(AnimatedSprite)


--- Initialise the spike object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
--- @param e table   The entity that come with the spike
function Fan:init(x, y, e)
	Fan.super.init(self, gfx.imagetable.new("images/hazards/" .. string.lower(e.name) .. "-table-32-16"))

	self:addState("spin", 1, 8, {ts = 1})
	self:playAnimation()

	self.damage = e.fields.damage

	self:setCollideRect(0, 0, 32, 16)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:add()
end