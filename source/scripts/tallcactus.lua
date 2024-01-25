-- Creating the script constants
local gfx <const> = playdate.graphics
local cactusImage <const> = gfx.image.new("images/tall-cactus")

-- Create the light rock class
class('Tallcactus').extends(gfx.sprite)

--- Initialise the tree object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Tallcactus:init(x, y)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	-- self:setCollideRect(2, 9, 12, 7)
	self:setImage(cactusImage)
	self:add()
end