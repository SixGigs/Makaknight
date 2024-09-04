-- Create Constants for the Playdate and Playdate Graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the Animal Class
class("Animal").extends(AnimatedSprite)


--- The Animal is Initialised Using This Method
--- @param  x  integer  The X Coordinate to Spawn the Animal
--- @param  y  integer  The Y Coordinate to Spawn the Animal
--- @param  e  integer  The Entity Used to Create the Animal
function Animal:init(x, y, e)
	-- Create the Animal State Machine with the Animated Sprite Library
	Animal.super.init(self, gfx.imagetable.new("images/animals/" .. string.lower(e.name) .. "-table-" .. e.fields.tableWidth .. "-" .. e.fields.tableHeight))

	-- Physics Properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.speed = e.fields.speed

	-- Animal Attributes
	self.globalFlip = tonumber(e.fields.facing)
	self.dead = false

	-- Collision Attribute Table
	self.overlapTags = {
		[TAGS.Hazard] = true,
		[TAGS.Pickup] = true,
		[TAGS.Flag] = true,
		[TAGS.Prop] = true,
		[TAGS.Door] = true,
		[TAGS.Animal] = true,
		[TAGS.Player] = true,
		[TAGS.Hitbox] = true,
		[TAGS.Crown] = true,
		[TAGS.GUI] = true,
		[TAGS.Bubble] = true,
		[TAGS.Fragileblock] = true,
		[TAGS.Wind] = true
	}

	-- Animal Properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Animal)
	self:setTag(TAGS.Animal)
end


--- This Method is Used to Return Collision Responses the Animal has with the World
--- @param   e        table    The Entity the Animal has just Collided with
--- @return  unknown  unknown  The Collision Response for the Entity
function Animal:collisionResponse(e)
	local tag <const> = e:getTag()

	if self.overlapTags[tag] then
		if tag == TAGS.Fragileblock then
			if e.currentState == "breaking" or e.currentState == "broken" then
				return gfx.sprite.kCollisionTypeOverlap
			end
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The Animal Update Method Runs Every Game Tick
function Animal:update()
	self:updateAnimation()

	if self.dead then
		self:remove()
	end

	self:handleState()
	self:handleMovementAndCollisions()
end


--- Handles All Animal Movement and Any Collisions it has
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
		elseif collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Roaster then
			collisionObject:handleCollision()
		elseif collisionTag == TAGS.Bubble then
			self.touchingGround = false
			collisionObject:pop(self)
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