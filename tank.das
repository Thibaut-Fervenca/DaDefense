
require daslib/media
require physObj


class Cannon
    angle: float2
    power: float
    pos: float2
    vertices: float2[4]

    width: float = 10.0
    height: float = 260.0

    def update()
        var angled = 1.0
        var dir = float2(cos(angled), sin(angled))
        print("x = {dir.x}\n")
        print("y = {dir.y}\n")
        normalize(dir)
        vertices[0] = float2(pos.x + dir.x * width, pos.y + dir.y * height)
        vertices[1] = pos + dir * float2(-width, height)
        vertices[2] = pos + dir * float2(-width, -height)
        vertices[3] = pos + dir * float2(width, -height)

    def draw()
        //todo create mesh
        fill_convex_polygon(vertices, make_color(1.0))

    def updatePos(v: float2)
        pos = v;

enum Phase
    MOVING
    AIMING
    POWERING
    IDLE



class TankMgr
    tanks: array<Tank?>

    def addTank(var t: Tank?)
        push(tanks, t)

    def update(dt:float)
        for t in tanks
            t->update(dt)

    def draw()
        for t in tanks
            t->draw()



class Tank
    isPlayer: bool = true
    health: int = 500
    hitBox: Box?
    phase : Phase = Phase IDLE
    cannon : Cannon?



    def Tank(pos: float2; size: float2)
        hitBox = new Box(pos, size)
        cannon = new Cannon()
        cannon.pos = hitBox.pos + float2(0.0, hitBox.height * 0.5)
        phase = Phase IDLE

    def setPosition(_pos: float2)
        hitBox.pos = _pos

    def update(dt:float)
        var test = hitBox.pos
        cannon->updatePos(test)
        cannon->update()

    def draw()
        //todo create mesh
        cannon->draw()
        var left = hitBox.pos.x - hitBox.width * 0.5
        var top = hitBox.pos.y - hitBox.height * 0.5
        fill_rect(left, top, hitBox.width, hitBox.height, make_color(1.0, 1.0, 0.0, 1.0))