require daslib/media
require physObj


class Player
    pos: float2
    speed: float
    vertices: float2[4]
    angle: float
    radius: float
    height: float = 50.0
    width: float = 20.0
    direction: float2

    def Player()
        speed = 3000.0
        radius = 50.0 // same as core
        angle = 0.0

    def update(dt: float)
        var center = float2(float(get_screen_width()) * 0.5,float(get_screen_height()) * 0.5)
        var mouse = get_mouse_position()
        var dir = float2(mouse.x - center.x, mouse.y - center.y)
        dir = normalize(float2(dir.x, dir.y))
        var norDir = float2(0.0, 1.0)
        var wishAngle = acos(dot(norDir, dir));
        var actualAngle = angle_move_to(angle, wishAngle, speed, dt)
        
        
        if (dir.x > 0.0)
            dir = float2(cos(-actualAngle), sin(-actualAngle))
        else
            dir = float2(cos(actualAngle), sin(actualAngle))
        var cross = float2(-dir.y, dir.x)
        pos = center + cross * radius
        vertices[0] = float2(pos.x + dir.x * width * 0.5, pos.y + dir.y * width * 0.5)
        vertices[1] = float2(pos.x - dir.x * width * 0.5, pos.y - dir.y * width * 0.5)
        vertices[2] = float2(pos.x + cross.x * height * 0.5 - dir.x * width * 0.5, pos.y + cross.y * height * 0.5 - dir.y * width * 0.5)
        vertices[3] = float2(pos.x + cross.x * height * 0.5 + dir.x * width * 0.5, pos.y + cross.y * height * 0.5 + dir.y * width * 0.5)

        direction = cross;

    //def reset()
    

    def draw()
        fill_convex_polygon(vertices, 0xFFFF0000)


