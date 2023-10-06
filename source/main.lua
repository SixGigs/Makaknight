-- PlayDate Core Libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- GitHub Libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"

-- Scripts
import "scripts/GameScene"
import "scripts/Player"

GameScene()

-- PlayDate Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Main Game Loop
function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
end