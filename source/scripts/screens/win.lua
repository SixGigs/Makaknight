class('Win').extends(Screen)
function Win:init()
	Win.super.init(self, 'win')
	self.nextScene = Credits
end