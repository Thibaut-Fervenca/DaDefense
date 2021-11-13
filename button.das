require daslib/media
require physObj
require colorUtils

enum ButtonAction
    RESET
    QUIT

class Button
    box: Box?
    color: uint
    text: string = "Play"
    isOvered: bool = false
    defaultScale: float2
    maxScale: float2
    overTime: float = 0.0
    defaultBrightness: float = 0.5
    maxBrightness: float = 1.0
    defaultColor: uint
    fontDefaultScale: float
    maxFontScale: float
    actualFontScale:int
    buttonAction: ButtonAction = ButtonAction RESET
    clicked: bool = false


    def Button(_pos : float2; _size : float2; _color: uint)
        color = multColor(_color, defaultBrightness)
        defaultColor = _color
        box = new Box(_pos, _size)
        defaultScale = _size
        maxScale = _size * 1.25
        fontDefaultScale = 15.0
        maxFontScale = 20.0
        actualFontScale = 15
       

    def onMouseOver()
        if (!isOvered)
            isOvered = true

    def onMouseOut()
        if (isOvered)
            isOvered = false
            clicked = false

    def onMouseLeftDown()
        if (isOvered)
            clicked = true

    def onMouseLeftUp()
        if (isOvered)
            clicked = false

    def isOver() : bool
        return isOvered

    def update(dt : float)
        if (isOvered)
            overTime = min(overTime + dt * 3.0, 1.0)
        else
            overTime = max(overTime - dt * 3.0, 0.0)
        var newScale= lerp(defaultScale, maxScale, overTime)
        box->setScale(newScale)
        color = multColor(defaultColor, lerp(defaultBrightness, maxBrightness, overTime))
        actualFontScale = int(lerp(fontDefaultScale, maxFontScale, overTime))


    def draw()
        var left = box.pos.x - box.width * 0.5
        var top = box.pos.y - box.height * 0.5
        fill_rect(left, top, box.width, box.height, color)
        set_font_name("Aqum.ttf")
        set_font_size(actualFontScale)
        var sizeText = get_text_size(text)
        var posText = float2(box.pos.x - sizeText.x * 0.5, box.pos.y - sizeText.y * 0.5) 
        text_out(posText.x, posText.y, text, make_color(0.0))

class ButtonMgr
    buttons: array<Button?>

    def update(dt:float)
        var mousePos = get_mouse_position()
        for b in buttons
            if (colTest(b.box, mousePos))
                b->onMouseOver()
            else
                b->onMouseOut()
            b->update(dt)

    def addButtons(var b: Button?)
        push(buttons, b)

    def draw()
        for b in buttons
            b->draw()

    def onMouseLeftDown()
        for b in buttons
            b->onMouseLeftDown()
    
    def onMouseLeftUp()
        for b in buttons
            b->onMouseLeftUp()

    def finalize()
        clear(buttons)