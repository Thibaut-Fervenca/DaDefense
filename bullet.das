require daslib/media
require physObj

class Bullet
    speed: float
    sph: Sphere?
    dir: float2
    seed : int4
    color : uint
    isDiscard: bool

    def Bullet()
        speed = 0.0
        randomize_seed(seed)
        sph = new Sphere(float2(-1000, 10000), 3.0)

    def fire(pos: float2;_dir:float2)
        sph.pos = pos
        dir = _dir
        var r = random_float(seed)
        var b = random_float(seed)
        var g = random_float(seed)
        color = make_color(r,g,b,1.0)
        speed = 3000.0
        isDiscard = false;


    def update(dt:float)
        sph.pos += dir * speed * dt
        var screenWidth = float(get_screen_width())
        var screenHeight = float(get_screen_height())
        if (sph.pos.x + sph.radius > screenWidth || sph.pos.x < -sph.radius)
            if (!isDiscard)
                discard()
        if (sph.pos.y + sph.radius > screenHeight || sph.pos.y < -sph.radius)
            if (!isDiscard)
                discard()


    def draw()
        fill_circle(sph.pos.x, sph.pos.y, sph.radius, color)

    def discard()
        sph.pos = float2(-1000.0, -1000.0)
        speed = 0.0
        isDiscard = true;



class BulletMgr
    bullets: array<Bullet?>
    timeUntilLastShoot: float = 0.0
    dtFire: float = 0.2


    def fireBullet(pos: float2; dir: float2)
        if (timeUntilLastShoot > dtFire)
            timeUntilLastShoot = 0.0
            for b in bullets
                if (b.isDiscard)
                    b->fire(pos, dir)
                    return
            var newBullet = new Bullet()
            push(bullets, newBullet)
            newBullet->fire(pos, dir)

    def update(dt:float)
        timeUntilLastShoot += dt;
        for b in bullets
            b->update(dt)


    def draw()
        for b in bullets
            b->draw()