local pd <const> = playdate
local gfx <const> = playdate.gfx
class('Healthpotion').extends(Potion)



function Healthpotion:init(x, y, ...)
	local i <const> = 'healthpotion-table-16-16'
	local e <const> = ...
	
	Healthpotion.super.init(self, x, y, i, e)
end