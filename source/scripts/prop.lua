local gfx <const> = playdate.graphics
class('Prop').extends(gfx.sprite)

--- The Prop class is used to spawn entities that are decoration
--- @param  x     integer  The X coordinate to spawn the spike
--- @param  y     integer  The Y coordinate to spawn the spike
--- @param  name  string   The name of the Prop to create as a prop
function Prop:init(x, y, name)
	local img <const> = gfx.image.new("images/entities/" .. name)

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Prop)
	self:setImage(img)
	self:add()
end