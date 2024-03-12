-- Creating the playdate graphics module as a constant
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Create the hit box class
class('Hitbox').extends(gfx.sprite)

--- Initialise the hit box object using the data given
--- @param x integer The X coordinate of the hit box (0 < x <= 400)
--- @param y integer The Y coordinate of the hit box (0 < y <= 240)
--- @param width integer The width of the hit box
--- @param height integer The height of the hit box
--- @param duration integer The duration of the hit box in milliseconds
function Hitbox:init(x, y, width, height, duration)	
	-- Set hit box properties
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.duration = duration
	self.active = true
	
	-- Create the hit box sprite
	self.hitboxSprite = gfx.sprite.new()
	self.hitboxSprite:setCollideRect(x, y, width, height)
	self.hitboxSprite:setTag(TAGS.Hitbox)
	self.hitboxSprite:setZIndex(Z_INDEXES.Hitbox)
	self.hitboxSprite:add()
	
	-- Start a timer to deactivate the hit box after the specified duration
	pd.timer.performAfterDelay(duration, function()
		self:deactivate()
	end)
end

--- Deactivate the hit box
function Hitbox:deactivate()
	self.active = false
	self.hitboxSprite:remove()
end

--- Check if the hit box is active
function Hitbox:isActive()
	return self.active
end