-- Creating the Playdate Graphics Module as a Constant
local gfx <const> = playdate.graphics

-- Create the Firebox Class
class("Firebox").extends(AnimatedSprite)


--- Initialise the Fire Box Entity Using the Data Given
--- @param  x  integer  The X coordinate to spawn the Fire Box
--- @param  y  integer  The Y coordinate to spawn the Fire Box
--- @param  e  table    The entity that come with the Fire Box
function Firebox:init(x, y, e)
	-- Local Variables for Initialisation
	local fillTicks <const> = 1.5
	local fillLoops <const> = e.fields.refill * 2
	local burnTicks <const> = e.fields.fuel * 30 / 16
	local burnTimer <const> = e.fields.fuel
	
	-- Initialise the Fire Box Class
	Firebox.super.init(self, gfx.imagetable.new("images/hazards/fire-box-table-32-16"))

	-- Fire Box Animation Settings
	self:addState("ready", 1, 1)
	self:addState("primed", 2, 2)
	self:addState("ignite", 3, 4, {ts = 2, l = 1, na = "burn"})
	self:addState("burn", 5, 21, {ts = burnTicks, l = 1, na = "refill"})
	self:addState("refill", 22, 32, {ts = fillTicks, l = fillLoops, na = "ready"})
	self:playAnimation()

	-- Fire Box Animation End Events
	self.states["ignite"].onAnimationEndEvent = function(self) Fire(x, y - 16, burnTimer) end -- Create a Fire Object When the Fire Box Ignites
	self.states["refill"].onAnimationEndEvent = function(self) self:setCollideRect(0, 17, 16, 15) end -- Update the Fire Box Hit Box when Ready to Activate Again

	-- Fire Box Attributes
	self.fuse = 0

	-- Fire Box Properties
	self:setCollideRect(0, 17, 16, 15)
	self:setCenter(0, 0.5)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Firebox)
	self:setTag(TAGS.Firebox)
	self:add()
end


--- The Update Method Updates the Fire Box Every Tick
function Firebox:update()
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


function Firebox:handleCollision()
	if self.currentState == "ready" then
		self:prime()
	elseif self.currentState == "primed" then
		self:pressed()
	end
end


function Firebox:prime()
	self:changeState("primed")
	self.fuse = 4
end


function Firebox:pressed()
	self.fuse = 4
end


function Firebox:ignite()
	self:setCollideRect(0, 16, 16, 16)
	self:changeState("ignite")
end