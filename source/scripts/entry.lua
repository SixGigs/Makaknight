-- Create the script constants
local gfx <const> = playdate.graphics

-- Create the entry class
class('Entry').extends(gfx.sprite)


--- Initialise the ability object using the data given
--- @param x      integer The X coordinate to spawn the ability pick-up
--- @param y      integer The Y coordinate to spawn the ability pick-up
--- @param entity table   The table of entities related to the ability
function Entry:init(x, y, entity)
	-- If the ability has been picked up don't spawn it
	self.fields = entity.fields

	-- If the ability hasn't been picked let's spawn it
	self.entry = self.fields.entry
	local entryImage = gfx.image.new("images/"..self.entry)
	assert(entryImage)
	
	-- The level the entry leads to
	self.level = self.fields.level
	
	-- Get the exit X and Y
	self.entryX = self.fields.entryX
	self.entryY = self.fields.entryY

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Entry)
	self:setTag(TAGS.Entry)
	self:setCollideRect(0, 0, 16, 32)
	self:setImage(entryImage)
	self:add()
end


function Entry:getEntryLevelID()
	return self.level
end

function Entry:getEntryX()
	return self.entryX
end

function Entry:getEntryY()
	return self.entryY
end