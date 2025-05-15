local gfx <const> = playdate.graphics
class('Potion').extends(AnimatedSprite)



--- Initialise the pickup object using the data given
--- @param  x  integer  The X coordinate to spawn the ability pick-up
--- @param  y  integer  The Y coordinate to spawn the ability pick-up
--- @param  e  object   The table of entities related to the ability
function Potion:init(x, y, e)
	local i <const> = gfx.imagetable.new('images/pickups/' .. string.lower(e.name) .. '-table-16-16')
	local l <const> i:getLength()

	-- Initialise the class
	Potion.super.init(self, i)

	-- Animation settings
	self:addState(0, 1, l, {ts = e.fields.tickSpeed})
	self:playAnimation()

	-- Potion properties
	self.id = e.iid
	self.ticker = 0
	self.timer = false
	self.restore_hp = e.fields.restore_hp and e.fields.restore_hp or 0
	self.restore_sp = e.fields.restore_sp and e.fields.restore_sp or 0
	self.restore_mp = e.fields.restore_mp and e.fields.restore_mp or 0

	-- If the potion ID is on the don't spawn list, hide the potion
	if GAME.depletedEntities[self.id] then
		self:setVisible(false)
	end

	-- Sprite properties
	self:setCollideRect(4, 8, 8, 8)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setTag(TAGS.Pickup)
	self:add()
end



--- This function runs every game tick and handles potion bottle behaviour
function Potion:update()
	self:updateAnimation()
	
	if self:isVisible() then
		self:handleState()
	end
end



--- This method handles potion behaviour if the potion is visible
function Potion:handleState()	
	if not self.timer then
		self.timer = true
		self.ticker = math.random(GAME.fps, GAME.fps * 3)
		return
	end
	
	self.ticker = self.ticker - (30 * DELTA_TIME)
	
	if self.ticker <= 0 then
		Sparkle(self.x + 8, self.y + 8)
		self.timer = false
	end
end



--- This method handles the ability being picked up by the player
--- @param player table The player is passed into this function to manage the pick-up
function Potion:pickUp(e)
	if not self:isVisible() then
		return
	end

	e.hp = e.hp + self.restore_hp
	if e.hp > 100 then
		e.hp = 100
	end

	e.sp = e.sp + self.restore_sp
	if e.sp > 100 then
		e.sp = 100
	end

	e.mp = e.mp + self.restore_mp
	if e.mp > 100 then
		e.mp = 100
	end

	Sparkle(self.x + 8, self.y + 8)
	GAME.depletedEntities[self.id] = true
	self:setVisible(false)
end