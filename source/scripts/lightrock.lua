-- Creating the script constants
local gfx <const> = playdate.graphics
local rockImage <const> = gfx.image.new("images/light-rock")

-- Create the light rock class
class('Lightrock').extends(gfx.sprite)

--- Initialise the rock object using the data given
--- @param x integer The X coordinate to spawn the spike
--- @param y integer The Y coordinate to spawn the spike
function Lightrock:init(x, y)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	-- self:setCollideRect(2, 9, 12, 7)
	self:setImage(rockImage)
	self:add()
end