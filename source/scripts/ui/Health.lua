local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Health').extends(Bar)


function Health:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/health-table-122-16')
	Health.super.init(self, x, y, i)

	self:changeState(tostring(math.floor(g.player_hp)))
end	


function Health:update()
	self:updateVisibility()

	if g.player_hp < g.player_max_hp then
		self:show()
	end

	if self:isVisible() then
		if self.currentState ~= tostring(math.floor(g.player_hp)) then
			self:changeState(tostring(math.floor(g.player_hp)))
		end
	end
end