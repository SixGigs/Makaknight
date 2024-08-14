-- Create the script constants
local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Bubble').extends(AnimatedSprite)


--- Initialise the Bubble object using the data given
--- @param x      integer The X coordinate to spawn the Bubble pick-up
--- @param y      integer The Y coordinate to spawn the Bubble pick-up
--- @param entity table   The table of entities related to the Bubble
function Bubble:init(x, y, entity)
	-- If the Bubble has been picked up don't spawn it
	-- self.fields = entity.fields
	-- if self.fields.pickedUp then
	-- 	return
	-- end

	Bubble.super.init(self, gfx.imagetable.new('images/abilities/doublejump-table-16-16'))

	self:addState('wiggle', 1, 4, {ts = 4})
	self:playAnimation()

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

		if player.currentState ~= "dbJump" then
			player:changeState("jump1")
		end

		self:setVisible(false)

		pd.timer.performAfterDelay(3000, function()
			self:setVisible(true)
		end)
	end
end