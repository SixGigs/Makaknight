-- Creating the Playdate Graphics Module as a Constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Fire Class
class("Fire").extends(AnimatedSprite)


--- Initialise the Fire Object Using the Data Given
--- @param  x  integer  The X coordinate to spawn the Fire
--- @param  y  integer  The Y coordinate to spawn the Fire
--- @param  s  integer  The seconds the fire burns for
--- @param  d  integer  The damage the fire deals
function Fire:init(x, y, s, d)
	-- Initialise the Fire Class
	Fire.super.init(self, gfx.imagetable.new("images/hazards/fire-table-16-16"))

	-- Fire Animation Settings
	self:addState("burn", 1, 4)
	self:playAnimation()

	-- Fire Attributes
	self.damage = d

	-- Delete the Fire After Set Amount of Time
	pd.timer.performAfterDelay(s * 1000, function()
		self:remove()
	end)

	-- Fire Properties
	self:setCollideRect(0, 0, 16, 16)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setTag(TAGS.Hazard)
	self:add()
end