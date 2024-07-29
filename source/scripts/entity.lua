local gfx <const> = playdate.graphics

-- Create the Entity class
class("Entity").extends(gfx.sprite)

--- The Entity class is used to spawn entities that are decoration
--- @param  x     integer  The X coordinate to spawn the spike
--- @param  y     integer  The Y coordinate to spawn the spike
--- @param  name  string   The name of the entity to create as a entity
function Entity:init(x, y, name)
	-- Find and open the image to use as an entity
	local img <const> = gfx.image.new("images/entities/" .. name)

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Entity)
	self:setImage(img)
	self:add()
end