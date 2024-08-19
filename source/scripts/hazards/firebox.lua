-- Creating the Playdate Graphics Module as a Constant
local gfx <const> = playdate.graphics

-- Create the Firebox Class
class("Firebox").extends(AnimatedSprite)


--- Initialise the Fan Object Using the Data Given
--- @param  x  integer  The X coordinate to spawn the Fan
--- @param  y  integer  The Y coordinate to spawn the Fan
--- @param  e  table    The entity that come with the Fan
function Firebox:init(x, y, e)
	-- Initialise the Fan Class
	Firebox.super.init(self, gfx.imagetable.new("images/hazards/fire-box-table-32-16"))

	-- Fire Box Animation Settings
	self:addState("ready", 1, 1)
	self:addState("primed", 2, 2, {ts = 2, l = 1, na = "ignite"})
	self:addState("ignite", 3, 4, {ts = 2, l = 1, na = "burn"})
	self:addState("burn", 5, 21, {ts = 4, l = 1, na = "refill"})
	self:addState("refill", 22, 32, {ts = 1, l = 8, na = "ready"})
	self:playAnimation()
	
	-- Create a Fire Object When the Fire Box Ignites
	self.states["ignite"].onAnimationEndEvent = function(self)
		Fire(x, y - 16)
	end

	-- Fire Box Properties
	self:setCollideRect(0, 16, 16, 16)
	self:setCenter(0, 0.5)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Firebox)
	self:setTag(TAGS.Firebox)
	self:add()
end


function Firebox:prime()
	if self.currentState == "ready" then
		self:changeState("primed")
	end
end


function Firebox:update()
	self:updateAnimation()

	local collisions = self:allOverlappingSprites()
	for i = 1, #collisions do
		local collision <const> = collisions[i]
		local collisionType <const> = collision.type
		if collision.className == "Player" then
			print("bruh")
		end
	end
end