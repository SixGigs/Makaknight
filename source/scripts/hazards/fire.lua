-- Creating the Playdate Graphics Module as a Constant
local gfx <const> = playdate.graphics

-- Create the Fan Class
class("Fire").extends(AnimatedSprite)


--- Initialise the Fan Object Using the Data Given
--- @param  x  integer  The X coordinate to spawn the Fan
--- @param  y  integer  The Y coordinate to spawn the Fan
--- @param  e  table    The entity that come with the Fan
function Fire:init(x, y)
	-- Initialise the Fan Class
	Fire.super.init(self, gfx.imagetable.new("images/hazards/fire-table-16-16"))

	-- Fan Animation Settings
	self:addState("burn", 1, 4, {ts = 1, l = 16})
	self:playAnimation()

	self.states["burn"].onAnimationEndEvent = function(self)
		self:remove()
	end

	-- Fan Attributes
	self.damage = 20

	-- Fan Properties
	self:setCollideRect(0, 0, 16, 16)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:add()
end