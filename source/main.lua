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
import "scripts/Ability"
import "scripts/Checkpoint"

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

-- Main Game Loop
function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
end