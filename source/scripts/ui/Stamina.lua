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

	if g.player_sp < (g.player_max_sp / 3) then
		self:show()
	end

	if self:isVisible() then
		if self.currentState ~= tostring(math.floor(g.player_sp)) then
			self:changeState(tostring(math.floor(g.player_sp)))		
		end
	end
end