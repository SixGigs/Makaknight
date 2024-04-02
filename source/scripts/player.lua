-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the player class
class('Player').extends(AnimatedSprite)


--- The player is initialised with this method
--- @param x    integer The X coordinate to spawn the player
--- @param y    integer The Y coordinate to spawn the player
--- @param gm   table   The game manager is passed in to manage player on object interactions
--- @param face integer The direction the player is facing as a 1 or 0
function Player:init(x, y, gm, face)
	-- Game Manager
	self.gm = gm

	-- Create the player state machine with the tile set
	local playerImageTable <const> = gfx.imagetable.new("images/player-table-80-80")
	Player.super.init(self, playerImageTable)

	-- Player states, sprites, and animation speeds
	self:addState("idle", 1, 16, {tickStep = 2})
	self:addState("walk", 17, 28, {tickStep = 1.5})
	self:addState("duckDown", 29, 29, {tickStep = 1, loop = 1, nextAnimation = "duck"})
	self:addState("duck", 30, 30)
	self:addState("duckUp", 31, 31, {tickStep = 1, loop = 1, nextAnimation = "idle"})
	self:addState("jump", 32, 32)
	self:addState("jump1", 33, 33)
	self:addState("jump2", 34, 34)
	self:addState("jump3", 35, 35)
	self:addState("midJump", 36, 36)
	self:addState("dash", 36, 36, {tickStep = 1})
	self:addState("fall", 37, 37)
	self:addState("fall1", 38, 38)
	self:addState("fall2", 39, 39)
	self:addState("fall3", 40, 40)
	self:addState("contact", 41, 42, {tickStep = 2, loop = 1, nextAnimation = "idle"})
	self:addState("roll", 43, 58, {tickStep = 1, loop = 1, nextAnimation = "idle"})

	self:addState("doubleJump", 17, 28, {tickStep = 1.5})
	self:addState("run", 17, 28, {tickStep = 1})
	self:addState("ready", 1, 16, {tickStep = 1})
	self:addState("dive", 54, 55, {tickStep = 1})
	self:addState("die", 56, 59, {tickStep = 2})
	self:addState("dead", 59, 59)
	self:addState("spawn", 68, 73, {tickStep = 3})
	self:addState("punch", 74, 77, {tickStep = 1})
	self:addState("duckPunch", 78, 81, {tickStep = 1})
	self:playAnimation()

	-- Sprite properties
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setCollideRect(35, 44, 10, 36)

	-- Physics properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 1.0
	self.maxSpeed = 3.4
	self.walkSpeed = 2
	self.jumpSpeed = 2.6
	self.jumpVelocity = -10
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	-- Roll
	self.rollAvailable = true
	self.rollFallSpeed = 2.6
	self.rollSpeed = 4
	self.rollBufferAmount = 2
	self.rollBuffer = 0
	self.rollRecharge = 300

	-- Dive
	self.diveSpeed = 12
	self.diveHorizontal = 4

	-- Jump Buffer
	self.jumpBufferAmount = 5
	self.jumpBuffer = 0

	-- Double Jump
	self.doubleJumpAvailable = true
	self.doubleJumpVelocity = -7.5

	-- Dash
	self.dashAvailable = true
	self.dashSpeed = 9
	self.dashMinimumSpeed = 3
	self.dashDrag = 1.4

	-- Door Management
	self.doorTimer = 2
	self.nextLevelID = nil
	self.exitX = 0
	self.exitY = 0

	-- Punch
	self.punchAvailable = false
	self.punchBufferAmount = 5
	self.punchBuffer = 0

	-- Player Attributes
	self.globalFlip = face
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.touchingDoor = false
	self.dead = false
end


----------------------------------------------------------------------------------------------------------
--- This function is used to handle the collisions the player has with the world
--- @param  other   table   This variable contains what the player has collided with
--- @return unknown unknown The function returns the collision response to use
function Player:collisionResponse(other)
	local tag <const> = other:getTag()
	local overlapTags <const> = {
		[TAGS.Hazard] = true,
		[TAGS.Pickup] = true,
		[TAGS.Flag] = true,
		[TAGS.Prop] = true,
		[TAGS.Door] = true,
		[TAGS.Animal] = true,
		[TAGS.Hitbox] = true
	}

	if overlapTags[tag] then
		return gfx.sprite.kCollisionTypeOverlap
	else
		return gfx.sprite.kCollisionTypeSlide
	end
end


----------------------------------------------------------------------------------------------------------
--- The player update function runs every game tick and manages all input/responses
function Player:update()
	self:updateAnimation()

	if self.dead then
		return
	end

	self:updateBuffers()
	self:handleState()
	self:handleMovementAndCollisions()
end


----------------------------------------------------------------------------------------------------------
--- Update all game buffers
function Player:updateBuffers()
	-- Update each game buffer, math.max ensures it never goes below zero
	self.jumpBuffer = math.max(self.jumpBuffer - 1, 0)
	self.rollBuffer = math.max(self.rollBuffer - 1, 0)
	self.punchBuffer = math.max(self.punchBuffer - 1, 0)

	-- Set the game buffers if each button is pressed
	if pd.buttonJustPressed(pd.kButtonA) then
		self.jumpBuffer = self.jumpBufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		self.rollBuffer = self.rollBufferAmount
		self.punchBuffer = self.punchBufferAmount
	end
end


----------------------------------------------------------------------------------------------------------
function Player:playerJumped() return self.jumpBuffer > 0 end --- This method is used to make jumping easier
function Player:playerRolled() return self.rollBuffer > 0 end --- This method is used to make rolling easier
function Player:playerPunched() return self.punchBuffer > 0 end --- This method used to calculate if the player can


----------------------------------------------------------------------------------------------------------
--- The state handler changes the functions running on the player based on state
function Player:handleState()
	if self.currentState == "jump" or self.currentState == "jump1" or self.currentState == "jump2" or self.currentState == "jump3" or self.currentState == "midJump" or self.currentState == "fall" or self.currentState == "fall1" or self.currentState == "fall2" or self.currentState == "fall3" or self.currentState == "dive" then
		if self.touchingGround then
			if self.yVelocity > 15 then
				if pd.buttonIsPressed(pd.kButtonRight) then
					self:changeToRollState("right")
				elseif pd.buttonIsPressed(pd.kButtonLeft) then
					self:changeToRollState("left")
				else
					self:changeToContactState()
				end
			else
				self:changeToIdleState()
			end
		elseif self.yVelocity > 5 then
			self:changeState("fall3")
		elseif self.yVelocity > 2 then
			self:changeState("fall2")
		elseif self.yVelocity > 0 then
			self:changeState("fall1")
		elseif self.yVelocity > -1 then
			self:changeState("fall")
		elseif self.yVelocity > -2 then
			self:changeState("midJump")
		elseif self.yVelocity > -3 then
			self:changeState("jump3")
		elseif self.yVelocity > -5 then
			self:changeState("jump2")
		elseif self.yVelocity > -8 then
			self:changeState("jump1")
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == "roll" then
		if self.yVelocity > 1 then
			self:applyDrag(self.drag)
		end

		self:applyGravity()
	elseif self.currentState == "dash" then
		self:applyDrag(self.dashDrag)
		if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
			self:changeState("midJump")
		end
	elseif self.currentState == "duck" then
		self:applyGravity()
		self:handleDuckInput()

		if self.yVelocity > 1 then
			self:changeState("fall3")
		end
	elseif self.currentState == "doubleJump" then
		if self.touchingGround then
			self:changeToIdleState()
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == "contact" or self.currentState == "spawn" or self.currentState == "punch" or self.currentState == "dead" or self.currentState == "die" or self.currentState == "duckPunch" or self.currentState == "duckUp" or self.currentState == "duckDown" then
	else
		self:applyGravity()
		self:handleGroundInput()

		if self.yVelocity > 1 then
			self:changeState("fall1")
		end
	end
end


----------------------------------------------------------------------------------------------------------
--- This function handles all player movement input and any collisions that might occur
function Player:handleMovementAndCollisions()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

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
				self.touchingGround = true
				self.dashAvailable = true
				self.doubleJumpAvailable = true
			elseif collision.normal.y == 1 then
				self.touchingCeiling = true
			end

			if collision.normal.x ~= 0 then
				self.touchingWall = true
			end
		end

		if collisionTag == TAGS.Hazard then
			died = true
		elseif collisionTag == TAGS.Pickup then
			collisionObject:pickUp(self)
		elseif collisionTag == TAGS.Flag then
			self:handleFlagCollision(collisionObject)
		elseif collisionTag == TAGS.Door then
			self:handleDoorCollision(collisionObject)
		end

		-- Check if we are still touching the door
		if self.touchingDoor == true and collisionTag ~= TAGS.Door then
			self.doorTimer = self.doorTimer - 1
			if self.doorTimer <= 0 then
				self.touchingDoor = false
				self.nextLevelID = nil
				self.exitX = 0
				self.exitY = 0
			end
		end
	end

	-- Change to face the direction we are moving in
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- If touching the edge of the level, lets move into the next room
	if self.x < -5 then
		self.gm:enterRoom("west")
	elseif self.x > 405 then
		self.gm:enterRoom("east")
	elseif self.y < -24 then
		self.gm:enterRoom("north")
	elseif self.y > 252 then
		self.gm:enterRoom("south")
	end
	
	-- Check if we die from fall damage
	if self.touchingGround then
		if self.yVelocity > 30 then
			died = true
		end
	end

	-- If the player touched a hazard, die
	if died then
		self:die()
	end
end


----------------------------------------------------------------------------------------------------------
--- This function gets details from the door the player has just collided with
--- @param door table The collisionObject in this function will be the door
function Player:handleDoorCollision(door)
	self.doorTimer = 2
	if self.touchingDoor == false then
		self.touchingDoor = true
		self.nextLevelID, self.exitX, self.exitY = door:getDetails()
	end
end

--- Trigger checkpoint
--- param flag table The checkpoint triggered
function Player:handleFlagCollision(flag)
	if flag.active then
		return
	end

	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Flag) then
			sprite:lower()
		end
	end

	flag:hoist()

	-- TODO: How can this be done better?
	self.gm.flag = flag.id
	self.gm.spawn = self.gm.level
	self.gm.spawnX = flag.x + 8
	self.gm.spawnY = flag.y + 24
end       


--- This function handles when the player dies, what to do and when to respawn
function Player:die()
	self.xVelocity = 0
	self.yVelocity = 0
	self.dead = true

	self:changeState("die")
	pd.timer.performAfterDelay(150, function()
		self:changeState("dead")
	end)

	self:setCollisionsEnabled(false)
	pd.timer.performAfterDelay(1000, function()
		self:setCollisionsEnabled(true)
		self.dead = false
		self.gm:resetPlayer()
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
		elseif pd.buttonJustPressed(pd.kButtonUp) then
			print("Pull out weapon")
		-- else
		-- 	self:changeToReadyState()
		end
	else
		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:changeToWalkState("left")
		elseif pd.buttonIsPressed(pd.kButtonRight) then
			self:changeToWalkState("right")
		elseif pd.buttonIsPressed(pd.kButtonDown) then
			self:changeToDuckState()
		else
			self:changeToIdleState()
		end
	end

	if self:playerRolled() then
		if pd.buttonJustPressed(pd.kButtonRight) and self.rollAvailable then
			self:changeToRollState("right")
		elseif pd.buttonJustPressed(pd.kButtonLeft) and self.rollAvailable then
			self:changeToRollState("left")
		end
	end

	if self:playerPunched() then
		if pd.buttonJustReleased(pd.kButtonB) and not self.punchAvailable then
			self:changeToPunchState("punch")
		end
	end

	if pd.buttonJustPressed(pd.kButtonUp) then
		if self.nextLevelID ~= nil then
			self.gm:enterDoor(self.nextLevelID, self.exitX, self.exitY)
		end
	end
end


--- Handle input while the player is crouched
function Player:handleDuckInput()
	if pd.buttonJustReleased(pd.kButtonDown) then
		self:setCollideRect(35, 44, 10, 36)
		self:changeState("duckUp")
	end
	
	if self:playerPunched() then
		if pd.buttonJustReleased(pd.kButtonB) and not self.punchAvailable then
			self:changeToPunchState("duckPunch")
		end
	end
end


--- Handle input while the player is in the air. Like going left, right, double jumping, and dashing
function Player:handleAirInput()
	if self:playerJumped() and self.doubleJumpAvailable then
		self.doubleJumpAvailable = false
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
end


----------------------------------------------------------------------------------------------------------
--- If the player is not moving on the X axis change to an idle state
function Player:changeToIdleState()
	self.xVelocity = 0
	self:changeState("idle")
end


--- If the player is moving in any direction set their X movement velocity to their max speed and change sprite
--- @param direction string Contains the direction the player is moving in as a string
function Player:changeToWalkState(direction)
	if direction == "left" then
		self.xVelocity = -self.walkSpeed
		self.globalFlip = 1
	elseif direction == "right" then
		self.xVelocity = self.walkSpeed
		self.globalFlip = 0
	end

	self:changeState("walk")
end


--- Change the player into a running state
function Player:changeToRunState(direction)
	if direction == "left" then
		self.xVelocity = -self.maxSpeed
		self.globalFlip = 1
	elseif direction == "right" then
		self.xVelocity = self.maxSpeed
		self.globalFlip = 0
	end

	self:changeState("run")
end


--- Changes the player sprite & Y velocity to the jump velocity
function Player:changeToJumpState()
	self.yVelocity = self.jumpVelocity
	self.jumpBuffer = 0

	self:changeState("jump")
end


--- Allow the player to double jump
function Player:changeToDoubleJumpState()
	self.yVelocity = self.doubleJumpVelocity
	self.jumpBuffer = 0

	pd.timer.performAfterDelay(400, function()
		if self.currentState == "dash" then
			return
		end

		self:changeState("midJump")
	end)

	self:changeState("doubleJump")
end


--- Changes the player sprite to the crouch state when down is pressed
function Player:changeToDuckState()
	self.xVelocity = 0

	self:setCollideRect(35, 61, 10, 19)
	self:changeState("duckDown")
end


--- Move the player into the ready state
function Player:changeToReadyState()
	self.xVelocity = 0
	self:changeState("ready")
end


--- Change the player into a roll state
function Player:changeToRollState(direction)
	self.rollAvailable = false

	if direction == "left" then
		self.xVelocity = -self.rollSpeed
		self.globalFlip = 1
	elseif direction == "right" then
		self.xVelocity = self.rollSpeed
		self.globalFlip = 0
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
			self:changeToDuckState()
		else
			self:setCollideRect(35, 44, 10, 36)
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


function Player:changeToSpawnState()
	self:changeState("spawn")
	pd.timer.performAfterDelay(510, function()
		self:changeState("idle")
	end)
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


----------------------------------------------------------------------------------------------------------
--- Applies gravity to the player, used if the player is not touching a surface
--- Resets Y velocity when colliding with a ceiling or the ground
function Player:applyGravity()
	self.yVelocity = self.yVelocity + self.gravity
	if self.touchingGround or self.touchingCeiling then
		self.yVelocity = 0
	end
end

--- Applies air drag to the player if they're not holding the direction they are moving in while airborne
--- @param amount integer The amount to decrease movement by while in the air if receiving no directional input
function Player:applyDrag(amount)
	if self.xVelocity > 0 then
		self.xVelocity = self.xVelocity - amount
	elseif self.xVelocity < 0 then
		self.xVelocity = self.xVelocity + amount
	end

	if math.abs(self.xVelocity) < self.minimumAirSpeed or self.touchingWall then
		self.xVelocity = 0
	end
end