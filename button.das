require daslib/media
require physObj
require colorUtils

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


    def Button(_pos : float2; _size : float2; _color: uint)
        color = multColor(_color, defaultBrightness)
        defaultColor = _color
        box = new Box(_pos, _size)
        defaultScale = _size
        maxScale = _size * 1.25

    def onMouseOver()
        if (!isOvered)
            isOvered = true

    def onMouseOut()
        if (isOvered)
            isOvered = false

    def onMouseLeftDown()
        if (isOvered)
            isOvered = false

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
        isOvered = false

    def draw()
        var left = box.pos.x - box.width * 0.5
        var top = box.pos.y - box.height * 0.5
        fill_rect(left, top, box.width, box.height, color)
        set_font_name("Aqum.ttf")
        set_font_size(15)
        text_out(box.pos.x, box.pos.y, text, make_color(0.0))

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