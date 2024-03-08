-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the lizard class
class('Lizard').extends(AnimatedSprite)


--- The Lizard is initialised using this method
--- @param x integer The X coordinate to spawn the lizard
--- @param y integer The Y coordinate to spawn the lizard
function Lizard:init(x, y)
	-- Create the Lizard state machine with the lizard tile set
	Lizard.super.init(self, gfx.imagetable.new("images/lizard-table-16-8"))

	-- Lizard states, sprites, and animation speeds
	self:addState("idle", 1, 1)
	self:addState("blep", 2, 4, {tickStep = 3})
	self:addState("walk", 5, 8, {tickStep = 3})
	self:playAnimation()

	-- Lizard properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Animal)
	self:setTag(TAGS.Animal)
	self:setCollideRect(4, 4, 8, 4)

	-- Physics properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 1.0
	self.speed = 2
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	-- Lizard attributes
	self.globalFlip = 0
	self.timerActive = false
	self.touchingGround = false
	self.touchingWall = false
	self.dead = false
end


-- This method is used to handle the collisions the lizard has with the world
--- @param  other   table   Contains what the lizard has collided with
--- @return unknown unknown The collision response for the object
function Lizard:collisionResponse(other)
	local tag <const> = other:getTag()
	if tag == TAGS.Hazard or tag == TAGS.Pickup or tag == TAGS.Flag or tag == TAGS.Prop or tag == TAGS.Door or tag == TAGS.Player then
		return gfx.sprite.kCollisionTypeOverlap
	end
	
	return gfx.sprite.kCollisionTypeSlide
end


--- The lizard update method runs every game tick
function Lizard:update()
	self:updateAnimation()

	if self.dead then
		self:remove()
	end

	self:handleState()
	self:handleMovementAndCollisions()
end


--- Handles the changing states of the lizard
function Lizard:handleState()
	self:applyGravity()
	self:handleGroundInput()
end


--- Handles all lizard movement and any collisions it has
function Lizard:handleMovementAndCollisions()
	-- Get a list of collisions
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

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
		if collisionTag == TAGS.Hazard then
			self.dead = true
		end
	end

	-- Change Lizard direction based on xVelocity
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- Let's delete the lizard if they travel off the screen
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


--- Handle the possible ground events for the lizard
function Lizard:handleGroundInput()
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


--- Have the lizard flick its tongue
function Lizard:changeToBlepState()
	self.xVelocity = 0
	self:changeState("blep")
	pd.timer.performAfterDelay(200, function()
		self:changeState("idle")
	end)
end


--- Have the lizard walk in a given direction for a while
function Lizard:changeToWalkState(direction)
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


--- Applies gravity to the lizard
function Lizard:applyGravity()
	self.yVelocity = self.yVelocity + self.gravity
	if self.touchingGround then
		self.yVelocity = 0
	end
end