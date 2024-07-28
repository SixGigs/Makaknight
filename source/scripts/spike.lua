local gfx <const> = playdate.graphics
class("Spike").extends(gfx.sprite)

--- Initialise the spike object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
--- @param e table   The entity that come with the spike
function Spike:init(x, y, e)
	local img <const> = gfx.image.new("images/hazards/" .. e.name)

	self.damage = e.fields.damage
	self.xVelocity = e.fields.xVelocity
	self.yVelocity = e.fields.yVelocity

	if e.name == "Stalactite" or e.name == "Roofspike" then
		self:setCollideRect(2, 1, 12, 2)
	else
		self:setCollideRect(2, 14, 12, 2)
	end

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:setImage(img)
	self:add()
end