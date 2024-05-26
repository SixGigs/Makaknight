-- PlayDate Core Libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries from GitHub
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/Game"
import "scripts/libraries/LDtk"

-- Scenes
import "scripts/scenes/Screen"
import "scripts/scenes/World"

-- Scripts
import "scripts/Animal"
import "scripts/Crown"
import "scripts/Door"
import "scripts/Flag"
import "scripts/Hitbox"
import "scripts/Player"
import "scripts/Prop"
import "scripts/Spike"
import "scripts/Spikeball"

-- PlayDate Constants & Globals
local pd <const> = playdate
local gfx <const> = playdate.graphics
gm = Game()

-- Create Title Screen
Screen("title")


-- Set Playdate Refresh Rate
pd.display.setRefreshRate(30)

-- Main Game Loop
function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
	pd.drawFPS(383, 2)
end