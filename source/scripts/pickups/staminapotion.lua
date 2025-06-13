local pd <const> = playdate
local gfx <const> = playdate.gfx
class('Staminapotion').extends(Potion)



function Staminapotion:init(x, y, ...)
	local i <const> = 'staminapotion-table-16-16'
	local e <const> = ...

	Staminapotion.super.init(self, x, y, i, e)
end