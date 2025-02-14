local pd <const> = playdate
local gfx <const> = playdate.graphics
class('Text').extends(gfx.sprite)



function Text:init(text, x, y)
	self.text = text
	self.font = gfx.font.new('fonts/StarlightBlasphemy')

	gfx.setFont(self.font)
	pd.timer.performAfterDelay(3000, function()
		self:remove()
	end)

	self:setCenter(0, 0)
	self:setSize(128, 20)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Text)
	self:setTag(TAGS.Text)
	self:add()
end



function Text:draw()
	gfx.pushContext()

	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 128, 20)
	gfx.drawTextInRect(self.text, 4, 1, 128, 40)

	gfx.popContext()
end