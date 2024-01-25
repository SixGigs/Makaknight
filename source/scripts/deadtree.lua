-- Creating the script constants
local gfx <const> = playdate.graphics
local treeImage <const> = gfx.image.new("images/dead-tree")

-- Create the light rock class
class('Deadtree').extends(gfx.sprite)

--- Initialise the tree object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Deadtree:init(x, y)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	-- self:setCollideRect(2, 9, 12, 7)
	self:setImage(treeImage)
	self:add()
end