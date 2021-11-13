require daslib/media
require button
require tank
require catMulRom
require physObj
require asteroid
require player
require planet
require bullet

options debugger            // uncomment for debug in VS Code
require daslib/debug 

var debugPos: float2

struct Hole
    pos : float2
    radius: float

struct Terrain
    vertices : array<float2>
    refPoints : float2[11]
    refTangeant : float2[11]
    subDivision : int = 10
    nbVertices: int = 1000
    nbVerticesPerDiv : int = 1000/10
    img: Image
    holes : array<Hole>

def checkTankAndHole(var terrain: Terrain; var tank: Tank?) : Hole
    for h in terrain.holes
        var dirLSq = length_sq(tank.hitBox.pos - h.pos)
        var rSq = h.radius + 3.0
        rSq = rSq * rSq
        if (dirLSq <= (rSq))
            var dirXRelativ = (tank.hitBox.pos.x - h.pos.x) / h.radius
            var dir = normalize(float2(sin(dirXRelativ), -cos(dirXRelativ)))
            var posPixel = float2(h.pos.x, h.pos.y) + float2(dir.x * (h.radius+2.0), -dir.y * (h.radius + 2.0))
            var col = get_pixel(terrain.img, int(posPixel.x), int(posPixel.y))
            var b = (col & 0xFF000000) > 0u
            debugPos = posPixel
            if (b)
                if(tank.onGround)
                    tank.hitBox.pos = posPixel
                    tank.norm = normalize(h.pos - posPixel)
                return h
    var fakeHole : Hole
    fakeHole.radius = -1.0
    return fakeHole

def updateTerrainTankCol(var terrain: Terrain; var tanks: array<Tank?>)
    for t in tanks
        var sub = int(t.hitBox.pos.x) / terrain.nbVertices; // [0;1]
        var T = (float(t.hitBox.pos.x) - (float(sub) * float(terrain.nbVertices))) / float(terrain.nbVertices) /*sub / ((float)NbrPixelBySub - 1)*/;
        var yPos = Hermite(terrain.refPoints[sub], terrain.refPoints[sub + 1], terrain.refTangeant[sub], terrain.refTangeant[sub + 1], T).y;
        if ((t.hitBox.pos.y) >= yPos)
            var col = get_pixel(terrain.img, int(t.hitBox.pos.x), int(t.hitBox.pos.y - 4.0))
            var b = (col & 0xFF000000) > 0u
            if (!b)
                t->setGrounded(false);
            else
                if (t.hitBox.pos.y > yPos + 10.0)
                    var hole = checkTankAndHole(terrain, t)
                    if (hole.radius > 0.0)
                        var cross = float2(-t.norm.y, t.norm.x)
                        t.dir = cross
                else
                    var T0 = (float(t.hitBox.pos.x - 10.0) - (float(sub) * float(terrain.nbVertices))) / float(terrain.nbVertices)
                    var T1 = (float(t.hitBox.pos.x + 10.0) - (float(sub) * float(terrain.nbVertices))) / float(terrain.nbVertices)
                    var Pos0 =  Hermite(terrain.refPoints[sub], terrain.refPoints[sub + 1], terrain.refTangeant[sub], terrain.refTangeant[sub + 1], T0)
                    var Pos1 =  Hermite(terrain.refPoints[sub], terrain.refPoints[sub + 1], terrain.refTangeant[sub], terrain.refTangeant[sub + 1], T1)
                    var dir = normalize(Pos1 - Pos0)
                    var cross = float2(dir.y, -dir.x)
                    t.norm = normalize(cross)
                    t.dir = dir
                    t.hitBox.pos = float2(t.hitBox.pos.x ,yPos)
                t->setGrounded(true);
                //t.hitBox.pos = float2(t.hitBox.pos.x, yPos)
        else
            t->setGrounded(false);


let subDivHole = 10
class Scene
    sceneType: int = 0
    buttonMgr: ButtonMgr?
    tankMgr: TankMgr?
    //terrain: Terrain
    asteroidMgr: AsteroidMgr?
    player : Player?
    planet : Planet?
    bulletMgr : BulletMgr?
    refPoints : float2[subDivHole + 1]
    refTangeant : float2[subDivHole + 1]
    seed: int4
    needReset:bool = false

    def Scene()
        buttonMgr = new ButtonMgr()
        tankMgr = new TankMgr()
        asteroidMgr = new AsteroidMgr()
        player = new Player()
        planet = new Planet()
        bulletMgr = new BulletMgr()

    def reset()
        planet->reset()
        asteroidMgr->reset()
        //terrain.subDivision = 3
        //terrain.nbVertices = 300
        //terrain.nbVerticesPerDiv = 300/3
        randomize_seed(seed)
        needReset = false

    def draw()
        //terrain.img |> draw_image(0,0)
        if (buttonMgr != null)
            buttonMgr->draw()
        tankMgr->draw()

        asteroidMgr->draw()         

        //fill_circle(debugPos.x, debugPos.y, 5.0, 0xFF0000FF)

        planet->draw()
        player->draw()
        bulletMgr->draw()

        //for i in range (terrain.nbVertices - 1)
        //    line(terrain.vertices[i].x, terrain.vertices[i].y, terrain.vertices[i + 1].x, terrain.vertices[i + 1].y, 0xFFD80404)
        //for r in terrain.refPoints
        //    fill_circle(r.x, r.y, 3.0, 0xFFFFFFFF)
        //for t in terrain.refTangeant
        //    fill_circle(t.x, t.y, 30.0, 0xFFF00FFF)

    def update(dt:float)

        buttonMgr->update(dt)
        tankMgr->update(dt)
        //updateTerrainTankCol(terrain, tankMgr.tanks)
        asteroidMgr->update(dt)
        player->update(dt)

        bulletMgr->update(dt)

        if (get_mouse_button(MB_LEFT))
            var testPos = player.pos
            var testDir = player.direction
            bulletMgr->fireBullet(testPos, testDir)

        if (get_mouse_button_down(MB_LEFT))
            buttonMgr->onMouseLeftDown()
        
        if (get_mouse_button_up(MB_LEFT))
            buttonMgr->onMouseLeftUp()

        for a in asteroidMgr.asteroidAssets
            var dir = a.sph.pos - planet.core.pos
            var l: float
            l = length_sq(dir)
            var radiusSq = sqr(a.sph.radius + planet.core.radius)
            if (l < radiusSq)
                needReset = true

        for b in bulletMgr.bullets
            for a in asteroidMgr.asteroidAssets
                var dir = b.sph.pos - a.sph.pos
                var l: float
                l = length_sq(dir)
                var radiusSq = sqr(a.sph.radius + b.sph.radius)
                if (l < radiusSq)
                    a.health -= 2.5f
                    b->discard()

        //for a in asteroidMgr.asteroidAssets
        //    if (colTest(a.sph, player.sph))
        //        asteroidMgr->resetAsteroid(a)

        //if (get_mouse_button_down(MB_LEFT))
        //    //addHole(get_mouse_position(), 50.0)
        //    var mouse = get_mouse_position()
        //    var leftTop = float2(mouse.x - 50.0, mouse.y - 50.0)
        //    for i in range(leftTop.x, leftTop.x + 50.0 * 2.0)
        //        for j in range(leftTop.y, leftTop.y + 50.0 * 2.0)
        //            var lSq = length_sq(float2(i, j) - mouse)
        //            if (lSq < (50.0*50.0))
        //                planet.img |> set_pixel(i, j, 0x00FFFFFF)



        for b in buttonMgr.buttons
            if (b.clicked && b.buttonAction == ButtonAction RESET)
                needReset = true


        for a in asteroidMgr.asteroidAssets
            if(checkCol(a.sph, planet.img))
                asteroidMgr->resetAsteroid(a)


        if (needReset)
            reset()
        //for i in range (200, 600)
        //    for j in range (200, 400)
        //        terrain.img |> set_pixel(i, j, 0x0000F0FF)

    //def initTerrain()
    //    var rndSeeds = int4( 2, 8, 9, 8 )
    //    let seed = random_int(rndSeeds)
    //    for i in range (0, terrain.subDivision + 1)
    //        var pts = float2((float(i)/float(terrain.subDivision)) * float(get_screen_width()), float(get_screen_height()) * 0.5 + random_float(rndSeeds) * 100.0)
    //        var tgs = float2(pts.x, float(get_screen_height()) * random_float(rndSeeds) - float(get_screen_height()) * 0.5)
    //        terrain.refPoints[i] = pts
    //        terrain.refTangeant[i] = tgs
//
    //    for i in range (terrain.subDivision)
    //        for j in range(terrain.nbVerticesPerDiv)
    //            var T = (float(j) / (float(terrain.nbVerticesPerDiv) - 1.0))
    //            var p = j + (i * terrain.nbVerticesPerDiv)
    //            var pts = Hermite(terrain.refPoints[i], terrain.refPoints[i + 1], terrain.refTangeant[i], terrain.refTangeant[i + 1], T)
    //            push(terrain.vertices, pts)
//
    //    terrain.img <- create_image(get_screen_width(), get_screen_height())
    //    //for i in range(800)
    //    //    for j in range(600)
    //    //        var sub = i / terrain.nbVertices; // [0;1]
    //    //        var T = (float(i) - (float(sub) * float(terrain.nbVertices))) / float(terrain.nbVertices) /*sub / ((float)NbrPixelBySub - 1)*/;
    //    //        var yPos = Hermite(terrain.refPoints[sub], terrain.refPoints[sub + 1], terrain.refTangeant[sub], terrain.refTangeant[sub + 1], T).y;
    //    //        if (float(j) < yPos)
    //    //            terrain.img |> set_pixel(i, j, 0x0000F0FF)
    //    //        else
    //    //            terrain.img |> set_pixel(i, j, 0xFF0F0000)
//
    def addHole(pos: float2; r: float; var img: Image)

        for i in range (0, subDivHole)
            var maxWidth = get_screen_width()
            var widthPerSub = maxWidth / subDivHole
            var pts = float2(float(i) * float(widthPerSub), (random_float(seed) * 20.0 - 10.0))
            var tgs = float2(pts.x, random_float(seed) * 20.0)
            refPoints[i] = pts
            refTangeant[i] = tgs

        refPoints[subDivHole] = refPoints[0]
        refTangeant[subDivHole] = refTangeant[0]

        var leftTop = float2(pos.x, pos.y) - float2(r, r)
        for i in range(leftTop.x, leftTop.x + r * 2.0)
            for j in range(leftTop.y, leftTop.y + r * 2.0)

                var anglePerDiv = 360 / subDivHole
                var pixelPos = float2(float(i), float(j))
                var dir = normalize(pixelPos - pos)
                var norDir = float2(0.0, 1.0)
                var actualAngle = dir.x < 0.0 ? 3.14159 : 0.0
                actualAngle += dir.x < 0.0 ? (3.14159 - abs(acos(dot(norDir, dir)))) : abs(acos(dot(norDir, dir)));
                //dir = float2(cos(actualAngle), sin(actualAngle))
                var actualAngleDeg = actualAngle * 180.0/3.14159
                var sub = int(actualAngleDeg) / anglePerDiv
                sub = sub == subDiv ? sub - 1 : sub
                var T = (float(actualAngleDeg) - (float(sub) * float(anglePerDiv))) / float(anglePerDiv)
                //print("anglePerDiv = {anglePerDiv} \n")
                //print("angle = {actualAngleDeg} \n")
                //print("sub = {sub}\n")
                var yPos = Hermite(refPoints[sub], refPoints[sub + 1], refTangeant[sub], refTangeant[sub + 1], T).y;
                var newRadiusSqr = (r + yPos) * (r + yPos)
                //
                ////var T = (actualAngleDeg - (float(anglePerDiv) * float(sub))) / float(anglePerDiv)

                var lSq = length_sq(float2(i, j) - pos)
                if (lSq < newRadiusSqr)
                    img |> set_pixel(i, j, 0x00FFFFFF)
        
    //def removePixel(pos: float2; r: float)
    //    var leftTop = float2(pos.x, pos.y) - float2(r, r)
    //    for i in range(leftTop.x, leftTop.x + r * 2.0)
    //        for j in range(leftTop.y, leftTop.y + r * 2.0)
    //            var lSq = length_sq(float2(i, j) - pos)
    //            if (lSq < (r*r))
    //                terrain.img |> set_pixel(i, j, 0x0000F0FF)

    def checkCol(sph: Sphere?; var img : Image) : bool
        var leftTopPos = float2(sph.pos.x - sph.radius, sph.pos.y - sph.radius)
        for i in range(leftTopPos.x, leftTopPos.x + sph.radius * 2.0)
            for j in range(leftTopPos.y, leftTopPos.y + sph.radius * 2.0)
                var col = img |> get_pixel(i, j)
                var b = col & 0xFF000000
                if (b > 0u)
                    var newPos = float2(float(i), float(j))
                    var lengthSq = length_sq(float2(sph.pos.x - float(i), sph.pos.y - float(j)))
                    if (lengthSq < (sph.radius * sph.radius))
                        addHole(float2(float(i), float(j)), 100.0, img)
                        return true
        return false;        