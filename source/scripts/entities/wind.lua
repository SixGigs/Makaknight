-- Creating the Playdate Graphics Module as a Constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Wind Class
class("Wind").extends(gfx.sprite)


--- Initialise the Wind Entity Using the Data Given
function Wind:init(x, y, s, d)
	self.strength = s
	self.direction = d

	self:moveTo(x, y)
	self:setCollideRect(0, 0, 48, 88)
	self:setZIndex(Z_INDEXES.Wind)
	self:setTag(TAGS.Wind)
	self:add()
end


--- Collision Method for Applying Force to an Entity
--- @param  entity  object  The entity to apply force to
function Wind:handleCollision(entity)
	if self.direction == 'left' then
		if entity.xVelocity >= -25 then
			entity.xVelocity = entity.xVelocity - self.strength
		end
	elseif self.direction == 'up' then
		if entity.yVelocity >= -150 then
			entity.yVelocity = entity.yVelocity - self.strength
		end
	end
end