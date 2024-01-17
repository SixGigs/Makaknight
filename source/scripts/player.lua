-- Constants used for the script
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the player class
class('Player').extends(AnimatedSprite)


--- The player is initialised with this method
--- @param x           integer The X coordinate to spawn the player
--- @param y           integer The Y coordinate to spawn the player
--- @param gameManager table   The game manager is passed in to manage player on object interactions
function Player:init(x, y, gameManager, facing)
	-- Game Manager
	self.gameManager = gameManager

	-- State Machine
	local playerImageTable = gfx.imagetable.new("images/seraphina-table-32-32")
	Player.super.init(self, playerImageTable)

	-- States
	self:addState("idle", 1, 1)
	self:addState("jump", 9, 9)
	self:addState("fall", 10, 10)
	self:addState("duck", 8, 8)
	self:addState("dead", 35, 35)
	self:addState("walk", 2, 7, {tickStep = 3})
	self:addState("run", 11, 16, {tickStep = 3})
	self:addState("dash", 27, 29, {tickStep = 1})
	self:addState("ready", 17, 26, {tickStep = 3})
	self:addState("dive", 30, 31, {tickStep = 1})
	self:addState("die", 32, 34, {tickStep = 2})
	self:playAnimation()

	-- Sprite Properties
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setCollideRect(9, 3, 14, 29)

	-- Physics Properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 1.0
	self.maxSpeed = 3.4
	self.walkSpeed = 2
	self.jumpSpeed = 2.6
	self.jumpVelocity = -9.5
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	-- Jump Buffer
	self.jumpBufferAmount = 5
	self.jumpBuffer = 0

	-- Abilities
	self.doubleJumpAbility = false
	self.dashAbility = true

	-- Double Jump
	self.doubleJumpAvailable = true

	-- Dash
	self.dashAvailable = true
	self.dashSpeed = 8
	self.dashMinimumSpeed = 3
	self.dashDrag = 1.4

	-- Player State
	self.globalFlip = facing
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.dead = false
end


--- This function is used to handle the collisions the player has with the world
--- @param  other   table   This variable contains what the player has collided with
--- @return unknown unknown The function returns the collision response to use
function Player:collisionResponse(other)
	local tag = other:getTag()
	if tag == TAGS.Hazard or tag == TAGS.Pickup or tag == TAGS.Checkpoint then
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


--- A function to detect whether the player has jumped based on jump buffer
function Player:playerJumped()
	return self.jumpBuffer > 0
end


--- The state handler changes the functions running on the player based on state
function Player:handleState()
	if self.currentState == "idle" then
		self:applyGravity()
		self:handleGroundInput()
	elseif self.currentState == "walk" then
		self:applyGravity()
		self:handleGroundInput()
	elseif self.currentState == "duck" then
		self:applyGravity()
		self:handleDuckInput()
	elseif self.currentState == "jump" then
		if self.touchingGround then
			self:changeToIdleState()
		end

		if self.yVelocity > 0 then
			self:changeToFallState()
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
	elseif self.currentState == "ready" then
		self:applyGravity()
		self:handleGroundInput()
	elseif self.currentState == "run" then
		self:applyGravity()
		self:handleGroundInput()
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
		local collision = collisions[i]
		local collisionType = collision.type
		local collisionObject = collision.other
		local collisionTag = collisionObject:getTag()

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
		elseif collisionTag == TAGS.Checkpoint then
			self:triggerCheckpoint(collisionObject)
		end
	end

	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	if self.x < 0 then
		self.gameManager:enterRoom("west")
	elseif self.x > 400 then
		self.gameManager:enterRoom("east")
	elseif self.y < -8 then -- Decreased from 0 to -8 to prevent glitches when jumping up a level
		self.gameManager:enterRoom("north")
	elseif self.y > 240 then
		self.gameManager:enterRoom("south")
	end

	if died then
		self:die()
	end
end


--- Trigger checkpoint
--- param collisionObject table The checkpoint triggered
function Player:triggerCheckpoint(collisionObject)
	if collisionObject.checked == false then
		local allSprites = gfx.sprite.getAllSprites()
		for _, sprite in ipairs(allSprites) do
			if sprite:isa(Checkpoint) then
				sprite:deactivate()
			end
		end

		collisionObject:hit()
		self.gameManager.checkpoint = collisionObject.id
		self.gameManager.spawnX = collisionObject.x + 36
		self.gameManager.spawnY = collisionObject.y + 16
		self.gameManager.spawnLevel = self.gameManager.currentLevel
		self.gameManager:saveGame()
	end
end


--- This function handles when the player dies, what to do and when to respawn
function Player:die()
	self.xVelocity = 0
	self.yVelocity = 0
	self.dead = true
	self:setCollisionsEnabled(false)
	pd.timer.performAfterDelay(750, function()
		self:setCollisionsEnabled(true)
		self.dead = false
		self.gameManager:resetPlayer()
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
end


--- Handle input while the player is crouched
function Player:handleDuckInput()
	if pd.buttonJustReleased(pd.kButtonDown) then
		self:changeToIdleState()
	end
end


--- Handle input while the player is in the air. Like going left, right, double jumping, and dashing
function Player:handleAirInput()
	if self:playerJumped() and self.doubleJumpAvailable and self.doubleJumpAbility then
		self.doubleJumpAvailable = false
		self:changeToJumpState()
	elseif pd.buttonJustPressed(pd.kButtonB) and self.dashAvailable and self.dashAbility then
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

	self:setCollideRect(10, 3, 12, 29)
	self:changeState("idle")
end


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


--- Changes the player sprite to the jump state when falling
function Player:changeToFallState()
	self:changeState("fall")
end


function Player:changeToDieState()
	self:changeState("die")
	pd.timer.performAfterDelay(150, function()
		self:changeState("dead")
	end)
end


function Player:changeToDiveState()
	self.yVelocity = 12
	if self.globalFlip == 0 then
		self.xVelocity = 4
	else
		self.xVelocity = -4
	end

	self:changeState("dive")
end


--- Changes the player sprite to the crouch state when down is pressed
function Player:changeToDuckState()
	self.xVelocity = 0

	self:setCollideRect(10, 16, 12, 16)
	self:changeState("duck")
end


--- Makes the player dash in the direction they are facing
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