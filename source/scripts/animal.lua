-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Animal class
class("Animal").extends(AnimatedSprite)


--- The Animal is initialised using this method
--- @param x integer The X coordinate to spawn the Animal
--- @param y integer The Y coordinate to spawn the Animal
function Animal:init(x, y, e)
	-- Create the Animal state machine with the Animal tile set
	Animal.super.init(self, gfx.imagetable.new("images/animals/" .. string.lower(e.name) .. "-table-" .. e.fields.tableWidth .. "-" .. e.fields.tableHeight))

	-- Animal states, sprites, and animation speeds
	if e.fields.fly then
		self:addState("fly", 1, 4, {tickStep = 3})
	else
		self:addState("idle", 1, 1)
		self:addState("blep", 2, 4, {tickStep = 3})
		self:addState("walk", 5, 8, {tickStep = 3})
	end
	self:playAnimation()

	-- Animal properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Animal)
	self:setTag(TAGS.Animal)
	self:setCollideRect(0, 0, e.fields.tableWidth, e.fields.tableHeight)

	-- Physics properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.speed = e.fields.speed
	self.gravity = 1.0
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	-- Animal attributes
	self.globalFlip = tonumber(e.fields.facing)
	self.timerActive = false
	self.touchingGround = false
	self.touchingWall = false
	self.fly = e.fields.fly
	self.dead = false
end


--- This method is used to handle the collisions the Animal has with the world
--- @param  other   table   Contains what the Animal has collided with
--- @return unknown unknown The collision response for the object
function Animal:collisionResponse(other)
	local tag <const> = other:getTag()
	if tag == TAGS.Hazard or tag == TAGS.Pickup or tag == TAGS.Flag or tag == TAGS.Prop or tag == TAGS.Door or tag == TAGS.Player or tag == TAGS.Animal or tag == TAGS.Hitbox then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The Animal update method runs every game tick
function Animal:update()
	self:updateAnimation()

	if self.dead then
		self:remove()
	end

	if self.fly then self:handleFlight() else self:handleState() end
	self:handleMovementAndCollisions()
end


--- Handles the changing states of the Animal
function Animal:handleState()
	self:applyGravity()
	self:handleGroundInput()
end


--- Handle the possible ground events for the Animal
function Animal:handleFlight()
	if self.timerActive then
		return
	end

	if not self.timer then
		self.timer = true
		pd.timer.performAfterDelay(math.random(50, 150), function()
			local xSpeed <const> = math.random(-self.speed, self.speed)
			local ySpeed <const> = math.random(-self.speed, self.speed)
			self.xVelocity = xSpeed * dt
			self.yVelocity = ySpeed * dt
			self.timer = false
		end)
	end
end


--- Handles all Animal movement and any collisions it has
function Animal:handleMovementAndCollisions()
	-- Get a list of collisions
	local _, _, collisions, length = self:moveWithCollisions(self.x + (self.xVelocity * dt), self.y + (self.yVelocity * dt))

	-- Reset the collision tracking attributes
	self.touchingGround = false
	self.touchingWall = false

	-- Loop through collisions if there are any
	for i = 1, length do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		local collisionObject <const> = collision.other
		local collisionTag <const> = collisionObject:getTag()

		-- Let's test the collision type
		if collisionType == gfx.sprite.kCollisionTypeSlide then
			if collision.normal.y == -1 then
				self.touchingGround = true
			end

			if collision.normal.x ~= 0 then
				self.touchingWall = true
			end
		end

		-- Process the collision based on the collision tag
		if collisionTag == TAGS.Hazard or collisionTag == TAGS.Hitbox then
			self.dead = true
		end
	end

	-- Change Animal direction based on xVelocity
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- Let's delete the Animal if they travel off the screen
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
function Animal:handleGroundInput()
	if self.timerActive then
		return
	end

	self.timerActive = true
	pd.timer.performAfterDelay(math.random(500, 2000), function()
		local action <const> = math.random(1, 2)

		if action == 1 then
			self:changeToBlepState()
		elseif action == 2 then
			self:changeToWalkState(math.random(0, 1))
		end

		self.timerActive = false
	end)
end


--- Have the Animal flick its tongue
function Animal:changeToBlepState()
	self.xVelocity = 0
	self:changeState("blep")
	pd.timer.performAfterDelay(200, function()
		self:changeState("idle")
	end)
end


--- Have the Animal walk in a given direction for a while
function Animal:changeToWalkState(direction)
	if direction == 0 then
		self.xVelocity = -self.speed
		self.globalFlip = 1
	else
		self.xVelocity = self.speed
		self.globalFlip = 0
	end

	self:changeState("walk")
	pd.timer.performAfterDelay(math.random(200, 600), function()
		self.xVelocity = 0
		self:changeState("idle")
	end)
end


--- Applies gravity to the Animal
function Animal:applyGravity()
	self.yVelocity = self.yVelocity + self.gravity
	if self.touchingGround then
		self.yVelocity = 0
	end
end