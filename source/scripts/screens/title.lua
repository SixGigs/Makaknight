class('Title').extends(Screen)
function Title:init()
	Title.super.init(self, 'title')
	self.nextScene = World
end