local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Mana').extends(Bar)


function Mana:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/mana-table-122-16')
	Mana.super.init(self, x, y, i)

	self:changeState(tostring(math.floor(g.player_mp)))
end	


function Mana:update()
	self:updateVisibility()

	if g.player_mp < g.player_max_mp then
		self:show()
	end

	if self:isVisible() then
		if self.currentState ~= tostring(math.floor(g.player_mp)) then
			self:changeState(tostring(math.floor(g.player_mp)))
		end
	end
end