local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)


function Player:init(x, y)
	-- State Machine
	local playerImageTable = gfx.imagetable.new("images/player-table-32-32")
	Player.super.init(self, playerImageTable)

	self:addState("idle", 4, 4)
	self:addState("run", 1, 4, {tickStep = 3})
	self:addState("jump", 5, 5)
	self:playAnimation()

	-- Sprite Properties
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setCollideRect(10, 3, 12, 29)

	-- Physics Properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 1.0
	self.maxSpeed = 2.0

	-- Player State
	self.touchingGround = false
end


function Player:collisionResponse()
	return gfx.sprite.kCollisionTypeSlide
end


function Player:update()
	self:updateAnimation()

	self:handleState()
	self:handleMovementAndCollisions()
end


function Player:handleState()
	if self.currentState == "idle" then
		self:applyGravity()
		self:handleGroundInput()
	elseif self.currentState == "run" then
		self:applyGravity()
		self:handleGroundInput()
	elseif self.currentState == "jump" then
		
	end
end


function Player:handleMovementAndCollisions()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

	self.touchingGround = false
	for i = 1, length do
		local collision = collisions[i]
		if collision.normal.y == -1 then
			self.touchingGround = true
		end
	end
end


-- Input Helper Functions
function Player:handleGroundInput()
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:changeToRunState("left")
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self:changeToRunState("right")
	else
		self:changeToIdleState()
	end
end


-- State Transitions
function Player:changeToIdleState()
	self.xVelocity = 0
	self:changeState("idle")
end


function Player:changeToRunState(direction)
	if direction == "left" then
		self.xVelocity = -self.maxSpeed
	elseif direction == "right" then
		self.xVelocity = self.maxSpeed
	end
	self:changeState("run")
end


-- Physics Helper Functions
function Player:applyGravity()
	self.yVelocity = self.yVelocity + self.applyGravity
	if self.touchingGround then
		self.yVelocity = 0
	end
end