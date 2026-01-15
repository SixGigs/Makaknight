local gfx <const> = playdate.graphics
class('Spike').extends(gfx.sprite)

--- Initialise the spike object using the data given
--- @param  x  integer The X coordinate to spawn the spike
--- @param  y  integer The Y coordinate to spawn the spike
--- @param  e  table   The entity that come with the spike
function Spike:init(x, y, w, h)
	-- Resize the spike hit box to make collisions tighter
	x = x + 2
	y = y + 2
	h = h - 4
	w = w - 4

	-- Set spike direction if possible
	local direction = "none"
	if w >= h then
		direction = "up/down"
	else
		direction = "left/right"
	end

	self.direction = direction
	self:moveTo(x, y)
	self:setCollideRect(0, 0, w, h)
	self:setTag(TAGS.Hazard)
	self:setZIndex(Z_INDEXES.Hazard)
	self:add()
end



--- Handle collisions of living entities with the spike entity
function Spike:handleCollision(e)
	local damage = 0

	if self.direction == "up/down" then
		if e.yVelocity > 45 or e.yVelocity < 0 and e.yVelocity > -156 then
			damage = 150
		end
	elseif self.direction == "left/right" then
		if e.xVelocity > 135 or e.xVelocity < -135 then
			damage = 150
		end
	else
		if e.yVelocity > 45 or e.yVelocity < 0 and e.yVelocity > -156 then
			damage = 150
		elseif e.xVelocity > 135 or e.xVelocity < -135 then
			damage = 150
		end
	end

	if damage ~= 0 then
		e.hp = e.hp - damage

		-- Round HP back up to 0 if it is less than zero
		if e.hp < 0 then
			e.hp = 0
		end
	end
end