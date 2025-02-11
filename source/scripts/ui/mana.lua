local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Mana').extends(Bar)


function Mana:init(x, y)
	local i <const> = gfx.imagetable.new('images/ui/mana-table-122-16')
	Mana.super.init(self, x, y, i)

	self:changeState(tostring(math.floor(g.playerMP)))
end	


function Mana:update()
	self:updateVisibility()

	if g.playerMP < g.playerMaxMP then
		self:show()
	end

	if self:isVisible() then
		if self.currentState ~= tostring(math.floor(g.playerMP)) then
			self:changeState(tostring(math.floor(g.playerMP)))
		end
	end
end