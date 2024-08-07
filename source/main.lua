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
import "scripts/Ability"
import "scripts/Animal"
import "scripts/Bar"
import "scripts/Bubble"
import "scripts/Crown"
import "scripts/Door"
import "scripts/Flag"
import "scripts/Hitbox"
import "scripts/Player"
import "scripts/Prop"
import "scripts/Spike"
import "scripts/Spikeball"

-- Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Globals
g = Game()
dt = 0

--Screen("title") -- Create Title Screen
World()

-- Main Game Loop
function pd.update()
	dt = playdate.getElapsedTime()
	playdate.resetElapsedTime()
	gfx.sprite.update()
	pd.timer.updateTimers()
	pd.drawFPS(383, 2)
end