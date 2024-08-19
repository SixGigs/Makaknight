--------------------------------
-- Working title; Makaknight  --
--------------------------------
-- Programming standards:     --
-- > Use double quotes        --
-- > Variables are camel case --
--------------------------------

-- Playdate Core Libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries from GitHub
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/Game"
import "scripts/libraries/LDtk"

-- Scripts
import "scripts/Ability"
import "scripts/Animal"
import "scripts/Bar"
import "scripts/Hitbox"
import "scripts/Player"
import "scripts/Prop"

-- Animal scripts
import "scripts/animals/Butterfly"
import "scripts/animals/Reptile"

-- Entity scripts
import "scripts/entities/Bubble"
import "scripts/entities/Crown"
import "scripts/entities/Wind"
import "scripts/entities/Door"
import "scripts/entities/Flag"
import "scripts/entities/Fragileblock"

-- Hazard scripts
import "scripts/hazards/Fan"
import "scripts/hazards/Fire"
import "scripts/hazards/Firebox"
import "scripts/hazards/Spike"
import "scripts/hazards/Spikeball"

-- Scene scripts
import "scripts/scenes/Screen"
import "scripts/scenes/World"



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