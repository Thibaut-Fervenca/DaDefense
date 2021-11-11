require daslib/media
require button
require tank

class Scene
    sceneType: int = 0
    buttonMgr: ButtonMgr?
    tankMgr: TankMgr?


    def Scene()
        buttonMgr = new ButtonMgr()
        tankMgr = new TankMgr()

    def draw()
        if (buttonMgr != null)
            buttonMgr->draw()
            tankMgr->draw()

    def update(dt:float)
        buttonMgr->update(dt)
        tankMgr->update(dt)