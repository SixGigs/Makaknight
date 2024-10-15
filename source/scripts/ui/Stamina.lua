local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Stamina').extends(Bar)


function Stamina:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/stamina-table-122-16')
	Stamina.super.init(self, x, y, i)

	self:changeState(tostring(math.floor(g.player_sp)))
end	


function Stamina:update()
	self:updateVisibility()
	if self.currentState ~= tostring(math.floor(g.player_sp)) then
		if math.floor(g.player_sp) < tonumber(self.currentState) then			
			self.timer = self.timerMax
			self:setVisible(true)
		end

		self:changeState(tostring(math.floor(g.player_sp)))		
	end
end