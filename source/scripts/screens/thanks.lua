class('Thanks').extends(Screen)
function Thanks:init()
	Thanks.super.init(self, 'thanks')
	self.nextScene = Title
end