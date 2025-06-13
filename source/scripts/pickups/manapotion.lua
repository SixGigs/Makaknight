local pd <const> = playdate
local gfx <const> = playdate.gfx
class('Manapotion').extends(Potion)



function Manapotion:init(x, y, ...)
	local i <const> = 'manapotion-table-16-16'
	local e <const> = ...

	Manapotion.super.init(self, x, y, i, e)
end