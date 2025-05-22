local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Potion').extends(Pickup)



--- Initialise the potion object using the data given
--- @param  x  integer  The X coordinate to spawn the potion pickup
--- @param  y  integer  The Y coordinate to spawn the potion pickup
--- @param  e  object   The table of entities related to the potion
function Potion:init(x, y, e)
	-- Load the relevant potion table & get its length
	local i <const> = 'images/pickups/'..string.lower(e.name)..'-table-16-16'
	local t <const> = gfx.imagetable.new(i)
	local l <const> = t:getLength()

	-- Initialise the potion using the pickup class
	Potion.super.init(self, x, y, i)

	-- Add the potion animation state & start playing
	self:addState(0, 1, nil, {ts = 3, animationStartingFrame = math.random(1, l)})
	self:playAnimation()

	-- Potion properties
	self.id = e.iid
	self.name = e.name
	self.xVelocity = 0
	self.yVelocity = 0
	self.spawnX = x
	self.spawnY = y
	self.weight = 20

	-- If the potion ID is on the don't spawn list, hide the potion
	if GAME.depletedEntities[self.id] then
		self:setVisible(false)
	end

	-- Sprite properties
	self:setCollideRect(4, 8, 8, 8)
end



--- This sets the potion y velocity to 0 if invisible
function Pickup:handleState()
	if self.touchingGround then
		self.yVelocity = 0
	end

	self:applyGravity()
end



--- This method handles the ability being picked up by the player
--- @param  e  table  The player is passed into this function to manage the pick-up
function Potion:handleCollision(e)
	if not self:isVisible() then
		return
	end

	if self.name == 'Healthpotion' then
		e.hp = e.maxHP
	elseif self.name == 'Staminapotion' then
		e.sp = e.maxSP
	else
		e.mp = e.maxMP
	end

	Sparkle(self.x + 8, self.y + 8)
	GAME.depletedEntities[self.id] = true
	self:setVisible(false)
end



--- This method is called to reset potions
function Potion:reset()
	self:moveTo(self.spawnX, self.spawnY)
	self:setVisible(true)
end