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

	-- Animal attributes
	self.globalFlip = tonumber(e.fields.facing)
	self.timerActive = false
	self.dead = false
	
	-- Collision attributes
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
		[TAGS.Bar] = true,
		[TAGS.Bubble] = true,
		[TAGS.Fragileblock] = true
	}
end


--- This method is used to handle the collisions the Animal has with the world
--- @param  other   table   Contains what the Animal has collided with
--- @return unknown unknown The collision response for the object
function Animal:collisionResponse(other)
	local tag <const> = other:getTag()

	if self.overlapTags[tag] then
		if tag == TAGS.Fragileblock then
			if other.currentState == "breaking" or other.currentState == "broken" then
				return gfx.sprite.kCollisionTypeOverlap
			end
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The Animal update method runs every game tick
function Animal:update()
	self:updateAnimation()

	if self.dead then
		self:remove()
	end

	self:handleState()
	self:handleMovementAndCollisions()
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