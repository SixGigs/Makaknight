--------------------------------
-- Working title; Makaknight  --
--------------------------------
-- Programming standards:     --
-- > Use double quotes        --
-- > Variables are camel case --
--------------------------------

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
import 'scripts/animals/animal'
import 'scripts/animals/Butterfly'
import 'scripts/animals/Reptile'

-- Entity scripts
import 'scripts/entities/Ability'
import 'scripts/entities/Block'
import 'scripts/entities/Bubble'
import 'scripts/entities/Crown'
import 'scripts/entities/Hitbox'
import 'scripts/entities/Wind'
import 'scripts/entities/Door'
import 'scripts/entities/Half'
import 'scripts/entities/Flag'
import 'scripts/entities/Prop'

-- Hazard scripts
import 'scripts/hazards/Fan'
import 'scripts/hazards/Fire'
import 'scripts/hazards/Roaster'
import 'scripts/hazards/Spike'
import 'scripts/hazards/Spikeball'

-- Game screen scripts
import 'scripts/screens/Background'
import 'scripts/screens/fade'
import 'scripts/screens/screen'
import 'scripts/screens/credits'
import 'scripts/screens/title'
import 'scripts/screens/world'
import 'scripts/screens/win'
import 'scripts/screens/thanks'

-- User interface scripts
import 'scripts/ui/Bar'
import 'scripts/ui/Health'
import 'scripts/ui/Stamina'
import 'scripts/ui/Mana'

-- Constants
local pd <const> = playdate
local gfx <const> = playdate.graphics



-- Globals
g = Game()
screenWidth = pd.display.getWidth()
screenHeight = pd.display.getHeight()
dt = 0


Title()


-- Save the game when it closes
function pd.gameWillTerminate()
	g:save()
end

-- Save the game when the console goes to sleep
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