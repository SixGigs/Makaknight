-- PlayDate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the TitleScene class
class("Screen").extends(gfx.sprite)

--- Initialise the screen class
--- @param  scene  string  The scene to use
function Screen:init(scene)
	self.scene = scene -- Save scene data locally
	self.transition = 'wipe'

	-- Set image for the scene
	self:setImage(gfx.image.new("images/screens/"..self.scene))
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:add()
end


function Screen:update()
	self:handleInput()
	self:handleMovement()
end


function Screen:handleInput()
	if pd.buttonJustPressed(pd.kButtonA) then
		g:switchScene(self.nextScene, self.transition)
	end
end


function Screen:handleMovement() end