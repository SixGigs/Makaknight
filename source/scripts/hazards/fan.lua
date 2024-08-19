-- Creating the Playdate Graphics Module as a Constant
local gfx <const> = playdate.graphics

-- Create the Fan Class
class("Fan").extends(AnimatedSprite)


--- Initialise the Fan Object Using the Data Given
--- @param  x  integer  The X coordinate to spawn the Fan
--- @param  y  integer  The Y coordinate to spawn the Fan
--- @param  e  table    The entity that come with the Fan
function Fan:init(x, y, e)
	-- Initialise the Fan Class
	Fan.super.init(self, gfx.imagetable.new("images/hazards/" .. string.lower(e.name) .. "-table-32-16"))

	-- Fan Animation Settings
	self:addState("spin", 1, 8, {ts = 1})
	self:playAnimation()

	-- Fan Attributes
	self.damage = e.fields.damage

	-- Fan Properties
	self:setCollideRect(0, 8, 32, 8)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:add()
end