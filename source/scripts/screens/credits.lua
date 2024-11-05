local pd <const> = playdate
class('Credits').extends(Screen)



function Credits:init()
	Credits.super.init(self, 'credits')
	self.transition = 'fade'

	self.width, self.height = self:getSize()
	self.paused = false
	self.xVelocity = 0
	self.xCredits = 240
end


function Credits:handleInput()
	-- Input with & without pause
	if not self.paused then
		self.xVelocity = 15 * dt
	else
		self.xVelocity = 0
	end

	-- Crank input
	if not pd:isCrankDocked() then
		local _, speed = pd.getCrankChange()
		if speed then
			self.xVelocity = self.xVelocity + (speed * 32) * dt
		end
	end

	-- D-pad inputs
	if pd.buttonIsPressed(pd.kButtonUp) then
		if self.paused then
			self.xVelocity = self.xVelocity - 180 * dt
		else
			self.xVelocity = self.xVelocity - 195 * dt
		end
	elseif pd.buttonIsPressed(pd.kButtonDown) then
		if self.paused then
			self.xVelocity = self.xVelocity + 180 * dt
		else
			self.xVelocity = self.xVelocity + 165 * dt
		end
	end

	-- Button inputs
	if pd.buttonJustPressed(pd.kButtonA) then
		if self.paused then
			self.paused = false 
		else
			self.paused = true
		end
	elseif pd.buttonJustPressed(pd.kButtonB) then
		g:switchScene(Thanks, self.transition)
	end
end


function Credits:handleMovement()
	self.xCredits = math.max(240, math.min(self.xCredits + self.xVelocity, self.height))

	if self.xCredits == 240 then
		self:moveTo(0, 0)
	elseif self.xCredits == self.height then
		self:moveTo(0, -(self.height - 240))
	else
		self:moveBy(0, -self.xVelocity)
	end
end