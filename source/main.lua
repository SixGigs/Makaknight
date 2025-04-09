----------------------------------------
-- Working title; Makaknight          --
----------------------------------------
-- Programming standards:             --
-- > Strings use 'single quotes'      --
-- > Variable names use camelCase     --
-- > Class names use CapitalCase      --
-- > Method names use snake_case      --
-- > Global variables use ALL_CAPS    --
----------------------------------------

-- Playdate Core Libraries
import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

-- Libraries from GitHub
import 'scripts/libraries/AnimatedSprite'
import 'scripts/libraries/LDtk'

-- Scripts
import 'scripts/Game'
import 'scripts/Player'

-- Animal scripts
import 'scripts/animals/Animal'
import 'scripts/animals/Butterfly'
import 'scripts/animals/Firefly'
import 'scripts/animals/Reptile'

-- Entity scripts
import 'scripts/entities/Block'
import 'scripts/entities/Bubble'
import 'scripts/entities/Candle'
import 'scripts/entities/Crown'
import 'scripts/entities/Door'
import 'scripts/entities/Flag'
import 'scripts/entities/Half'
import 'scripts/entities/Hitbox'
import 'scripts/entities/Prop'
import 'scripts/entities/Wind'

-- Pickup scripts
import 'scripts/pickups/Potion'

-- Hazard scripts
import 'scripts/hazards/Fan'
import 'scripts/hazards/Fire'
import 'scripts/hazards/Roaster'
import 'scripts/hazards/Spike'
import 'scripts/hazards/Spikeball'

-- Game screen scripts
import 'scripts/screens/Background'
import 'scripts/screens/Screen'
import 'scripts/screens/Credits'
import 'scripts/screens/Title'
import 'scripts/screens/World'
import 'scripts/screens/Win'
import 'scripts/screens/Thanks'

-- Transitions
import 'scripts/transitions/Fade'
import 'scripts/transitions/Wipe'

-- User interface scripts
import 'scripts/ui/Bar'
import 'scripts/ui/Text'

-- Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Globals
DEBUG = true
GAME = Game()
DELTA_TIME = 0
SCREEN = {
	['width'] = pd.display.getWidth(),
	['height'] = pd.display.getHeight()
}

Title()



-- Save the game when it closes
function pd.gameWillTerminate()
	GAME:save()
end

-- Save the game when the console goes to sleep
function pd.gameWillSleep()
	GAME:save()
end



-- Main Game Loop
function pd.update()
	DELTA_TIME = playdate.getElapsedTime()
	playdate.resetElapsedTime()
	gfx.sprite.update()
	pd.timer.updateTimers()
	
	if DEBUG then
		pd.drawFPS(383, 2)
	end
end