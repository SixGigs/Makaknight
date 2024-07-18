-- Playdate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the bar class
class('Bar').extends(gfx.sprite)

function Bar:init(x, y, hp)
	local barImage <const> = gfx.image.new("images/player/hitpoint")

	gfx.lockFocus(barImage)
	gfx.drawRect(33, 2, hp, 5)
	gfx.fillRect(33, 6, hp, 8)
	gfx.unlockFocus()

	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Bar)
	self:setTag(TAGS.Bar)
	self:setImage(barImage)
	self:setCollideRect(0, 0, 128, 8)
	self:add()

	self.hidden = false
end

function Bar:collisionResponse(other)
	return gfx.sprite.kCollisionTypeOverlap
end

function Bar:update()
	self:handleCollisions()
end

function Bar:handleCollisions()
	local _, _, collisions, length = self:moveWithCollisions(self.x, self.y)

	for i = 1, length do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		local collisionObject <const> = collision.other
		local collisionTag <const> = collisionObject:getTag()

		if collisionTag == TAGS.Player and not self.hidden then
			self:setVisible(false)
			pd.timer.performAfterDelay(2000, function()
				self:setVisible(true)
				self.hidden = false
			end)
			self.hidden = true
		end
	end
end