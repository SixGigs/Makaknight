-- Creating the Playdate Graphics Module as a Constant
local gfx <const> = playdate.graphics

-- Create the Roaster Class
class("Roaster").extends(AnimatedSprite)


--- Initialise the Roaster Entity
--- @param  x  integer  The X coordinate to spawn the Roaster
--- @param  y  integer  The Y coordinate to spawn the Roaster
--- @param  e  table    The entity that come with the Roaster
function Roaster:init(x, y, e)
	-- Local Variables for Initialisation
	local fillTicks <const> = 1.5
	local fillLoops <const> = e.fields.refill * 2
	local burnTicks <const> = e.fields.fuel * 30 / 16
	local fireTimer <const> = e.fields.fuel
	local fireDamage <const> = e.fields.damage
	
	-- Initialise the Fire Box Class
	Roaster.super.init(self, gfx.imagetable.new("images/hazards/roaster-table-32-16"))

	-- Fire Box Animation Settings
	self:addState("ready", 1, 1)
	self:addState("primed", 2, 2)
	self:addState("ignite", 3, 4, {ts = 2, l = 1, na = "burn"})
	self:addState("burn", 5, 21, {ts = burnTicks, l = 1, na = "refill"})
	self:addState("refill", 22, 32, {ts = fillTicks, l = fillLoops, na = "ready"})
	self:playAnimation()

	-- Fire Box Attributes
	self.fuse = 0

	-- Fire Box Properties
	self:setCollideRect(0, 17, 16, 15)
	self:setCenter(0, 0.5)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Roaster)
	self:setTag(TAGS.Roaster)
	self:add()

	-- Fire Box Animation End Events
	self.states["ignite"].onAnimationEndEvent = function(self) Fire(self.x, self.y - 16, fireTimer, fireDamage) end -- Create a Fire Object When the Fire Box Ignites
	self.states["refill"].onAnimationEndEvent = function(self) self:setCollideRect(0, 17, 16, 15) end -- Update the Fire Box Hit Box when Ready to Activate Again
end


--- The Update Method Updates the Roaster Every Tick
function Roaster:update()
	-- Update the Fire Box Animation
	self:updateAnimation()

	-- If the Fire Box Trap is Primed, Check the Count Down to Ignition
	if self.currentState == "primed" then
		-- Count the Fuse Down Every Game Tick
		if self.fuse >= 1 then
			self.fuse = self.fuse - 1
		end
	
		-- If
		if self.fuse == 0 then
			self:ignite()
		end
	end
end


function Roaster:handleCollision()
	if self.currentState == "ready" then
		self:prime()
	elseif self.currentState == "primed" then
		self:pressed()
	end
end


function Roaster:prime()
	self:changeState("primed")
	self.fuse = 4
end


function Roaster:pressed()
	self.fuse = 4
end


function Roaster:ignite()
	self:setCollideRect(0, 16, 16, 16)
	self:changeState("ignite")
end