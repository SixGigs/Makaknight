local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Animal').extends(AnimatedSprite)



--- The Animal is Initialised Using This Method
--- @param  x  integer  The X Coordinate to Spawn the Animal
--- @param  y  integer  The Y Coordinate to Spawn the Animal
--- @param  e  integer  The Entity Used to Create the Animal
function Animal:init(x, y, e)
	-- Create the Animal State Machine with the Animated Sprite Library
	Animal.super.init(self, gfx.imagetable.new('images/animals/'.. string.lower(e.name) .. '-table-' .. e.fields.tableWidth .. '-' .. e.fields.tableHeight))

	-- Animal properties
	self.id = e.iid
	self.hp = e.fields.hp
	self.max_hp = e.fields.hp
	self.weight = e.fields.weight
	self.spawn_x = x
	self.spawn_y = y

	-- If the animal ID is on the don't spawn list, hide the animal
	if g.depletedEntities[self.id] then
		self:setVisible(false)
	end

	-- Dynamic properties
	if e.fields.heals then self.heals = e.fields.heals end

	-- Physics Properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.speed = e.fields.speed

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
		[TAGS.Fragile] = true,
		[TAGS.Wind] = true,
		[TAGS.Half] = true
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
		if tag == TAGS.Fragile or tag == TAGS.Half then
			return e:collision(self)
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The Animal Update Method Runs Every Game Tick
function Animal:update()
	if not self:isVisible() then
		return
	end

	if self.hp <= 0 then
		g.depletedEntities[self.id] = true
		self:setVisible(false)
	end

	self:updateAnimation()
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
		if collisionTag == TAGS.Hazard or collisionTag == TAGS.Hitbox or collisionTag == TAGS.Spike then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Roaster then
			collisionObject:handleCollision()
		elseif collisionTag == TAGS.Bubble then
			self.touchingGround = false
			collisionObject:pop(self)
		elseif collisionTag == TAGS.Fragile then
			collisionObject:handleCollision(self, collision)
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
		self.hp = 0
	elseif self.x > 408 then
		self.hp = 0
	elseif self.y < -12 then
		self.hp = 0
	elseif self.y > 264 then
		self.hp = 0
	end
end


--- Handle collisions
function Animal:handleCollision(obj)
	if not self:isVisible() then
		return
	end

	self.hp = self.hp - obj.damage
	if self.hp < 0 then
		self.hp = 0
	end

	if self.hp == 0 then
		if self.heals then
			obj.hp = obj.hp + self.heals
			if obj.hp > obj.max_hp then
				obj.hp = obj.max_hp
			end
		end
	end
end