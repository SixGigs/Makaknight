local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Health').extends(Bar)


function Health:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/health-table-122-16')
	Health.super.init(self, x, y, i)

	self:changeState(tostring(math.floor(g.playerHP)))
end	


function Health:update()
	self:updateVisibility()

	if g.playerHP < g.playerMaxHP then
		self:show()
	end

	if self:isVisible() then
		if self.currentState ~= tostring(math.floor(g.playerHP)) then
			self:changeState(tostring(math.floor(g.playerHP)))
		end
	end
end