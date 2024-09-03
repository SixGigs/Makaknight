-- Create the script constants
local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Fragileblock').extends(AnimatedSprite)


--- Initialise the Fragileblock object using the data given
--- @param x      integer The X coordinate to spawn the Fragileblock pick-up
--- @param y      integer The Y coordinate to spawn the Fragileblock pick-up
--- @param entity table   The table of entities related to the Fragileblock
function Fragileblock:init(x, y, entity)
	Fragileblock.super.init(self, gfx.imagetable.new('images/hazards/fragileblock-table-32-32'))

	self.respawns = entity.fields.respawns
	if self.respawns then
		self.respawn_time = entity.fields.respawn_time * 1000
	end

	self:addState('solid', 1, 1)
	self:addState('cracking', 2, 6, {ts = 1, l = 1, na = 'breaking'})
	self:addState('breaking', 7, 11, {ts = 2, l = 1, na = 'broken'})
	self:addState('broken', 12, 12)
	self:playAnimation()

	self.states["breaking"].onAnimationEndEvent = function(self) 
		if self.respawns then
			pd.timer.performAfterDelay(self.respawn_time, function()
				self:changeState('solid')
			end)
		end
	end

	-- Sprite properties
	self:setCenter(0.25, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Fragileblock)
	self:setTag(TAGS.Fragileblock)
	self:setCollideRect(8, 0, 16, 16)
	self:add()
end


function Fragileblock:crack()
	self:changeState('cracking')
end