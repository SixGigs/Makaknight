local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Bar').extends(AnimatedSprite)



--- Status bars are created using this method
--- @param  x  integer  The X coordinate to spawn the status bar
--- @param  y  integer  The Y coordinate to spawn the status bar
function Bar:init(name, x, y)
	-- Initialise the state machine using a bar sprite sheet
	local i <const> = gfx.imagetable.new('images/ui/' .. name .. '-table-122-16')
	Bar.super.init(self, i)

	-- Set all bar states with a for loop (makes states '100' -> '0')
	for i = 100, 0, -1 do
		local s <const> = tostring(i)
		self:addState(s, 1 + i, 1 + i)
	end
	self:playAnimation()

	-- Bar properties
	self.name = name
	self.timerMax = 120
	self.timer = 0
	self.lockTimerMax = 30
	self.lockTimer = 0

	-- Set bar states
	if name == 'health' then
		self:changeState(tostring(math.floor(GAME.playerHP)))
		self.lastStateValue = math.floor(GAME.playerHP)
	elseif name == 'stamina' then
		self:changeState(tostring(math.floor(GAME.playerSP)))
		self.lastStateValue = math.floor(GAME.playerSP)
	else
		self:changeState(tostring(math.floor(GAME.playerMP)))
		self.lastStateValue = math.floor(GAME.playerMP)
	end

	self:setVisible(false)
	self:setCollideRect(0, 0, self.width, self.height)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Gui)
	self:setTag(TAGS.Gui)
	self:add()
end



--- This method is run every frame when a bar is on the screen
function Bar:update()	
	self:updateVisibility()

	if not self:isVisible() then
		local visible = false

		if self.name == 'health' then
			local val = GAME.playerHP
			visible = val < self.lastStateValue or val > self.lastStateValue + 5
		elseif self.name == 'stamina' then
			local val = GAME.playerSP
			visible = val < (GAME.playerMaxSP / 2) or val > self.lastStateValue + 5
		else
			local val = GAME.playerMP
			visible = (val < self.lastStateValue and val < (GAME.playerMaxMP / 2)) or val > self.lastStateValue + 5
		end

		if visible then self:show() end
	end

	if self:isVisible() then
		local newValue

		if self.name == 'health' then
			newValue = math.floor(GAME.playerHP)
		elseif self.name == 'stamina' then
			newValue = math.floor(GAME.playerSP)
		else
			newValue = math.floor(GAME.playerMP)
		end

		if newValue ~= self.lastStateValue then
			self.lastStateValue = newValue
			self:changeState(tostring(newValue))
		end
	end
end




function Bar:handleCollision()
	self.lockTimer = self.lockTimerMax
	self.timer = 0
	self:setVisible(false)
end




function Bar:show()
	if self.lockTimer > 0 then
		return
	end

	self.timer = self.timerMax
	self:setVisible(true)
end




function Bar:updateVisibility()
	if self:isVisible() then
		if self.timer > 0 then
			self.timer = self.timer - 30 * DELTA_TIME
		else
			self:setVisible(false)
		end
	else
		if self.lockTimer > 0 then
			self.lockTimer = self.lockTimer - 30 * DELTA_TIME
		end
	end
end