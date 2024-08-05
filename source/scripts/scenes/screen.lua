-- PlayDate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the TitleScene class
class("Screen").extends(gfx.sprite)

--- Initialise the screen class
--- @param  scene  string  The scene to use
function Screen:init(scene)
	self.scene = scene -- Save scene data locally

	-- Set image for the scene
	self:setImage(gfx.image.new("images/"..self.scene))
	self:moveTo(200, 120)
	self:add()
end

-- This method runs every frame when the screen is added to the sprite group
-- It listens for the A button press and moves over to the relevant scene
function Screen:update()
	if pd.buttonJustPressed(pd.kButtonA) then
		if self.scene == "title" then
			g:switchScene(World)
		else
			g:switchScene(Screen, "wipe", "title")
		end
	end
end