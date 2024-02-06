-- Create the script constants
local gfx <const> = playdate.graphics

-- Create the door class
class('Door').extends(gfx.sprite)


--- Initialise the ability object using the data given
--- @param x      integer The X coordinate to spawn the ability pick-up
--- @param y      integer The Y coordinate to spawn the ability pick-up
--- @param entity table   The table of entities related to the ability
function Door:init(x, y, entity)
	-- If the ability has been picked up don't spawn it
	self.fields = entity.fields

	-- If the ability hasn't been picked let's spawn it
	self.doorSprite = self.fields.doorSprite
	local doorImage = gfx.image.new("images/"..self.doorSprite)
	assert(doorImage)

	-- The level the entry leads to
	self.level = self.fields.level

	-- Get the exit X and Y
	self.exitX = self.fields.exitX
	self.exitY = self.fields.exitY

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Door)
	self:setTag(TAGS.Door)
	self:setCollideRect(7, 16, 2, 16)
	self:setImage(doorImage)
	self:add()
end


function Door:getNextLevelID()
	return self.level
end

function Door:getExitX()
	return self.exitX
end

function Door:getExitY()
	return self.exitY
end