require daslib/media
require physObj
require player

let ASTEROID_POINTS = 16

def HermiteA(P0: float2; P1: float2; T0:float2; T1: float2; t: float) : float2
	var x : float = ((1.0f - 3.0f * (t*t) + 2.0f * (t*t*t)) * P0.x +((t*t) * (3.0f - 2.0f * t)) * P1.x + (t * ((t-1.0)*(t-1.0))) * T0.x +((t*t) * (t - 1.0f)) * T1.x)

    var y : float = (1.0f - 3.0f * (t*t) + 2.0f * (t*t*t)) * P0.y + ((t*t) * (3.0f - 2.0f * t)) * P1.y + (t * ((t-1.0)*(t-1.0))) * T0.y + ((t*t) * (t - 1.0f)) * T1.y
	return float2(x, y)


class AsteroidMgr
    asteroidAssets: array<Asteroid?>
    seed: int4
    time: float
    haveSpawn: bool

    def AsteroidMgr
        time = 0.0
        randomize_seed(seed)
        haveSpawn = false;

    def reset()
        time = 0.0
        randomize_seed(seed)
        haveSpawn = false;
        clear(asteroidAssets)

    def draw()
        for a in asteroidAssets
            a->draw()

    def update(dt:float)
        time +=dt
        var timeInt = int(time)
        if ((timeInt % 5 == 0))
            if (!haveSpawn)
                addNewAsteroid()
                haveSpawn = true;
        else
            haveSpawn = false;
        for a in asteroidAssets
            if (a.health < 0.0)
                resetAsteroid(a)
            a->update(dt)

    def resetAsteroid(var a:Asteroid?)
        randomize_seed(seed)
        a.speed = 100.0 + random_float(seed) * 300.0
        var randAngle = random_float(seed) * (3.147 * 2.0)
        var dir = normalize(float2(cos(randAngle), sin(randAngle)))
        var center = float2(float(get_screen_width())* 0.5, float(get_screen_height()) * 0.5)
        a.sph.pos = center + dir * float(get_screen_width())
        a.dir = -dir
        for i in range(0, ASTEROID_POINTS)
            a.curvature[i] = a.sph.radius + random_float(seed) * (a.sph.radius * 0.3) - (a.sph.radius * 0.015)

        a.health = random_float(seed) * 5.0 + 2.0; //[2 / 7.5]

    def addNewAsteroid()
        var asteroid = new Asteroid(float2(200.0, 400.0), 50.0, seed)
        push(asteroidAssets, asteroid)
        resetAsteroid(asteroid)

class Asteroid
    dir:float2
    speed: float
    sph: Sphere?
    vertices: array<float2>
    curvature: float[ASTEROID_POINTS]
    health: float

    def Asteroid(_pos: float2; radius: float; var seed: int4)
        sph = new Sphere(_pos, radius)
        speed = 100.0 + random_float(seed) * 300.0
        for i in range(0, ASTEROID_POINTS)
            curvature[i] = random_float(seed) * (radius * 1.5) - (radius * 0.5)

        dir = normalize(float2(float(get_screen_width()) * 0.5, float(get_screen_height()) * 0.5) - sph.pos )

        //for i in range(img.width)
        //    for j in range(img.height)
        

        for i in range(ASTEROID_POINTS)
            push(vertices, float2(0.0, 0.0))
            //if (sub == 0)
            //    toAdd = lerp(curvature[ASTEROID_POINTS -1], curvature[0], t)
            //else
            //    if (sub == ASTEROID_POINTS)
            //        toAdd = lerp(curvature[0], curvature[sub - 1], t)
            //    else
            //        toAdd = lerp(curvature[sub - 1], curvature[sub], t)
            //var toRad = float(i) * (3.14 / 180.0)
            //var dirR = normalize(float2(sin(toRad), cos(toRad)))
            //var posCentered = float2(radius * 2.0, radius * 2.0)
            //var pixelPos = posCentered + dirR * sph.radius * toAdd

        //for i in range(100)
        //    for j in range(200)
        //        img |> set_pixel(i, j, 0xFFFFFFFF) 

    def draw()
        fill_convex_polygon(vertices, 0xFFFFFFFF)
        //fill_circle(sph.pos.x, sph.pos.y, sph.radius, 0xFFFFFFFF)

    def update(dt: float)
        sph.pos += dir * speed * dt
        for i in range(0, ASTEROID_POINTS)
            var toDeg = float(i) * (360.0 / float(ASTEROID_POINTS))
            var toRad = float(toDeg) * (3.14 / 180.0)
            var dirR = normalize(float2(cos(toRad), sin(toRad)))
            vertices[i] = float2(sph.pos.x + dirR.x * curvature[i], sph.pos.y + dirR.y * curvature[i])
