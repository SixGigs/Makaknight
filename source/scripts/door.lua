local gfx <const> = playdate.graphics
local newImage = gfx.image.new
local Z_INDEXES = Z_INDEXES
local TAGS = TAGS

-- Create the door class
class("Door").extends(gfx.sprite)


--- Initialise the door object using the data given
--- @param x integer The X coordinate to spawn the door
--- @param y integer The Y coordinate to spawn the door
--- @param e table   The table of entity attributes in the door
function Door:init(x, y, e)
	-- Use entity attribute 'doorSprite' to load the correct sprite
	local img = newImage("images/doors/" .. e.fields.sprite)

	-- The level the door leads to
	self.level = e.fields.level

	-- The coordinates the player will spawn at in the room
	local exitX = e.fields.exitX * 16 + 16
	local exitY = e.fields.exitY * 16 + 8

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Door)
	self:setTag(TAGS.Door)
	self:setCollideRect(12, 32, 8, 16)
	self:setImage(img)
	self:add()

	-- Store precomputed values
	self.exitX = exitX
	self.exitY = exitY
end


-- Used by the player in the door collision event to set where to travel to if they enter the door
function Door:getDetails()
	return self.level, self.exitX, self.exitY
end