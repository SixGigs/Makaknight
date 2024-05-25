-- PlayDate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the TitleScene class
class("Win").extends(gfx.sprite)

-- Load the title scene
function Win:init()
	self:setImage(gfx.image.new("images/win"))
	self:moveTo(200, 120)
	self:add()
end

-- This method runs every frame when the title scene is added to the sprite group
-- It listens for the A button press and moves over to the game scene
function Win:update()
	if pd.buttonJustPressed(pd.kButtonA) then
		gm:switchScene(Title, "wipe")
	end
end