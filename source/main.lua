-- PlayDate Core Libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries from GitHub
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"

-- Scripts
import "scripts/GameScene"
import "scripts/Player"
import "scripts/Spike"
import "scripts/Spikeball"
import "scripts/Door"
import "scripts/Checkpoint"
import "scripts/Prop"

-- PlayDate Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics
local gs <const> = GameScene()

-- PlayDate Functions
function pd.gameWillTerminate()
	gs:saveGame()
end

function pd.deviceWillSleep()
	gs:saveGame()
end

-- Playdate Set Refresh Rate
pd.display.setRefreshRate(30)

-- Main Game Loop
function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
	pd.drawFPS(383, 2)
end