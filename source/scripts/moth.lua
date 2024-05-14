-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Moth class
class('Moth').extends(AnimatedSprite)


--- The Moth is initialised using this method
--- @param x integer The X coordinate to spawn the Moth
--- @param y integer The Y coordinate to spawn the Moth
function Moth:init(x, y, e)
	-- Create the Moth state machine with the Moth tile set
	Moth.super.init(self, gfx.imagetable.new('images/' .. string.lower(e.name) .. '-table-4-4'))

	-- Moth states, sprites, and animation speeds
	self:addState('fly', 1, 4, {tickStep = 3})
	self:playAnimation()

	-- Moth properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Animal)
	self:setTag(TAGS.Animal)
	self:setCollideRect(0, 0, 4, 4)

	-- Physics properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.speed = e.fields.speed
	self.gravity = 1.0
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	-- Moth attributes
	self.globalFlip = 0
	self.timer = false
	self.dead = false
end


--- This method is used to handle the collisions the Moth has with the world
--- @param  other   table   Contains what the Moth has collided with
--- @return unknown unknown The collision response for the object
function Moth:collisionResponse(other)
	local tag <const> = other:getTag()
	if tag == TAGS.Hazard or tag == TAGS.Pickup or tag == TAGS.Flag or tag == TAGS.Prop or tag == TAGS.Door or tag == TAGS.Player or tag == TAGS.Animal or tag == TAGS.Hitbox then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The Moth update method runs every game tick
function Moth:update()
	self:updateAnimation()

	if self.dead then self:remove() end
	self:handleFlight()
	self:handleMovementAndCollisions()
end


--- Handles all Moth movement and any collisions it has
function Moth:handleMovementAndCollisions()
	-- Get a list of collisions
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

	-- Loop through collisions if there are any
	for i = 1, length do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		local collisionObject <const> = collision.other
		local collisionTag <const> = collisionObject:getTag()

		-- Process the collision based on the collision tag
		if collisionTag == TAGS.Hazard or collisionTag == TAGS.Hitbox then
			self.dead = true
		end
	end

	-- Change Moth direction based on xVelocity
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- Let's delete the Moth if they travel off the screen
	if self.x < -8 then
		self.dead = true
	elseif self.x > 408 then
		self.dead = true
	elseif self.y < -12 then
		self.dead = true
	elseif self.y > 264 then
		self.dead = true
	end
end

	
--- Handle the possible ground events for the Animal
function Moth:handleFlight()
	if self.timerActive then
		return
	end

	if not self.timer then
		self.timer = true
		pd.timer.performAfterDelay(math.random(50, 150), function()
			local xSpeed <const> = math.random(-self.speed, self.speed)
			local ySpeed <const> = math.random(-self.speed, self.speed)
			self.xVelocity = xSpeed
			self.yVelocity = ySpeed
			self.timer = false
		end)
	end
end