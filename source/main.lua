-- PlayDate Core Libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries from GitHub
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"
import "scripts/libraries/GameManager"

-- Scenes
import "scripts/scenes/World"
import "scripts/scenes/Title"
import "scripts/scenes/Win"

-- Scripts
import "scripts/Player"
import "scripts/Spike"
import "scripts/Spikeball"
import "scripts/Door"
import "scripts/Flag"
import "scripts/Prop"
import "scripts/Animal"
import "scripts/Hitbox"
import "scripts/Crown"

-- PlayDate Constants & Globals
local pd <const> = playdate
local gfx <const> = playdate.graphics
gm = Game()

-- Create Title Screen
Win()

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