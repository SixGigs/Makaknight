-- Create constants for the playdate and playdate.graphics
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create hit box constants
local standing <const> = {['x'] = 38, ['y'] = 44, ['w'] = 4, ['h'] = 36}
local crouching <const> = {['x'] = 38, ['y'] = 61, ['w'] = 4, ['h'] = 19}




-- Create the player class
class('Player').extends(AnimatedSprite)

--- The player is initialised with this method
--- @param  x      integer  The X coordinate to spawn the player
--- @param  y      integer  The Y coordinate to spawn the player
--- @param  world  table    The game manager is passed in to manage player on object interactions
function Player:init(world)
	-- Load player image, add equipment & armour
	local image = gfx.image.new('images/player/player')
	local imagetable <const> = self:addArmour(image)
	Player.super.init(self, imagetable)

	self.world = world -- Save the World Class as a property

	---[ AnimatedSprite library - States, loops, and animations ] ----------------------------------------
	self:addState('idle',     1, 16,    {ts = 2})
	self:addState('walk',     17, 28,   {ts = 1.3})
	self:addState('duckDown', 29, 29,   {ts = 1, l = 1, na = 'duck'})
	self:addState('duck',     30, 30)
	self:addState('duckUp',   31, 31,   {ts = 1, l = 1, na = 'idle'})
	self:addState('jump',     32, 32)
	self:addState('jump1',    33, 33)
	self:addState('jump2',    34, 34)
	self:addState('jump3',    35, 35)
	self:addState('midJump',  36, 36)
	self:addState('dash',     36, 36)   -- REMAKE LATER
	self:addState('fall',     37, 37)
	self:addState('fall1',    38, 38)
	self:addState('fall2',    39, 39)
	self:addState('fall3',    40, 40)
	self:addState('contact',  41, 42,   {ts = 2, l = 1, na = 'idle'})
	self:addState('roll',     43, 58,   {ts = 1, l = 1, na = 'midJump'})
	self:addState('dbJump',   59, 74,   {ts = 1, l = 1})
	self:addState('hurt',     75, 76,   {ts = 1, l = 12, na = 'fall'})
	self:addState('run',      77, 88,   {ts = 1})
	self:addState('dive',     89, 89)
	self:addState('die',      90, 94,   {ts = 3, l = 1, na = 'dead'})
	self:addState('dead',     95, 95)
	self:addState('spawn',    96, 101,  {ts = 3, l = 1, na = 'idle'})
	self:addState('ready',    102, 111, {ts = 3})
	self:addState('punch',    112, 114, {ts = 1, l = 1})
	self:addState('exit',     99, 101,  {ts = 3, l = 1, na = 'idle'})
	self:addState('entering', 115, 116, {ts = 3, l = 1, na = 'enter'})
	self:addState('enter',    117, 117)
	self:addState('runTurn',  118, 118, {ts = 5, l = 1, na = 'idle'})

	-- The following are temporary sprites that will be animated later
	self:addState("duckPunch", 78, 81, {ts = 1})
	self:playAnimation()




	-- If the yVelocity increases or decreases in these states then enter jumping or falling
	self.states['idle'].onFrameChangedEvent  = function(self) self:handleYVelocity() end
	self.states['ready'].onFrameChangedEvent = function(self) self:handleYVelocity() end
	self.states['duck'].onFrameChangedEvent  = function(self) self:handleYVelocity() end
	self.states['walk'].onFrameChangedEvent  = function(self) self:handleYVelocity() end
	self.states['run'].onFrameChangedEvent   = function(self) self:handleYVelocity() end

	-- If the players yVelocity is less than -240 pixels a second, change to the jump1 sprite
	self.states["jump"].onFrameChangedEvent = function(self)
		if self.yVelocity > -240 then
			self:changeState("jump1")
		end
	end

	-- If the players yVelocity is less than -150 pixels a second, change to the jump2 sprite
	-- Or if the players yVelocity is more than -240 pixels a second, change back to the jump sprite
	self.states["jump1"].onFrameChangedEvent = function(self)
		if self.yVelocity > -150 then
			self:changeState("jump2")
		elseif self.yVelocity < -240 then
			self:changeState("jump")
		end
	end

	self.states["jump2"].onFrameChangedEvent = function(self)
		if self.yVelocity > -90 then
			self:changeState("jump3")
		elseif self.yVelocity < -150 then
			self:changeState("jump1")
		end
	end

	self.states["jump3"].onFrameChangedEvent = function(self)
		if self.yVelocity > -60 then
			self:changeState("midJump")
		elseif self.yVelocity < -90 then
			self:changeState("jump2")
		end
	end

	self.states["midJump"].onFrameChangedEvent = function(self)
		if self.yVelocity > -30 then
			self:changeState("fall")
		elseif self.yVelocity < -60 then
			self:changeState("jump3")
		end
	end

	self.states["fall"].onFrameChangedEvent = function(self)
		if self.yVelocity > 0 then
			self:changeState("fall1")
		elseif self.yVelocity < -30 then
			self:changeState("midJump")
		end
	end

	self.states["fall1"].onFrameChangedEvent = function(self)
		if self.yVelocity > 60 then
			self:changeState("fall2")
		elseif self.yVelocity < 0 then
			self:changeState("fall")
		end
	end

	self.states["fall2"].onFrameChangedEvent = function(self)
		if self.yVelocity > 150 then
			self:changeState("fall3")
		elseif self.yVelocity < 60 then
			self:changeState("fall1")
		end
	end

	self.states["fall3"].onFrameChangedEvent = function(self)
		if self.yVelocity < 150 then
			self:changeState("fall2")
		end
	end




	-- If the double jump animation ends, change to the mid jump state
	self.states["dbJump"].onAnimationEndEvent = function(self)
		self:changeState("midJump")
	end

	self.states["contact"].onAnimationEndEvent = function(self)
		self:changeToIdleState()
	end

	self.states["hurt"].onAnimationEndEvent = function(self) 
		self.hurt = false
		self.doubleJumpAvailable = false
	end

	self.states['runTurn'].onAnimationEndEvent = function(self)
		if self.globalFlip == 0 then
			self.globalFlip = 1
		else
			self.globalFlip = 0
		end
		
		self.xVelocity = 0
	end



	-- General player class properties
	self.hp = GAME.playerHP
	self.sp = GAME.playerSP
	self.mp = GAME.playerMP
	self.maxHP = GAME.playerMaxHP
	self.maxSP = GAME.playerMaxSP
	self.maxMP = GAME.playerMaxMP
	self.globalFlip = GAME.playerFacing
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
	self.weight = 72
	self.holster = ''
	self.hand = ''
	self.hurt = false
	self.dead = false

	-- Array of playdate tags the player hit box can overlap with
	self.overlapTags = {
		[TAGS.Hazard] = true,
		[TAGS.Pickup] = true,
		[TAGS.Flag] = true,
		[TAGS.Prop] = true,
		[TAGS.Door] = true,
		[TAGS.Animal] = true,
		[TAGS.Hitbox] = true,
		[TAGS.Crown] = true,
		[TAGS.Gui] = true,
		[TAGS.Bubble] = true,
		[TAGS.Fragile] = true,
		[TAGS.Wind] = true,
		[TAGS.Spike] = true,
		[TAGS.Half] = true,
		[TAGS.Effect] = true
	}

	-- Array of all the player states which have no input hooks or gravity
	self.noInputStates = {
		['contact'] = true,
		['spawn'] = true,
		['punch'] = true,
		['dead'] = true,
		['dive'] = true,
		['die'] = true,
		['punch'] = true,
		['duckPunch'] = true,
		['duckUp'] = true,
		['duckDown'] = true,
		['exit'] = true,
		['enter'] = true,
		['entering'] = true
	}

	-- Run properties
	self.maxSpeed = 195
	self.runStaminaCost = 7.5

	-- Roll properties
	self.rollAvailable = true
	self.rollSpeed = 165
	self.rollRecharge = 600
	self.rollStaminaCost = 20

	-- Dive properties
	self.diveManaCost = 10
	self.diveSpeed = 900
	self.diveHorizontal = 160

	-- Jump properties
	self.jumping = false
	self.jumpSpeed = 112
	self.jumpCounter = 0
	self.jumpCounterMax = 0.1
	self.jumpVelocity = -220
	self.jumpBufferAmount = 3
	self.jumpStaminaCost = 1
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

	-- Double Jump properties
	self.doubleJumpManaCost = 5
	self.doubleJumpAvailable = true
	self.doubleJumpVelocity = -300

	-- Dash properties
	self.dashManaCost = 10
	self.dashAvailable = true
	self.dashMinimumSpeed = 120
	self.dashSpeed = 450
	self.dashDrag = 630
	self.damage = 20

	-- Punch properties
	self.punchAvailable = true
	self.punchStaminaCost = 5
	self.punchFrameDuration = 30
	self.punchBufferAmount = 4
	self.punchRecharge = 195
	self.punchBuffer = 0
	self.punchDamage = 5

	-- Left & Right buffer properties
	self.bufferAmount = 2
	self.leftBuffer = 0
	self.rightBuffer = 0
	self.upBuffer = 0
	self.bBuffer = 0

	-- Status buffer properties
	self.setStaminaBuffer = false
	self.staminaBufferAmount = 60
	self.staminaBuffer = 0

	-- Mana buffer properties
	self.setManaBuffer = false
	self.manaBufferAmount = 60
	self.manaBuffer = 0

	-- Run buffer properties
	self.runBufferAmount = 4
	self.runLeftBuffer = 0
	self.runRightBuffer = 0

	-- Physics properties
	self.xVelocity = GAME.playerXVelocity
	self.yVelocity = GAME.playerYVelocity
	self.minimumAirSpeed = 15
	self.walkSpeed = 90
	self.drag = 120




	self:changeState(GAME.playerState)
	-- Do -1 here to stop the player slipping through half tiles
	self:moveTo(GAME.playerX, GAME.playerY -1)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setHitBox(standing)
end




--- The player update function runs every game tick and manages all input/responses
function Player:update()
	-- This keeps the player animations playing
	self:updateAnimation()

	-- Update globals so the game saves correct data when closed
	GAME.playerHP = self.hp
	GAME.playerSP = self.sp
	GAME.playerMP = self.mp
	GAME.playerFacing = self.globalFlip
	GAME.playerX = self.x
	GAME.playerY = self.y
	GAME.playerXVelocity = self.xVelocity
	GAME.playerYVelocity = self.yVelocity
	GAME.playerState = self.currentState

	-- If not dead update player buffers, handle player states, and movement with collisions
	if self.dead then return end	
	self:updateBuffers()
	self:handleState()
	self:handleMovementAndCollisions()
end



--- Update all game buffers
function Player:updateBuffers()
	-- Update each game buffer, math.max ensures it never goes below zero
	self.jumpBuffer = math.max(self.jumpBuffer - (30 * DELTA_TIME), 0)
	self.bBuffer = math.max(self.bBuffer - (30 * DELTA_TIME), 0)
	self.punchBuffer = math.max(self.punchBuffer - (30 * DELTA_TIME), 0)
	self.leftBuffer = math.max(self.leftBuffer - (30 * DELTA_TIME), 0)
	self.rightBuffer = math.max(self.rightBuffer - (30 * DELTA_TIME), 0)
	self.upBuffer = math.max(self.upBuffer - (30 * DELTA_TIME), 0)
	self.staminaBuffer = math.max(self.staminaBuffer - (30 * DELTA_TIME), 0)
	self.manaBuffer = math.max(self.manaBuffer - (30 * DELTA_TIME), 0)
	self.runLeftBuffer = math.max(self.runLeftBuffer - (30 * DELTA_TIME), 0)
	self.runRightBuffer = math.max(self.runRightBuffer - (30 * DELTA_TIME), 0)

	-- Set the game buffers if each button is pressed
	if pd.buttonJustPressed(pd.kButtonA) then
		self.jumpBuffer = self.jumpBufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		self.bBuffer = self.bufferAmount
		self.punchBuffer = self.punchBufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonLeft) then
		self.leftBuffer = self.bufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonRight) then
		self.rightBuffer = self.bufferAmount
	end

	if pd.buttonJustPressed(pd.kButtonUp) then
		self.upBuffer = self.bufferAmount
	end

	if pd.buttonIsPressed(pd.kButtonB) then
		if pd.buttonIsPressed(pd.kButtonLeft) then
			self.runLeftBuffer = self.runBufferAmount
		elseif pd.buttonIsPressed(pd.kButtonRight) then
			self.runRightBuffer = self.runBufferAmount
		end
	end

	-- Set the stamina buffer if requested
	if self.setStaminaBuffer then
		self.staminaBuffer = self.staminaBufferAmount
		self.setStaminaBuffer = false
	end

	-- Set the mana buffer if requested
	if self.setManaBuffer then
		self.manaBuffer = self.manaBufferAmount
		self.setManaBuffer = false
	end
end




--- These methods return true if the buffer is greater than zero
function Player:playerPunched() return self.punchBuffer > 0 end
function Player:playerPressedLeft() return self.leftBuffer > 0 end
function Player:playerPressedRight() return self.rightBuffer > 0 end
function Player:playerPressedUp() return self.upBuffer > 0 end
function Player:playerJumped() return self.jumpBuffer > 0 end
function Player:playerPressedB() return self.bBuffer > 0 end
function Player:staminaBlocked() return self.staminaBuffer > 0 end
function Player:manaBlocked() return self.manaBuffer > 0 end




--- The state handler changes the functions running on the player based on state
function Player:handleState()
	self:regenerateStamina()
	self:regenerateMana()

	-- If the player is in the air we use this statement to handle that
	if self.jumpStates[self.currentState] then
		if self.touchingGround then
			if self.yVelocity > 360 then
				if pd.buttonIsPressed(pd.kButtonDown) then
					self:changeToDuckState()
				else
					self:changeToContactState()
				end
			else
				if pd.buttonIsPressed(pd.kButtonDown) then
					self:changeToDuckingState()
				else
					self:changeToIdleState()
				end
			end
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == "hurt" then
		self:applyGravity()
		self:applyDrag(self.drag)

		if self.touchingGround and self.hp == 0 and not self.dead then
			self:die()
		end
	elseif self.currentState == "dash" then
		self:applyGravity()
		self:applyDrag(self.dashDrag)

		if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
			self:changeToMidJumpState()
		elseif self.touchingGround then
			self:changeToIdleState()
		end
	elseif self.currentState == "duck" then
		self.xVelocity = 0
		self:applyGravity()
		self:handleDuckInput()
	elseif self.currentState == "dbJump" then
		if self.touchingGround then
			self:changeToDuckState()
		end

		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()
	elseif self.currentState == 'roll' then
		self:applyGravity()
		self:applyDrag(self.drag)
	elseif self.currentState == 'runTurn' then
		if self.globalFlip == 1 then
			self.xVelocity = -self.walkSpeed
		else
			self.xVelocity = self.walkSpeed
		end

		self:applyGravity()
	elseif self.noInputStates[self.currentState] then
	else
		self:applyGravity()
		self:handleGroundInput()
	end
end



--- This function handles all player movement input and any collisions that might occur
function Player:handleMovementAndCollisions()
	local xMovement = self.x + (self.xVelocity * DELTA_TIME)
	local yMovement = self.y + (self.yVelocity * DELTA_TIME)
	local _, _, collisions, length = self:moveWithCollisions(xMovement, yMovement)

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

		if collisionTag == TAGS.Hazard then
			if self.currentState ~= 'hurt' then
				collisionObject:handleCollision(self)
			end
		elseif collisionTag == TAGS.Bubble then
			collisionObject: handleCollision(self)
		elseif collisionTag == TAGS.Flag then
			self:handleFlagCollision(collisionObject)
		elseif collisionTag == TAGS.Door then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Crown then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Fragile then
			collisionObject:handleCollision(self, collision)
		elseif collisionTag == TAGS.Wind then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Pickup then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Roaster then
			collisionObject:handleCollision(self)
		elseif collisionTag == TAGS.Animal then
			if self.currentState == 'dash' or self.currentState == 'dive' then
				collisionObject:handleCollision(self)
			end
		end
	end

	-- If the world is wider than 400 pixels and the player is 250 or more pixels across the screen update the world
	if self.x + self.xVelocity > self.x and self.x >= 250 and GAME.worldX + SCREEN['width'] < self.world.width - 1 then
		self.world:update()
	end

	-- If the world X value is greater than 0 and the player is 150 or less pixels across the screen update the world
	if self.x + self.xVelocity < self.x and self.x <= 150 and GAME.worldX > 1 then
		self.world:update()
	end

	-- If the world is taller than 240 pixels and the player is in the centre of the screen update the world
	if self.world.height > 240 then
		if self.y + self.yVelocity < self.y and self.y <= (SCREEN['height'] / 2) - (standing['h'] / 2) and GAME.worldY > 0 then 
			self.world:update()
		end

		if (self.y + self.yVelocity) > self.y and self.y >= SCREEN['height'] / 2 + (standing['h'] / 4) and GAME.worldY + SCREEN['height'] < self.world.height then
			self.world:update()
		end
	end

	-- Change to face the direction we are moving in
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	-- If touching the edge of the room, lets try moving into the next room
	if self.x < -22 then
		self.world:enterRoom("west")
	elseif self.x > 422 then
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

	if self.hp < GAME.playerHP then self:changeToHurtState() end -- Check if we took damage and change to hurt state
	if self.hp <= 0 and self.currentState ~= 'hurt' then died = true end -- Check if we are dead from no hit points
	if died and not self.dead then self:die() end -- If the player is dead then run the die method
end



function Player:reset()
	self.hp = self.maxHP
	self.sp = self.maxSP
	self.mp = self.maxMP
	self.dead = false
	self.hurt = false
	
	self:setCollisionsEnabled(true)
	self.world:resetPlayer()
end



--- This method handles collisions with objects that can deal damage
--- @param  obj  object   This object contains all collision object data
--- @param  tag  integer  This integer contains the ID of the collision object
function Player:handleDamageCollision(obj, tag)
	-- Presume the player takes no damage until proven otherwise
	local damage = 0

	-- If the player is not already in a hurt state, lets see if they can be hurt again
	if not self.hurt then
		damage = obj.damage

		-- If the damage number is not zero, deduct it from the player health
		if damage ~= 0 then
			self.hp = self.hp - damage

			-- Round player HP back up to 0 if it is less than zero
			-- And if not below zero, put the player into a hurt state
			if self.hp < 0 then
				self.hp = 0
			end
		end
	end
end



--- Trigger checkpoint
--- param flag table The checkpoint triggered
function Player:handleFlagCollision(flag)
	if flag.currentState == 'up' then return end -- If the Flag is Hoisted Do Nothing

	-- Lower any other flag on screen
	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		if sprite:isa(Flag) then
			sprite:lower()
		end
	end

	flag:hoist() -- Raise the touched flag

	-- Top up player properties
	self.hp = self.maxHP
	self.sp = self.maxSP
	self.mp = self.maxMP
end



function Player:handleVariableJump()
	if pd.buttonJustReleased(pd.kButtonA) or self.jumpCounter > (self.jumpCounterMax * GAME.fps) then
		if self.jumping then
			self.jumpCounter = 0
			self.jumping = false
		end
	end

	if self.jumping then 
		if self.sp > self.jumpStaminaCost then
			self.yVelocity = self.jumpVelocity
			self.jumpCounter = self.jumpCounter + 1
			self:deductStamina(self.jumpStaminaCost)
		end

		self.setStaminaBuffer = true
	end
end



--- This function handles when the player dies, what to do and when to respawn
function Player:die()
	-- Stop the player from moving & interacting
	self.xVelocity = 0
	self.yVelocity = 0
	self.dead = true

	-- Stop player collisions & set a timer to reset the player
	self:setCollisionsEnabled(false)
	pd.timer.performAfterDelay(2000, function()
		Fade('out')

		pd.timer.performAfterDelay(500, function()
			self:reset()
		end)
	end)

	-- Create some local vars dropping coins
	local xCoin = self.x
	local yCoin = 0
	local coins = math.ceil(GAME.playerCoins / 2)

	-- If the player dies offscreen set coins to spawn at 236
	if self.y > 240 then
		yCoin = 236
	else
		yCoin = self.y
	end

	-- If the amount of coins dropped is greater than 4, set it to 4
	if coins > 4 then
		coins = 4
	end

	-- Spawn as many dropped coins as necessary
	for i = 1, coins, 1 do
		Coin(xCoin, yCoin)
	end

	-- Deduct the coins from the player & show new coin balance
	GAME.playerCoins = math.floor(GAME.playerCoins / 2, 0.5)
	Text('$ ' .. tostring(GAME.playerCoins), 'right', 0)

	-- Set the player to the die state
	self:changeState('die')
end




--- Handle input while the player is on the ground. Like going left, right, dashing, and jumping
function Player:handleGroundInput()
	if self:playerJumped() then
		self:changeToJumpState()
	elseif pd.buttonIsPressed(pd.kButtonB) then
		if pd.buttonIsPressed(pd.kButtonLeft) then
			if self.sp > self.runStaminaCost then
				if self.runRightBuffer > 0 then
					self:changeState('runTurn')
				else
					self:changeToRunState('left')
					self:deductStamina(self.runStaminaCost * DELTA_TIME)
				end
			else
				self:changeToWalkState('left')
			end

			self.setStaminaBuffer = true
		elseif pd.buttonIsPressed(pd.kButtonRight) then
			if self.sp > self.runStaminaCost then
				if self.runLeftBuffer > 0 then
					self:changeState('runTurn')
				else
					self:changeToRunState('right')
					self:deductStamina(self.runStaminaCost * DELTA_TIME)
				end
			else
				self:changeToWalkState('right')
			end

			self.setStaminaBuffer = true
		else
			self:changeToReadyState()
		end
	else
		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:changeToWalkState('left')
			self.setStaminaBuffer = true
		elseif pd.buttonIsPressed(pd.kButtonRight) then
			self:changeToWalkState('right')
			self.setStaminaBuffer = true
		else
			if self.currentState ~= 'idle' then
				self:changeToIdleState()
			end
		end
	end

	if pd.buttonIsPressed(pd.kButtonDown) then
		self:changeToDuckingState()
	end

	if self.rollAvailable and self:playerPressedB() then
		if self:playerPressedLeft() then
			self:changeToRollState('left')
		elseif self:playerPressedRight() then
			self:changeToRollState('right')
		end
	end

	if self:playerPunched() then
		if pd.buttonJustReleased(pd.kButtonB) then
			self:changeToPunchState('punch')
		end
	end

	if pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
		self.xVelocity = 0
	end

	self:handleVariableJump()
end




--- Handle input while the player is crouched
function Player:handleDuckInput()
	if not pd.buttonIsPressed(pd.kButtonDown) then
		self:setHitBox(standing)
		self:changeState('duckUp')
	end

	-- if self:playerPunched() then
	-- 	if pd.buttonJustReleased(pd.kButtonB) and not self.punchAvailable then
	-- 		self:changeToPunchState("duckPunch")
	-- 	end
	-- end
end




--- Handle input while the player is in the air. Like going left, right, double jumping, and dashing
function Player:handleAirInput()
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self.xVelocity = -self.jumpSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self.xVelocity = self.jumpSpeed
	end

	if pd.buttonIsPressed(pd.kButtonUp) then
		if pd.buttonIsPressed(pd.kButtonB) and not pd.buttonIsPressed(pd.kButtonDown) then
			if self.doubleJumpAvailable then
				self:changeToDoubleJumpState()
			end
		end
	end

	if pd.buttonIsPressed(pd.kButtonLeft) or pd.buttonIsPressed(pd.kButtonRight) then
		if self:playerPressedB() then
			if self.dashAvailable then
				self:changeToDashState()
			end
		end
	end

	if pd.buttonIsPressed(pd.kButtonDown) then
		if pd.buttonJustPressed(pd.kButtonB) then
			self:changeToDiveState()
		end
	end

	self:handleVariableJump()
end




--- If the player is not moving on the X axis change to an idle state
function Player:changeToIdleState()
	if self.currentState ~= 'idle' then
		self.yVelocity = 0
		self.xVelocity = 0

		self:setHitBox(standing)
		self:changeState('idle')
	end
end




--- Change the player to a ready state
function Player:changeToReadyState()
	if self.currentState ~= 'ready' then
		self.xVelocity = 0
		self.yVelocity = 0

		self:setHitBox(standing)
		self:changeState('ready')
	end
end




--- If the player is moving in any direction set their X movement velocity to their max speed and change sprite
--- @param direction string Contains the direction the player is moving in as a string
function Player:changeToWalkState(direction)
	if direction == 'left' then
		self.xVelocity = -self.walkSpeed
	elseif direction == 'right' then
		self.xVelocity = self.walkSpeed
	end

	if self.currentState ~= 'walk' then
		self:changeState('walk')
	end
end




--- Change the player into a running state
function Player:changeToRunState(direction)
	if direction == 'left' then
		self.xVelocity = -self.maxSpeed
	elseif direction == 'right' then
		self.xVelocity = self.maxSpeed
	end

	if self.currentState ~= 'run' then
		self:changeState('run')
	end
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

	if self.currentState ~= 'hurt' then
		self:changeState('hurt')
	end
end




--- Changes the player sprite & Y velocity to the jump velocity
function Player:changeToJumpState()
	if self.sp > self.jumpStaminaCost then
		self.jumping = true
		self.jumpBuffer = 0
		self.yVelocity = self.jumpVelocity
		self:deductStamina(self.jumpStaminaCost)
	end

	self.setStaminaBuffer = true
end




--- Changes the player sprite to the mid jump sprite
function Player:changeToMidJumpState()
	self:setHitBox(standing)
	self:changeState('midJump')
end




--- Allow the player to double jump
function Player:changeToDoubleJumpState()
	if self.mp > self.doubleJumpManaCost then
		self.jumpBuffer = 0
		self.doubleJumpAvailable = false
		self.yVelocity = self.doubleJumpVelocity
		self:changeState('dbJump')
		self:deductMana(self.doubleJumpManaCost)		
	end

	self.setManaBuffer = true
end




--- Changes the player to the duck state
function Player:changeToDuckState()
	self.xVelocity = 0
	self.yVelocity = 0

	self:setHitBox(crouching)
	self:changeState('duck')
end




--- Changes the player sprite to the crouch state when down is pressed
function Player:changeToDuckingState()
	self.xVelocity = 0
	self.yVelocity = 0

	self:setHitBox(crouching)
	self:changeState('duckDown')
end




--- Change the player into a roll state
--- @param  direction  string  The direction to roll in
function Player:changeToRollState(direction)
	if self.sp > self.rollStaminaCost then
		self.rollAvailable = false
		self:setHitBox(crouching)

		if direction == 'left' then
			self.xVelocity = -self.rollSpeed
		elseif direction == 'right' then
			self.xVelocity = self.rollSpeed
		end

		pd.timer.performAfterDelay(490, function()
			pd.timer.performAfterDelay(self.rollRecharge, function()
				self.rollAvailable = true
			end)
		end)

		self:deductStamina(self.rollStaminaCost)
		self:changeState('roll')
	end

	self.setStaminaBuffer = true
end




--- Changes the player to the contact state
function Player:changeToContactState()
	self.yVelocity = 0
	self.xVelocity = 0

	self:changeState('contact')
end




--- Changes the player to a punch state
function Player:changeToPunchState(state)
	if self.sp > self.punchStaminaCost then
		self.xVelocity = 0
		self.yVelocity = 0

		if self.punchAvailable then
			local hitboxX = self.globalFlip == 0 and self.x + 9 or self.x - 17
			local hitboxY = self.y + 9
			if state == 'punch' then
				hitboxX = self.globalFlip == 0 and self.x + 12 or self.x - 24
				hitboxY = self.y + 16
			end

			Hitbox(hitboxX, hitboxY, 12, 7, self.punchDamage, self.punchFrameDuration)

			self.punchAvailable = false
			pd.timer.performAfterDelay(self.punchRecharge, function()
				self.punchAvailable = true
			end)

			self:deductStamina(self.punchStaminaCost)
			self:changeState(state)
		end
	end

	self.setStaminaBuffer = true
end




--- Changes the player to the dive state
function Player:changeToDiveState()
	if self.mp > self.diveManaCost then
		self.yVelocity = self.diveSpeed

		if self.globalFlip == 0 then
			self.xVelocity = self.diveHorizontal
		else
			self.xVelocity = -self.diveHorizontal
		end

		self:deductMana(self.dashManaCost)
		self:changeState('dive')
	end

	self.setManaBuffer = true
end




--- This method make the player dash in the direction they face
function Player:changeToDashState()
	if self.mp > self.dashManaCost then
		self.dashAvailable = false
		self.yVelocity = -self.walkSpeed
	
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

		self:deductMana(self.dashManaCost)
		self:changeState('dash')
	end

	self.setManaBuffer = true
end



function Player:changeToSpawnState()
	self:setHitBox(standing)
	self:changeState('spawn')
end




--- Applies gravity to the player, used if the player is not touching a surface
--- Resets Y velocity when colliding with a ceiling or the ground
function Player:applyGravity()
	self.yVelocity = self.yVelocity + ((GRAVITY + self.weight) * DELTA_TIME)

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
		self.xVelocity = self.xVelocity - (amount * DELTA_TIME)
	elseif self.xVelocity < 0 then
		self.xVelocity = self.xVelocity + (amount * DELTA_TIME)
	end

	if math.abs(self.xVelocity) < self.minimumAirSpeed or self.touchingWall then
		self.xVelocity = 0
	end
end




--- This method is used to calculate when to regenerate stamina and how quickly
function Player:regenerateStamina()
	if self.sp < self.maxSP and not self:staminaBlocked() then
		if self.currentState == 'duck' then
			self.sp = self.sp + 30 * DELTA_TIME
		end

		self.sp = self.sp + 30 * DELTA_TIME
	end

	if self.sp > self.maxSP then
		self.sp = self.maxSP
	end
end




--- This method is used to calculate when to regenerate mana
function Player:regenerateMana()
	if self.mp < self.maxMP and not self:manaBlocked() then
		self.mp = self.mp + 1 * DELTA_TIME
	end

	if self.mp > self.maxMP then
		self.mp = self.maxMP
	end
end




--- This method is used to deduct stamina from the player, and request a stamina buffer set
--- @param  amount  integer  The amount of stamina to deduct from the player
function Player:deductStamina(amount)
	self.sp = self.sp - amount
end




function Player:deductMana(amount)
	self.mp = self.mp - amount
end




--- This method is used to set the player hit box dimensions and uses a table to do it
--- @param  hitBox  table  A table containing an X, Y, Width, and Height for the collision rect
function Player:setHitBox(hitBox)
	self:setCollideRect(hitBox['x'], hitBox['y'], hitBox['w'], hitBox['h'])
end




--- This method handles falling and jumping sprite changes in several onFrameChangeEvents
function Player:handleYVelocity()
	if self.yVelocity < 0 then
		self:changeState('jump')
	elseif self.yVelocity > 90 then
		self:changeState('fall')
	end
end




function Player:addArmour(sheet)
	-- Sprite sheet frame width & height
	local width <const> = 80
	local height <const> = 80

	-- ADD ARMOUR/CUSTOMISING CODE HERE

	local helmet = gfx.image.new('images/player/roman-helmet')
	gfx.pushContext(sheet)
	helmet:draw(0, 0)
	gfx.popContext()

	-- Calculate number of frames
	local sheetWidth, sheetHeight <const> = sheet:getSize()
	local columns = math.floor(sheetWidth / width)
	local rows = math.floor(sheetHeight / height)

	-- Create a new imagetable
	local frames = {}
	for row = 0, rows - 1 do
		for col = 0, columns - 1 do
			local frame = gfx.image.new(width, height)
			gfx.pushContext(frame)
			sheet:draw(-col * width, -row * height)
			gfx.popContext()
			table.insert(frames, frame)
		end
	end

	-- Convert frames into an imagetable
	local imagetable = {}
	setmetatable(imagetable, {
		__index = function(_, i)
			return frames[i]
		end,
		__len = function()
			return #frames
		end
	})

	return imagetable
end




--- This method is used to handle the collisions the player has with the world
--- @param   e        table    This variable contains what the player has collided with
--- @return  unknown  unknown  The function returns the collision response to use
function Player:collisionResponse(e)
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
