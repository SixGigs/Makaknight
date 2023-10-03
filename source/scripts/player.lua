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