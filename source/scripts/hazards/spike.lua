local gfx <const> = playdate.graphics
class('Spike').extends(gfx.sprite)

--- Initialise the spike object using the data given
--- @param  x  integer The X coordinate to spawn the spike
--- @param  y  integer The Y coordinate to spawn the spike
--- @param  e  table   The entity that come with the spike
function Spike:init(x, y, e)
	local img <const> = gfx.image.new("images/hazards/" .. e.name)

	self.damage = e.fields.damage
	self.xVelocity = e.fields.xVelocity
	self.yVelocity = e.fields.yVelocity

	if e.name == "Stalactite" or e.name == "Roofspike" then
		self:setCollideRect(0, 0, 16, 2)
		self:setTag(TAGS.Hazard)
	else
		self:setCollideRect(0, 14, 16, 2)
		self:setTag(TAGS.Spike)
	end

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setImage(img)
	self:add()
end