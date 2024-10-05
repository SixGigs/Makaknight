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
import "scripts/Animal"
import "scripts/Background"
import "scripts/Hitbox"
import "scripts/Player"
import "scripts/Prop"
import "scripts/Screen"
import "scripts/World"

-- Animal scripts
import "scripts/animals/Butterfly"
import "scripts/animals/Reptile"

-- Entity scripts
import "scripts/entities/Ability"
import "scripts/entities/Bubble"
import "scripts/entities/Crown"
import "scripts/entities/Wind"
import "scripts/entities/Door"
import "scripts/entities/Flag"
import "scripts/entities/FragileBlock"

-- Hazard scripts
import "scripts/hazards/Fan"
import "scripts/hazards/Fire"
import "scripts/hazards/Roaster"
import "scripts/hazards/Spike"
import "scripts/hazards/Spikeball"

-- User interface scripts
import "scripts/ui/Bar"



-- Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Globals
g = Game()
screenWidth = pd.display.getWidth()
screenHeight = pd.display.getHeight()
dt = 0

-- Screen("title") -- Create Title Screen
World()


-- These Functions are Used to Save the Game When Finished
function pd.gameWillTerminate()
	g:save()
end

function pd.gameWillSleep()
	g:save()
end

-- Main Game Loop
function pd.update()
	dt = playdate.getElapsedTime()
	playdate.resetElapsedTime()
	gfx.sprite.update()
	pd.timer.updateTimers()
	pd.drawFPS(383, 2)
end