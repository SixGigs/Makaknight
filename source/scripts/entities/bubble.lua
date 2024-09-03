local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Bubble').extends(AnimatedSprite)


--- Initialise the Bubble object using the data given
--- @param  x  integer  The X coordinate to spawn the Bubble pick-up
--- @param  y  integer  The Y coordinate to spawn the Bubble pick-up
--- @param  e  object   The table of entities related to the Bubble
function Bubble:init(x, y, e)
	Bubble.super.init(self, gfx.imagetable.new('images/abilities/doublejump-table-16-16'))

	self:addState('a', 1, 4, {ts = 4})
	self:playAnimation()

	self.respawnTimer = e.fields.respawn * 1000

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Bubble)
	self:setTag(TAGS.Bubble)
	self:setCollideRect(0, 4, 16, 16)
	self:add()
end


--- This method handles the Bubble being picked up by the player
--- @param player table The player is passed into this function to manage the pick-up
function Bubble:bounce(player)
	if self:isVisible() then
		player.touchingGround = false
		player.yVelocity = -270

		if player.currentState ~= 'dbJump' then
			player:changeState('jump1')
		end

		pd.timer.performAfterDelay(self.respawnTimer, function()
			self:setVisible(true)
		end)

		self:setVisible(false)
	end
end