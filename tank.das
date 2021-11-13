
require daslib/media
require physObj


let G : float = 9.81
let gravityMult = 10.0

class Cannon
    angle: float2
    power: float
    pos: float2
    vertices: float2[4]

    width: float = 3.0
    height: float = 10.0

    def update()
        var angled = 1.0
        var test = normalize(pos - get_mouse_position())
        var dir = test//float2(cos(angled), sin(angled))
        var cross = float2(-dir.y, dir.x)
        print("x = {dir.x}\n")
        print("y = {dir.y}\n")
        normalize(dir)
        vertices[0] = pos + dir * height + cross * -width
        vertices[1] = pos + dir * height + cross * width
        vertices[2] = pos + dir * -height + cross * width
        vertices[3] = pos + dir * -height + cross * -width

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
    onGround : bool
    isTurn : bool = true
    speed : float = 250.0
    dir : float2
    norm : float2
    vertices: float2[4]

    def setGrounded(v: bool)
        onGround = v

    def Tank(pos: float2; size: float2)
        hitBox = new Box(pos, size)
        cannon = new Cannon()
        phase = Phase IDLE
        onGround = false

    def setPosition(_pos: float2)
        hitBox.pos = _pos

    def update(dt:float)
        if (length_sq(norm) <= 0.001)
            norm = float2(1.0, 0.0)
        if (length_sq(dir) <= 0.001)
            norm = float2(0.0, 1.0)
        if (!onGround)
            hitBox.pos += float2(0.0, G * dt * gravityMult)
        else
            if(get_key(VK_A))
                hitBox.pos += float2(-dir.x, dir.y) * speed * dt
            if(get_key(VK_D))
                hitBox.pos += float2(dir.x, dir.y) * speed * dt

        var cannonPos = hitBox.pos
        cannonPos.y -= (hitBox.height * 0.5) 
        cannon->updatePos(cannonPos)
        cannon->update()

        //var test = normalize(pos - get_mouse_position())
        var dirT = norm//float2(cos(angled), sin(angled))
        var cross = float2(-dirT.y, dirT.x)
        print("x = {dir.x}\n")
        print("y = {dir.y}\n")
        normalize(dir)
        vertices[0] = dirT *  hitBox.height +  cross * -hitBox.width
        vertices[1] = dirT *  hitBox.height +  cross *  hitBox.width
        vertices[2] = dirT * -hitBox.height + cross *   hitBox.width
        vertices[3] = dirT * -hitBox.height + cross * - hitBox.width

        vertices[0] += float2(hitBox.pos.x, hitBox.pos.y)
        vertices[1] += float2(hitBox.pos.x, hitBox.pos.y)
        vertices[2] += float2(hitBox.pos.x, hitBox.pos.y)
        vertices[3] += float2(hitBox.pos.x, hitBox.pos.y)

    def draw()
        //todo create mesh
        cannon->draw()
        var left = hitBox.pos.x - hitBox.width * 0.5
        var top = hitBox.pos.y - hitBox.height * 0.5
        //fill_rect(left, top, hitBox.width, hitBox.height, make_color(1.0, 1.0, 0.0, 1.0))
        fill_convex_polygon(vertices,  make_color(1.0, 1.0, 0.0, 1.0))
        line(hitBox.pos.x, hitBox.pos.y, hitBox.pos.x + norm.x * 50.0, hitBox.pos.y + norm.y * 50.0, 0xFFFFFFFF)
        line(hitBox.pos.x, hitBox.pos.y, hitBox.pos.x + dir.x * 50.0, hitBox.pos.y + dir.y * 50.0, 0x0000FFF)