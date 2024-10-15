local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Health').extends(Bar)


function Health:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/health-table-122-16')
	Health.super.init(self, x, y, i)

	self:changeState(tostring(g.player_hp))
end	


function Health:update()
	self:updateVisibility()
	if self.currentState ~= tostring(g.player_hp) then
		self:changeState(tostring(g.player_hp))
		self:setVisible(true)
		self.timer = self.timerMax
	end
end