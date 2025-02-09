local gfx <const> = playdate.graphics
class('Spike').extends(gfx.sprite)

--- Initialise the spike object using the data given
--- @param  x  integer The X coordinate to spawn the spike
--- @param  y  integer The Y coordinate to spawn the spike
--- @param  e  table   The entity that come with the spike
function Spike:init(x, y, e)
	local i <const> = gfx.image.new("images/hazards/" .. e.name)

	self.name = e.name
	self.xVelocity = e.fields.xVelocity
	self.yVelocity = e.fields.yVelocity

	if e.name == "Stalactite" or e.name == "Roofspike" then
		self:setCollideRect(1, 0, 14, 2)
	else
		self:setCollideRect(1, 14, 14, 2)
	end

	
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setTag(TAGS.Hazard)
	self:setZIndex(Z_INDEXES.Hazard)
	self:setImage(i)
	self:add()
end



--- Handle collisions of living entities with the spike entity
function Spike:handleCollision(e)
	local damage = 0

	if e.yVelocity > 90 then
		damage = e.yVelocity

		-- Divide the damage number by 10 if a damage number exists
		if damage < 0 then
			damage = 0
		else
			damage = damage / 10
		end

		-- Dividing the damage number can result in floats, make it a round number
		damage = math.floor(damage)
	else
		if self.name == "Stalactite" or self.name == "Roofspike" then
			damage = 999
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