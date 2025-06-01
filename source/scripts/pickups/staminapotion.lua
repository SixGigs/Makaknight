local pd <const> = playdate
local gfx <const> = playdate.gfx
class('Staminapotion').extends(Potion)



function Staminapotion:init(x, y, ...)
	local i <const> = 'staminapotion-table-16-16'
	local e <const> = ...

	Staminapotion.super.init(self, x, y, i, e)
end



--- This method handles the stamina potion being picked up by an entity
--- @param  e  table  The entity colliding with the health potion
function Staminapotion:handleCollision(e)
	if not self:isVisible() then
		return
	end

	local collisionTag <const> = e:getTag()

	-- Collect the coin if the entity is a player
	if collisionTag == TAGS.Player then
		if not e.dead then
			if e.currentState ~= 'dash' and e.currentState ~= 'dive' then
				e.sp = e.maxSP

				Sparkle(self.x + 8, self.y + 8)

				if self.id then
					GAME.depletedEntities[self.id] = true
					self:setVisible(false)
				else
					self:remove()
				end
			end
		end
	end
end