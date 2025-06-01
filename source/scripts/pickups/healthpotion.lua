local pd <const> = playdate
local gfx <const> = playdate.gfx
class('Healthpotion').extends(Potion)



function Healthpotion:init(x, y, ...)
	local i <const> = 'healthpotion-table-16-16'
	local e <const> = ...
	
	Healthpotion.super.init(self, x, y, i, e)
end



--- This method handles the health potion being picked up by an entity
--- @param  e  table  The entity colliding with the health potion
function Healthpotion:handleCollision(e)
	if not self:isVisible() then
		return
	end

	local collisionTag <const> = e:getTag()

	-- Collect the coin if the entity is a player
	if collisionTag == TAGS.Player then
		if not e.dead then
			if e.currentState ~= 'dash' and e.currentState ~= 'dive' then
				e.hp = e.maxHP

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