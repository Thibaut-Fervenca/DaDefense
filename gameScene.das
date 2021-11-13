require daslib/media
require scene
require button
require tank

class GameScene : Scene

    def GameScene()
        Scene`Scene(self)
        init()

    def init()
        var size = float2(float(get_screen_width()) * 0.05, float(get_screen_width()) * 0.05)
        var position = float2(float(get_screen_width()) - size.x * 0.5, size.y * 0.5)

        var buttonPlay = new Button(position, size, 0xFFFFFFFF)
        buttonPlay.text = "RESET"
        buttonMgr->addButtons(buttonPlay)

        position.y -= 100.0
        position.x = 200.0
        size.x = 30.0
        size.y = 10.0
        //var newTank = new Tank(position, size)
        //tankMgr->addTank(newTank)

