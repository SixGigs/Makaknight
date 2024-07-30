local gfx <const> = playdate.graphics

-- Create the door class
class("Door").extends(gfx.sprite)


--- Initialise the door object using the data given
--- @param x integer The X coordinate to spawn the door
--- @param y integer The Y coordinate to spawn the door
--- @param e table   The table of entity attributes in the door
function Door:init(x, y, e)
	-- Use entity attribute 'doorSprite' to load the correct sprite
	local img = gfx.image.new("images/doors/" .. e.name)

	-- The level, X, & Y values the door leads to
	self.level = e.fields.level
	self.exitX = e.fields.exitX * 16 + 16
	self.exitY = e.fields.exitY * 16 + 8

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Door)
	self:setTag(TAGS.Door)
	self:setCollideRect(12, 32, 8, 16)
	self:setImage(img)
	self:add()
end