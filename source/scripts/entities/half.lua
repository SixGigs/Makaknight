local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Half').extends(gfx.sprite)


--- Initialise a half tile object to jump and drop through
--- @param  x  integer  The X coordinate for the half tile hit box
--- @param  y  integer  The Y coordinate for the half tile hit box
--- @param  w  integer  The width of the half tile hit box in pixels
--- @param  h  integer  The height of the half tile hit box in pixels
function Half:init(x, y, w, h)
	self:moveTo(x, y)
	self:setCollideRect(0, 0, w, h)
	self:setTag(TAGS.Half)
	self:setZIndex(0)
	self:add()
end


--- This method is used to return collision types to colliding entities
--- @param  e  object  The entity that is colliding with the half tile
function Half:collision(e)
	-- Adds minus 0.1 for some leniency for collisions (stops player slipping through half tiles when moving the camera up & down)
	if e.y + (e.height / 2) - 0.05 > self.y or e.currentState == 'duck' and pd.buttonIsPressed(pd.kButtonA) or e.yVelocity >= 750 then
		return gfx.sprite.kCollisionTypeOverlap
	else
		return gfx.sprite.kCollisionTypeSlide
	end
end