-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the player class
class("Player").extends(AnimatedSprite)


--- The player is initialised with this method
--- @param x     integer The X coordinate to spawn the player
--- @param y     integer The Y coordinate to spawn the player
--- @param world table   The game manager is passed in to manage player on object interactions
function Player:init(world)
	Player.super.init(self, gfx.imagetable.new("images/player/player-table-80-80"))

	self.world = world -- Save the World Class as an Attribute

	-- Player states, sprites, and animation speeds
	self:addState("idle", 1, 16, {ts = 2})
	self:addState("walk", 17, 28, {ts = 1.3})
	self:addState("duckDown", 29, 29, {ts = 1, l = 1, na = "duck"})
	self:addState("duck", 30, 30)
	self:addState("duckUp", 31, 31, {ts = 1, l = 1, na = "idle"})
	self:addState("jump", 32, 32)
	self:addState("jump1", 33, 33)
	self:addState("jump2", 34, 34)
	self:addState("jump3", 35, 35)
	self:addState("midJump", 36, 36)
	self:addState("dash", 36, 36)
	self:addState("fall", 37, 37)
	self:addState("fall1", 38, 38)
	self:addState("fall2", 39, 39)
	self:addState("fall3", 40, 40)
	self:addState("contact", 41, 42, {ts = 2, l = 1, na = "idle"})
	self:addState("roll", 43, 58, {ts = 1, l = 1})
	self:addState("dbJump", 59, 74, {ts = 1, l = 1})
	self:addState("hurt", 75, 76, {ts = 1, l = 12, na = "fall"})

	-- The following are temporary sprites that will be animated later
	self:addState("run", 17, 28, {ts = 1})
	self:addState("dive", 40, 40, {ts = 1})
	self:addState("die", 29, 29, {ts = 2, l = 1, na = "dead"})
	self:addState("dead", 30, 30)
	self:addState("spawn", 30, 31, {ts = 3, l = 1, na = "idle"})
	self:addState("punch", 74, 77, {ts = 1})
	self:addState("duckPunch", 78, 81, {ts = 1})
	self:playAnimation()

	-- On Frame Change Events for State Changes
	self.states["idle"].onFrameChangedEvent = function(self) if self.yVelocity < 0 then self:changeState("jump") end end
	self.states["walk"].onFrameChangedEvent = function(self) if self.yVelocity < 0 then self:changeState("jump") end end
	self.states["run"].onFrameChangedEvent = function(self) if self.yVelocity < 0 then self:changeState("jump") end end

	-- On Frame Change Events for Managing Jumping and Jump Velocity States
	self.states["jump"].onFrameChangedEvent = function(self) if self.yVelocity > -240 then self:changeState("jump1") end end
	self.states["jump1"].onFrameChangedEvent = function(self) if self.yVelocity > -150 then self:changeState("jump2") elseif self.yVelocity < -240 then self:changeState("jump") end end
	self.states["jump2"].onFrameChangedEvent = function(self) if self.yVelocity > -90 then self:changeState("jump3") elseif self.yVelocity < -150 then self:changeState("jump1") end end
	self.states["jump3"].onFrameChangedEvent = function(self) if self.yVelocity > -60 then self:changeState("midJump") elseif self.yVelocity < -90 then self:changeState("jump2") end end
	self.states["midJump"].onFrameChangedEvent = function(self) if self.yVelocity > -30 then self:changeState("fall") elseif self.yVelocity < -60 then self:changeState("jump3") end end
	self.states["fall"].onFrameChangedEvent = function(self) if self.yVelocity > 0 then self:changeState("fall1") elseif self.yVelocity < -30 then self:changeState("midJump") end end
	self.states["fall1"].onFrameChangedEvent = function(self) if self.yVelocity > 60 then self:changeState("fall2") elseif self.yVelocity < 0 then self:changeState("fall") end end
	self.states["fall2"].onFrameChangedEvent = function(self) if self.yVelocity > 150 then self:changeState("fall3") elseif self.yVelocity < 60 then self:changeState("fall1") end end
	self.states["fall3"].onFrameChangedEvent = function(self) if self.yVelocity < 150 then self:changeState("fall2") end end

	-- Roll state finish process
	self.states["roll"].onAnimationEndEvent = function(self) self:changeToMidJumpState() end
	self.states["dbJump"].onAnimationEndEvent = function(self) self:changeState("midJump") end
	self.states["hurt"].onAnimationEndEvent = function(self) 
		self.hurt = false
		self.doubleJumpAvailable = false
	end

	-- Sprite properties
	self:moveTo(g.player_x, g.player_y)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setCollideRect(38, 44, 4, 36)

	-- Attributes
	self.hurt = false
	self.globalFlip = g.player_facing
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.weight = 72
	self.dead = false
	self.win = false

	-- Physics properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 900
	self.jumpVelocity = -220
	self.minimumAirSpeed = 15
	self.maxSpeed = 150
	self.walkSpeed = 90
	self.jumpSpeed = 112
	self.drag = 120
	
	-- Collision attributes
	self.overlapTags = {
		[TAGS.Hazard] = true,
		[TAGS.Pickup] = true,
		[TAGS.Flag] = true,
		[TAGS.Prop] = true,
		[TAGS.Door] = true,
		[TAGS.Animal] = true,
		[TAGS.Hitbox] = true,
		[TAGS.Crown] = true,
		[TAGS.GUI] = true,
		[TAGS.Bubble] = true,
		[TAGS.Fragile] = true,
		[TAGS.Wind] = true,
		[TAGS.Spike] = true,
		[TAGS.Halftile] = true
	}

	-- Buffer
	self.bufferAmount = 2

	-- Roll
	self.rollAvailable = true
	self.rollSpeed = 120
	self.rollBuffer = 0
	self.rollRecharge = 600

	-- Dive
	self.diveSpeed = 750
	self.diveHorizontal = 160

	-- Jump attributes
	self.jumping = false
	self.jumpCounter = 0
	self.jumpCounterMax = 0.1
	self.jumpBufferAmount = 3
	self.jumpBuffer = 0
	self.jumpStates = {
		["jump"] = true,
		["jump1"] = true,
		["jump2"] = true,
		["jump3"] = true,
		["midJump"] = true,
		["fall"] = true,
		["fall1"] = true,
		["fall2"] = true,
		["fall3"] = true,
		["dive"] = true
	}

	-- Double Jump
	self.doubleJumpAvailable = true
	self.doubleJumpVelocity = -240

	-- Dash
	self.dashAvailable = true
	self.dashSpeed = 360
	self.dashMinimumSpeed = 105
	self.dashDrag = 1134

	-- Punch
	self.punchAvailable = false
	self.punchBufferAmount = 3
	self.punchBuffer = 0

	-- Left & Right buffers
	self.leftBuffer = 0
	self.rightBuffer = 0
	self.upBuffer = 0
end


--- This function is used to handle the collisions the player has with the world
--- @param  e   table   This variable contains what the player has collided with
--- @return unknown unknown The function returns the collision response to use
function Player:collisionResponse(e)
	local tag <const> = e:getTag()

	if self.overlapTags[tag] then
		if tag == TAGS.Fragile then
			return e:collision()
		elseif tag == TAGS.Halftile then
			if self.y + 48 > e.y or pd.buttonIsPressed(pd.kButtonDown) then
				return gfx.sprite.kCollisionTypeOverlap
			end
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The player update function runs every game tick and manages all input/responses
function Player:update()
	self:updateAnimation()

	g.player_x = self.x
	g.player_y = self.y

	if self.dead then return end
	self:updateBuffers()
	self:handleState()
	self:handleMovementAndCollisions()
end


--- Update all game buffers
function Player:updateBuffers()
	-- Update each game buffer, math.max ensures it never goes below zero
	self.jumpBuffer = math.max(self.jumpBuffer - (30 * dt), 0)
	self.rollBuffer = math.max(self.rollBuffer - (30 * dt), 0)
	self.punchBuffer = math.max(self.punchBuffer - (30 * dt), 0)
	self.leftBuffer = math.max(self.leftBuffer - (30 * dt), 0)
	self.rightBuffer = math.max(self.rightBuffer - (30 * dt), 0)

	-- Set the game buffers if each button is pressed
	if pd.buttonJustPressed(pd.kButtonA) then
		self.jumpBuffer = self.jumpBufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		self.rollBuffer = self.bufferAmount
		self.punchBuffer = self.punchBufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonLeft) then
		self.leftBuffer = self.bufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonRight) then
		self.rightBuffer = self.bufferAmount
	end
end


--- These methods return true if the buffer is greater than zero
function Player:playerPunched() return self.punchBuffer > 0 end
function Player:playerPressedRight() return self.rightBuffer > 0 end
function Player:playerPressedLeft() return self.leftBuffer > 0 end
function Player:playerJumped() return self.jumpBuffer > 0 end
function Player:playerRolled() return self.rollBuffer > 0 end


--- The state handler changes the functions running on the player based on state
function Player:handleState()
	-- If the player is in the air we use this statement to handle that
	if self.jumpStates[self.currentState] then
		if self.touchingGround then
			if self.yVelocity > 420 then
				if pd.buttonIsPressed(pd.kButtonDown) then
					self:changeToDuckState()
				else
					self:changeToContactState()
				end
			else
				self:changeToIdleState()
			end
		end

		self:variableJump()
		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == "hurt" then
		self:applyGravity()
		self:applyDrag(self.drag)
	elseif self.currentState == "dash" then
		self:applyDrag(self.dashDrag)
		if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
			self:changeState("midJump")
		end
	elseif self.currentState == "duck" then
		self.xVelocity = 0
		self:applyGravity()
		self:handleDuckInput()
		if self.yVelocity > 90 then
			self:changeState("fall")
		end
	elseif self.currentState == "dbJump" then
		if self.touchingGround then
			self:setCollideRect(38, 44, 4, 36)
			self:changeToIdleState()
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == "contact" or self.currentState == "spawn" or self.currentState == "punch" or self.currentState == "dead" or self.currentState == "die" or self.currentState == "duckPunch" or self.currentState == "duckUp" or self.currentState == "duckDown" then
	else
		self:applyGravity()
		if self.currentState ~= 'roll' then self:handleGroundInput() end

		if self.yVelocity > 90 then
			self:changeState("fall")
		end
	end
end


--- This function handles all player movement input and any collisions that might occur
function Player:handleMovementAndCollisions()
	local _, _, collisions, length = self:moveWithCollisions(self.x + (self.xVelocity * dt), self.y + (self.yVelocity * dt))

	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	local died = false

	for i = 1, length do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		local collisionObject <const> = collision.other
		local collisionTag <const> = collisionObject:getTag()

		if collisionType == gfx.sprite.kCollisionTypeSlide then
			if collision.normal.y == -1 then
				self.doubleJumpAvailable = true
				self.touchingGround = true
				self.dashAvailable = true
			elseif collision.normal.y == 1 then
				self.touchingCeiling = true
			end

			if collision.normal.x ~= 0 then
				self.touchingWall = true
			end
		end

		if collisionTag == TAGS.Hazard and not self.hurt then
			self:handleDamageCollision(collisionObject)
		elseif collisionTag == TAGS.Spike then
			if self.yVelocity > 120 then
				self:handleDamageCollision(collisionObject)
			end
		elseif collisionTag == TAGS.Bubble then
			self:handleBubbleCollision(collisionObject)
		elseif collisionTag == TAGS.Flag then
			self:handleFlagCollision(collisionObject)
		elseif collisionTag == TAGS.Door and pd.buttonJustPressed(pd.kButtonUp) then
			self.world:enterDoor(collisionObject.level, collisionObject.exitX, collisionObject.exitY)
		elseif collisionTag == TAGS.Crown then
			self:handleCrownCollision(collisionObject)
		elseif collisionTag == TAGS.Fragile then
			collisionObject:handleCollision(self, collision)
		elseif collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Roaster then
			if self.touchingGround then
				collisionObject:handleCollision()
			end
		end

		-- Check if we are colliding with the health bar
		if collisionTag == TAGS.GUI and self.world.bar:isVisible() then
			self.world.bar:setVisible(false)
			pd.timer.performAfterDelay(2000, function()
				self.world.bar:setVisible(true)
			end)
		end
	end

	-- If the world is wider than 400 pixels and the player is 250 or more pixels across the screen update the world
	if self.x + self.xVelocity > self.x and self.x >= 250 and g.world_x + 400 < self.world.width - 1 then
		self.world:update()
	end

	-- If the world X value is greater than 0 and the player is 150 or less pixels across the screen update the world
	if self.x + self.xVelocity < self.x and self.x <= 150 and g.world_x > 1 then
		self.world:update()
	end

	-- Change to face the direction we are moving in
	if self.xVelocity < 0 then
		self.globalFlip = 1
		g.player_facing = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
		g.player_facing = 0
	end

	-- If touching the edge of the level, lets move into the next room
	if self.x < -2 then
		self.world:enterRoom("west")
	elseif self.x > 402 then
		self.world:enterRoom("east")
	elseif self.y < -32 then
		self.world:enterRoom("north")
	elseif self.y > 264 then
		self.world:enterRoom("south")
	end

	-- Check if we die from fall damage
	if self.touchingGround then
		if self.yVelocity > 1350 then
			died = true
		end
	end

	if g.player_hp <= 0 then died = true end -- Check if we are dead from no hit points
	if died then self:die() end -- If the player is dead then run the die method
end


function Player:handleDamageCollision(obj)
	g.player_hp = g.player_hp - obj.damage
	if g.player_hp < 0 then
		g.player_hp = 0
	else
		self:changeToHurtState()
	end
end


--- Handle Colliding with the Bubble Object
--- param  obj  object  The Bubble Object we'll be interacting with
function Player:handleBubbleCollision(obj)
	self.touchingGround = false
	obj:pop(self)
end


--- Trigger checkpoint
--- param flag table The checkpoint triggered
function Player:handleFlagCollision(flag)
	if flag.currentState == "up" then return end -- If the Flag is Hoisted Do Nothing

	-- Lower any other flag on screen
	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Flag) then
			sprite:lower()
		end
	end

	flag:hoist(self.world, self.globalFlip) -- Raise the touched flag

	g.player_hp = 100 -- Top up the player health
	self.world:updateHealthBar()
end


--- If the player collides with a crown, run this function
function Player:handleCrownCollision(obj)
	if not self.win then
		self.win = true
		g:switchScene(Screen, "wipe", "win")
		obj:setVisible(false)
	end
end


--- Variable jump height handler
function Player:variableJump()
	if self.jumpCounter >= (self.jumpCounterMax * g.fps) then
		self.jumpCounter = 0
		self.jumping = false
	end

	if self.jumping then
		self.jumpCounter = self.jumpCounter + 1
	end
end


function Player:handleVariableJump()
	if pd.buttonJustReleased(pd.kButtonA) then
		self.jumpCounter = 0
		self.jumping = false
	end

	if self.jumping then
		self.yVelocity = self.jumpVelocity
	end
end


--- This function handles when the player dies, what to do and when to respawn
function Player:die()
	self.xVelocity = 0
	self.yVelocity = 0
	self.dead = true
	g.player_hp = 0

	self:changeState("die")
	self.world:updateHealthBar() 

	self:setCollisionsEnabled(false)
	pd.timer.performAfterDelay(1000, function()
		g.player_hp = 100
		self:setCollisionsEnabled(true)
		self.dead = false
		self.hurt = false
		self.world:resetPlayer()
	end)
end


--- Handle input while the player is on the ground. Like going left, right, dashing, and jumping
function Player:handleGroundInput()
	if self:playerJumped() then
		self:changeToJumpState()
	elseif pd.buttonIsPressed(pd.kButtonB) then
		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:changeToRunState("left")
		elseif pd.buttonIsPressed(pd.kButtonRight) then
			self:changeToRunState("right")
		end
	else
		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:changeToWalkState("left")
		elseif pd.buttonIsPressed(pd.kButtonRight) then
			self:changeToWalkState("right")
		elseif pd.buttonIsPressed(pd.kButtonDown) then
			self:changeToDuckingState()
		end
	end

	if pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
		self:changeToIdleState()
	end

	if self.rollAvailable and self:playerRolled() then
		if self:playerPressedLeft() then
			self:changeToRollState("left")
		elseif self:playerPressedRight() then
			self:changeToRollState("right")
		end
	end

	-- if self:playerPunched() then
	-- 	if pd.buttonJustReleased(pd.kButtonB) and not self.punchAvailable then
	-- 		self:changeToPunchState("punch")
	-- 	end
	-- end
end


--- Handle input while the player is crouched
function Player:handleDuckInput()
	if pd.buttonJustReleased(pd.kButtonDown) then
		self:setCollideRect(38, 44, 4, 36)
		self:changeState("duckUp")
	end

	-- if self:playerPunched() then
	-- 	if pd.buttonJustReleased(pd.kButtonB) and not self.punchAvailable then
	-- 		self:changeToPunchState("duckPunch")
	-- 	end
	-- end
end


--- Handle input while the player is in the air. Like going left, right, double jumping, and dashing
function Player:handleAirInput()
	if self:playerJumped() and self.doubleJumpAvailable then
		self:changeToDoubleJumpState()
	elseif pd.buttonJustPressed(pd.kButtonB) and self.dashAvailable then
		self:changeToDashState()
	elseif pd.buttonIsPressed(pd.kButtonLeft) then
		self.xVelocity = -self.jumpSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self.xVelocity = self.jumpSpeed
	end

	if pd.buttonJustPressed(pd.kButtonDown) then
		self:changeToDiveState()
	end

	self:handleVariableJump()
end


--- If the player is not moving on the X axis change to an idle state
function Player:changeToIdleState()
	self.xVelocity = 0
	self:setCollideRect(38, 44, 4, 36)
	self:changeState("idle")
end


--- If the player is moving in any direction set their X movement velocity to their max speed and change sprite
--- @param direction string Contains the direction the player is moving in as a string
function Player:changeToWalkState(direction)
	self.xVelocity = 0
	if direction == "left" then
		self.xVelocity = self.xVelocity - self.walkSpeed
	elseif direction == "right" then
		self.xVelocity = self.xVelocity + self.walkSpeed
	end

	self:changeState("walk")
end


function Player:changeToFallState()
	self:setCollideRect(38, 44, 4, 36)
	self:changeState("fall")
end


--- Change the player into the hurt state
function Player:changeToHurtState()
	if self.globalFlip == 1 then
		self.xVelocity = self.walkSpeed
	else
		self.xVelocity = -self.walkSpeed
	end

	self.yVelocity = -self.maxSpeed

	self.hurt = true
	self.world:updateHealthBar()
	self:changeState("hurt")
end


--- Change the player into a running state
function Player:changeToRunState(direction)
	if direction == "left" then
		self.xVelocity = -self.maxSpeed
	elseif direction == "right" then
		self.xVelocity = self.maxSpeed
	end

	self:changeState("run")
end


--- Changes the player sprite & Y velocity to the jump velocity
function Player:changeToJumpState()
	self.jumping = true
	self.jumpBuffer = 0
	self.yVelocity = self.jumpVelocity
	--self:changeState("jump")
end


--- Changes the player sprite to the mid jump sprite
function Player:changeToMidJumpState()
	self:setCollideRect(38, 44, 4, 36)
	self:changeState("midJump")
end


--- Allow the player to double jump
function Player:changeToDoubleJumpState()
	self.jumpBuffer = 0
	self.doubleJumpAvailable = false
	self.yVelocity = self.doubleJumpVelocity
	self:changeState("dbJump")
end


--- Changes the player to the duck state
function Player:changeToDuckState()
	self.xVelocity = 0
	self:setCollideRect(38, 61, 4, 19)
	self:changeState("duck")
end


--- Changes the player sprite to the crouch state when down is pressed
function Player:changeToDuckingState()
	self.xVelocity = 0
	self:setCollideRect(38, 61, 4, 19)
	self:changeState("duckDown")
end


--- Change the player into a roll state
--- @param  direction  string  The direction to roll in
function Player:changeToRollState(direction)
	self.rollAvailable = false
	self:setCollideRect(38, 61, 4, 19)

	if direction == "left" then
		self.xVelocity = -self.rollSpeed
	elseif direction == "right" then
		self.xVelocity = self.rollSpeed
	end

	pd.timer.performAfterDelay(490, function()
		pd.timer.performAfterDelay(self.rollRecharge, function()
			self.rollAvailable = true
		end)
	end)

	self:changeState("roll")
end


--- Changes the player to the contact state
function Player:changeToContactState()
	self.xVelocity = 0
	self:changeState("contact")
end


--- Changes the player to a punch state
function Player:changeToPunchState(state)
	self.punchAvailable = true
	self.xVelocity = 0

	pd.timer.performAfterDelay(75, function()
		if pd.buttonIsPressed(pd.kButtonDown) then
			self:changeToDuckingState()
		else
			self:setCollideRect(38, 44, 4, 36)
			self:changeToIdleState()
		end
	end)

	pd.timer.performAfterDelay(60, function()
		self.punchAvailable = false
	end)

	local hitboxX = self.globalFlip == 0 and self.x + 9 or self.x - 17
	local hitboxY = self.y + 7
	if state == "punch" then
		hitboxX = self.globalFlip == 0 and self.x + 12 or self.x - 20
		hitboxY = self.y + 5
	end

	Hitbox(hitboxX, hitboxY, 8, 8, 50)

	self:changeState(state)
end


--- Change the player into the spawn state
function Player:changeToSpawnState()
	self:changeState("spawn")
end


--- Changes the player to the dive state
function Player:changeToDiveState()
	self.yVelocity = self.diveSpeed
	if self.globalFlip == 0 then
		self.xVelocity = self.diveHorizontal
	else
		self.xVelocity = -self.diveHorizontal
	end

	self:changeState("dive")
end


--- Makes the player dash in the direction they face
function Player:changeToDashState()
	self.dashAvailable = false
	self.yVelocity = 0
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self.xVelocity = -self.dashSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self.xVelocity = self.dashSpeed
	else
		if self.globalFlip == 1 then
			self.xVelocity = -self.dashSpeed
		else
			self.xVelocity = self.dashSpeed
		end
	end

	self:changeState("dash")
end


--- Applies gravity to the player, used if the player is not touching a surface
--- Resets Y velocity when colliding with a ceiling or the ground
function Player:applyGravity()
	self.yVelocity = self.yVelocity + (self.gravity * dt)
	if self.touchingGround or self.touchingCeiling then
		self.jumping = false
		self.jumpCounter = 0
		self.yVelocity = 0
	end
end


--- Applies air drag to the player if they're not holding the direction they are moving in while airborne
--- @param  amount  integer  The amount to decrease movement by while in the air if receiving no directional input
function Player:applyDrag(amount)
	if self.xVelocity > 0 then
		self.xVelocity = self.xVelocity - (amount * dt)
	elseif self.xVelocity < 0 then
		self.xVelocity = self.xVelocity + (amount * dt)
	end

	if math.abs(self.xVelocity) < self.minimumAirSpeed or self.touchingWall then
		self.xVelocity = 0
	end
end