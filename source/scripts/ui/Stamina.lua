local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Stamina').extends(Bar)


function Stamina:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/stamina-table-122-16')
	Stamina.super.init(self, x, y, i)

	self:changeState(tostring(math.floor(g.playerSP)))
end	


function Stamina:update()
	self:updateVisibility()

	if g.playerSP < (g.playerMaxSP / 3) then
		self:show()
	end

	if self:isVisible() then
		if self.currentState ~= tostring(math.floor(g.playerSP)) then
			self:changeState(tostring(math.floor(g.playerSP)))		
		end
	end
end