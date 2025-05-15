local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Text').extends(gfx.sprite)



function Text:init(text, x, y)
	self.text = text
	self.font = gfx.font.new('fonts/StarlightBlasphemy')
	self.xPadding = 24
	self.yPadding = 2
	self.width = self.font:getTextWidth(self.text) + self.xPadding
	self.height = self.font:getHeight()

	if x == 'center' then
		x = (SCREEN['width'] / 2) - (self.width / 2)
	elseif x == 'right' then
		x = SCREEN['width'] - self.width
	end

	gfx.setFont(self.font)
	pd.timer.performAfterDelay(3000, function()
		self:remove()
	end)

	self:setCenter(0, 0)
	self:setSize(self.width, self.height)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Text)
	self:setTag(TAGS.Text)
	self:add()
end



function Text:draw()
	gfx.pushContext()

	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, self.width, self.height)
	gfx.drawTextInRect(
		self.text,
		self.xPadding / 2,
		self.yPadding,
		self.width,
		self.height
	)

	gfx.popContext()
end