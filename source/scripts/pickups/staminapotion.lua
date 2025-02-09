class('Staminapotion').extends(Potion)



--- Initialise the pickup object using the data given
--- @param  x  integer  The X coordinate to spawn the ability pick-up
--- @param  y  integer  The Y coordinate to spawn the ability pick-up
--- @param  e  object   The table of entities related to the ability
function Staminapotion:init(x, y, e)
	Staminapotion.super.init(self, x, y, e)

	-- Animation settings
	self:addState(0, 1, 5, {ts = 3})
	self:playAnimation()
end