require daslib/media
require scene
require button
require tank

class Menu : Scene

    def Menu()
        Scene`Scene(self)
        init()

    def init()
        var position = float2(float(get_screen_width()) * 0.5, float(get_screen_height()) * 0.5)
        var size = float2(float(get_screen_width()) * 0.3, float(get_screen_width()) * 0.1)

        var buttonPlay = new Button(position, size, 0xFFFFFFFF)
        buttonMgr->addButtons(buttonPlay)

        position.y -= 100.0
        var newTank = new Tank(position, size)
        tankMgr->addTank(newTank)

