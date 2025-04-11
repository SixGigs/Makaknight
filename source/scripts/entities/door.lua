local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Door').extends(gfx.sprite)


--- Initialise the door object using the data given
--- @param  x  integer  The X coordinate to spawn the door
--- @param  y  integer  The Y coordinate to spawn the door
--- @param  e  table    The table of entity attributes in the door
function Door:init(x, y, e)
	-- Use entity attribute 'doorSprite' to load the correct sprite
	local i <const> = gfx.image.new('images/doors/' .. e.name)

	-- The level & door IID to travel to
	self.level = e.fields.links['levelIid']
	self.exit = e.fields.links['entityIid']

	-- Sprite properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Door)
	self:setTag(TAGS.Door)
	self:setCollideRect(12, 32, 8, 16)
	self:setImage(i)
	self:add()
end


--- Used when the player collides with the door
--- @param  player  table  The player object
function Door:handleCollision(player)
	if pd.buttonJustPressed(pd.kButtonUp) then
		player.xVelocity = 0
		player.yVelocity = 0
		player:changeState('entering')
		player.world:enterDoor(self)
	end
end