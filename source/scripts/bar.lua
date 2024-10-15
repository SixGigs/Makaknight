-- Playdate shorthand constants
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create the bar class
class('Bar').extends(AnimatedSprite)


--- Status bars are created using this method
--- @param  x  integer  The X coordinate to spawn the status bar
--- @param  y  integer  The Y coordinate to spawn the status bar
function Bar:init(x, y, i)
	-- Initialise the state machine using a bar sprite sheet
	Bar.super.init(self, i)

	-- Set all bar states in the state machine
	self:addState('100', 101, 101)
	self:addState('99', 100, 100)
	self:addState('98', 99, 99)
	self:addState('97', 98, 98)
	self:addState('96', 97, 97)
	self:addState('95', 96, 96)
	self:addState('94', 95, 95)
	self:addState('93', 94, 94)
	self:addState('92', 93, 93)
	self:addState('91', 92, 92)
	self:addState('90', 91, 91)
	self:addState('89', 90, 90)
	self:addState('88', 89, 89)
	self:addState('87', 88, 88)
	self:addState('86', 87, 87)
	self:addState('85', 86, 86)
	self:addState('84', 85, 85)
	self:addState('83', 84, 84)
	self:addState('82', 83, 83)
	self:addState('81', 82, 82)
	self:addState('80', 81, 81)
	self:addState('79', 80, 80)
	self:addState('78', 79, 79)
	self:addState('77', 78, 78)
	self:addState('76', 77, 77)
	self:addState('75', 76, 76)
	self:addState('74', 75, 75)
	self:addState('73', 74, 74)
	self:addState('72', 73, 73)
	self:addState('71', 72, 72)
	self:addState('70', 71, 71)
	self:addState('69', 70, 70)
	self:addState('68', 69, 69)
	self:addState('67', 68, 68)
	self:addState('66', 67, 67)
	self:addState('65', 66, 66)
	self:addState('64', 65, 65)
	self:addState('63', 64, 64)
	self:addState('62', 63, 63)
	self:addState('61', 62, 62)
	self:addState('60', 61, 61)
	self:addState('59', 60, 60)
	self:addState('58', 59, 59)
	self:addState('57', 58, 58)
	self:addState('56', 57, 57)
	self:addState('55', 56, 56)
	self:addState('54', 55, 55)
	self:addState('53', 54, 54)
	self:addState('52', 53, 53)
	self:addState('51', 52, 52)
	self:addState('50', 51, 51)
	self:addState('49', 50, 50)
	self:addState('48', 49, 49)
	self:addState('47', 48, 48)
	self:addState('46', 47, 47)
	self:addState('45', 46, 46)
	self:addState('44', 45, 45)
	self:addState('43', 44, 44)
	self:addState('42', 43, 43)
	self:addState('41', 42, 42)
	self:addState('40', 41, 41)
	self:addState('39', 40, 40)
	self:addState('38', 39, 39)
	self:addState('37', 38, 38)
	self:addState('36', 37, 37)
	self:addState('35', 36, 36)
	self:addState('34', 35, 35)
	self:addState('33', 34, 34)
	self:addState('32', 33, 33)
	self:addState('31', 32, 32)
	self:addState('30', 31, 31)
	self:addState('29', 30, 30)
	self:addState('28', 29, 29)
	self:addState('27', 28, 28)
	self:addState('26', 27, 27)
	self:addState('25', 26, 26)
	self:addState('24', 25, 25)
	self:addState('23', 24, 24)
	self:addState('22', 23, 23)
	self:addState('21', 22, 22)
	self:addState('20', 21, 21)
	self:addState('19', 20, 20)
	self:addState('18', 19, 19)
	self:addState('17', 18, 18)
	self:addState('16', 17, 17)
	self:addState('15', 16, 16)
	self:addState('14', 15, 15)
	self:addState('13', 14, 14)
	self:addState('12', 13, 13)
	self:addState('11', 12, 12)
	self:addState('10', 11, 11)
	self:addState('9', 10, 10)
	self:addState('8', 9, 9)
	self:addState('7', 8, 8)
	self:addState('6', 7, 7)
	self:addState('5', 6, 6)
	self:addState('4', 5, 5)
	self:addState('3', 4, 4)
	self:addState('2', 3, 3)
	self:addState('1', 2, 2)
	self:addState('0', 1, 1)
	self:playAnimation()

	-- Bar attributes
	self.timerMax = 90
	self.timer = 60

	-- Bar properties
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.GUI)
	self:setTag(TAGS.GUI)
	self:add()
end


function Bar:updateVisibility()
	if self:isVisible() and self.timer > 1 then
		self.timer = self.timer - 30 * dt
	else
		self:setVisible(false)
	end
end