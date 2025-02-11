class('Thanks').extends(Screen)
function Thanks:init()
	Thanks.super.init(self, 'thanks')

	self.nextScene = Title
	self.transition = 'fade'
end