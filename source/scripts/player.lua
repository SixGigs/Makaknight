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
	local playerImageTable <const> = gfx.imagetable.new("images/seraphina-table-48-48")
	Player.super.init(self, playerImageTable)

	-- Player states, sprites, and animation speeds
	self:addState("idle", 1, 8, {tickStep = 3})
	self:addState("walk", 9, 14, {tickStep = 3})
	self:addState("duck", 15, 15)
	self:addState("jump", 16, 16)
	self:addState("midJump", 17, 17)
	self:addState("fall", 18, 18)
	self:addState("run", 19, 30, {tickStep = 1.5})
	self:addState("ready", 31, 40, {tickStep = 3})
	self:addState("dash", 41, 43, {tickStep = 1})
	self:addState("dive", 44, 45, {tickStep = 1})
	self:addState("die", 46, 49, {tickStep = 2})
	self:addState("dead", 49, 49)
	self:addState("roll", 50, 57, {tickStep = 2})
	self:addState("spawn", 58, 63, {tickStep = 3})
	self:playAnimation()

	-- Sprite properties
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setCollideRect(19, 19, 10, 29)

	-- Physics properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 1.0
	self.maxSpeed = 3.4
	self.walkSpeed = 2
	self.jumpSpeed = 2.6
	self.jumpVelocity = -9.5
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	-- Roll
	self.rollAvailable = true
	self.rollFallSpeed = 2.6
	self.rollSpeed = 3
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
	self.doubleJumpVelocity = -6.5

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

	-- Player Attributes
	self.globalFlip = face
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.touchingDoor = false
	self.dead = false
end


--- This function is used to handle the collisions the player has with the world
--- @param  other   table   This variable contains what the player has collided with
--- @return unknown unknown The function returns the collision response to use
function Player:collisionResponse(other)
	local tag <const> = other:getTag()
	if tag == TAGS.Hazard or tag == TAGS.Pickup or tag == TAGS.Flag or tag == TAGS.Prop or tag == TAGS.Door or tag == TAGS.Animal then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end


--- The player update function runs every game tick and manages all input/responses
function Player:update()
	self:updateAnimation()

	if self.dead then
		return
	end

	self:updateJumpBuffer()
	self:updateRollBuffer()
	self:handleState()
	self:handleMovementAndCollisions()
end


--- The jump buffer helps jumping appear more natural in the game
function Player:updateJumpBuffer()
	self.jumpBuffer = self.jumpBuffer - 1

	if self.jumpBuffer <= 0 then
		self.jumpBuffer = 0
	end

	if pd.buttonJustPressed(pd.kButtonA) then
		self.jumpBuffer = self.jumpBufferAmount
	end
end


--- The roll buffer helps the player input the button combination for a roll
function Player:updateRollBuffer()
	self.rollBuffer = self.rollBuffer - 1

	if self.rollBuffer <= 0 then
		self.rollBuffer = 0
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		self.rollBuffer = self.rollBufferAmount
	end
end


--- A function to detect whether the player has jumped based on jump buffer
function Player:playerJumped()
	return self.jumpBuffer > 0
end


--- A function to detect if the player has input to roll based on roll buffer
function Player:playerRolled()
	return self.rollBuffer > 0
end


--- The state handler changes the functions running on the player based on state
function Player:handleState()
	if self.currentState == "roll" then
		self:applyGravity()
	elseif self.currentState == "jump" or self.currentState == "midJump" then
		if self.yVelocity > 1 then
			self:changeToFallState()
		elseif self.yVelocity > -2 then
			self:changeToMidJumpState()
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == "dash" then
		self:applyDrag(self.dashDrag)
		if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
			self:changeToFallState()
		end
	elseif self.currentState == "fall" or self.currentState == "dive" then
		if self.touchingGround then
			if pd.buttonIsPressed(pd.kButtonB) then
				self:changeToReadyState()
			else
				self:changeToIdleState()
			end
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	else
		self:applyGravity()
		self:handleGroundInput()

		if self.yVelocity > 1 then
			self:changeToFallState()
		end
	end
end


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
			self:changeToDieState()
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
	if self.x < -6 then
		self.gm:enterRoom("west")
	elseif self.x > 406 then
		self.gm:enterRoom("east")
	elseif self.y < -12 then -- Decreased from 0 to -8 to prevent glitches when jumping up a level
		self.gm:enterRoom("north")
	elseif self.y > 252 then
		self.gm:enterRoom("south")
	end

	-- If the player touched a hazard, die
	if died then
		self:die()
	end
end


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
	if flag.active == false then
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
end


--- This function handles when the player dies, what to do and when to respawn
function Player:die()
	self.xVelocity = 0
	self.yVelocity = 0
	self.dead = true

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
		else
			self:changeToReadyState()
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

	if pd.buttonJustPressed(pd.kButtonUp) then
		if self.nextLevelID ~= nil then
			self.gm:enterDoor(self.nextLevelID, self.exitX, self.exitY)
		end
	end
end


--- Handle input while the player is crouched
function Player:handleDuckInput()
	if pd.buttonJustReleased(pd.kButtonDown) then
		self:changeToIdleState()
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


--- If the player is not moving on the X axis change to an idle state
function Player:changeToIdleState()
	self.xVelocity = 0

	self:setCollideRect(19, 19, 10, 29)
	self:changeState("idle")
end


--- Move the player into the ready state
function Player:changeToReadyState()
	self.xVelocity = 0

	self:changeState("ready")
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

		if self.touchingGround then
			self:changeState("idle")
		elseif self.dead then
			self:changeState("dead")
		else
			if self.globalFlip == 0 then
				self.xVelocity = self.rollFallSpeed
			else
				self.xVelocity = -self.rollFallSpeed
			end

			self:changeState("fall")
		end
	end)

	self:changeState("roll")
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

	self:changeState("jump")
end


--- Changes the player sprite to the jump state when falling
function Player:changeToFallState()
	self:changeState("fall")
end


--- Changes the player sprite to the jump state when falling
function Player:changeToMidJumpState()
	self:changeState("midJump")
end


function Player:changeToDieState()
	self:changeState("die")
	pd.timer.performAfterDelay(150, function()
		self:changeState("dead")
	end)
end

function Player:changeToSpawnState()
	self:changeState("spawn")
	pd.timer.performAfterDelay(510, function()
		self:changeState("idle")
	end)
end


function Player:changeToDiveState()
	self.yVelocity = self.diveSpeed
	if self.globalFlip == 0 then
		self.xVelocity = self.diveHorizontal
	else
		self.xVelocity = -self.diveHorizontal
	end

	self:changeState("dive")
end


--- Changes the player sprite to the crouch state when down is pressed
function Player:changeToDuckState()
	self.xVelocity = 0

	self:setCollideRect(17, 32, 12, 16)
	self:changeState("duck")
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