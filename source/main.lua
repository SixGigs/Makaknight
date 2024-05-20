-- PlayDate Core Libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries from GitHub
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"
import "scripts/libraries/SceneManager" -- Takes a long time to load, why!?

-- Scenes
import "scripts/scenes/Game"
import "scripts/scenes/Title"

-- Scripts
import "scripts/Player"
import "scripts/Spike"
import "scripts/Spikeball"
import "scripts/Door"
import "scripts/Flag"
import "scripts/Prop"
import "scripts/Animal"
import "scripts/Hitbox"

-- PlayDate Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- PlayDate Globals
sm = SceneManager()

-- Create Title Screen
Title()

-- Set Playdate Refresh Rate
pd.display.setRefreshRate(30)

-- Main Game Loop
function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
	pd.drawFPS(383, 2)
end

-- function pd.gameWillTerminate() g:save() end
-- function pd.deviceWillSleep() g:save() end