require daslib/media
require physObj
require catMulRom

//don't zork for now
def vectorAngle(x: float; y: float) : float
    if (x == 0.0) // special cases
        return (y > 0.0) ? 180.0 : (y == 0.0) ? 0.0 : 0.0;
    else
        if (y == 0.0) // special cases
            return (x >= 0.0) ? 90.0 : 270.0;
    var ret = atan(y/x) * 180.0/3.147
    if (x < 0.0 && y < 0.0) // quadrant 4
        ret = 270.0 + ret;
    else
        if (x < 0.0 && y > 0.0) // quadrant 3
            ret = 180.0 + ret; // it actually substracts
        else
            if (x > 0.0 && y > 0.0) // quadrant 2
                ret = 90.0 + ret;
    return ret;

let subDiv = 10

class Planet
    img: Image
    pos: float2
    radius: float
    subDivision: int
    anglePerDiv: int
    refPoints : float2[subDiv + 1]
    refTangeant : float2[subDiv + 1]
    radiusBoundingBox: float
    seed: int4
    coreRadius: float
    angle: float
    core: Sphere?

    def Planet()
        reset()

    def reset()
        pos = float2(float(get_screen_width()) * 0.5, float(get_screen_height()) * 0.5)
        radius = float(get_screen_height()) * 0.4
        img <- create_image(get_screen_width(), get_screen_height())
        img |> make_image_color_transparent(0x00FFFFFF)
        var center = float2(float(img.width) * 0.5, float(img.height) * 0.5)
        randomize_seed(seed)
        subDivision = subDiv
        anglePerDiv = 360 / subDivision

        radiusBoundingBox = radius * 2.0

        coreRadius = 50.0
        core = new Sphere(center, coreRadius)

        //first carving
        //coreRadius = 50.0
        //for i in range(img.width)
        //    for j in range(img.height)
        //        var pixelPos = float2(float(i), float(j))
        //        var lengthSq = length_sq(pos - pixelPos)
        //        if (lengthSq < (coreRadius * coreRadius))
        //            img |> set_pixel(i, j, 0xFFFF0000)
        //        else
        //            if (lengthSq > (radius * radius))
        //                img |> set_pixel(i, j, 0x00FFFFFF)
        //            else
        //                img |> set_pixel(i, j, 0xFFFFFFFF)

        for i in range (0, subDivision)
            var maxWidth = get_screen_width()
            var widthPerSub = maxWidth / subDivision
            var pts = float2(float(i) * float(widthPerSub), (random_float(seed) * 200.0 - 100.0))
            var tgs = float2(pts.x, random_float(seed) * 200.0)
            refPoints[i] = pts
            refTangeant[i] = tgs

        refPoints[subDiv] = refPoints[0]
        refTangeant[subDiv] = refTangeant[0]

        
        
        for i in range(img.width)
            for j in range(img.height)
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
                var radialPos = center + (dir * radius) + (dir * yPos)
                //
                ////var T = (actualAngleDeg - (float(anglePerDiv) * float(sub))) / float(anglePerDiv)
                var lengthSqPixel = length_sq(pixelPos - center)
                var lengthSq = length_sq(radialPos - center)
                if (lengthSqPixel < lengthSq)
                    img |> set_pixel(i, j, 0xFFFFFFFF)
                else
                    img |> set_pixel(i, j, 0x00FFFFFF) 

        
        for i in range(img.width)
            for j in range(img.height)
                var pixelPos = float2(float(i), float(j))
                var lengthSq = length_sq(pos - pixelPos)
                if (lengthSq < (coreRadius * coreRadius))
                    img |> set_pixel(i, j, 0xFFFF0000)

    def draw()
        enable_alpha_blend()
        var positionImage = int2(int(pos.x) - img.width / 2, int(pos.y) - img.height / 2)
        img |> draw_image(positionImage.x , positionImage.y)

    def checkCol(sph: Sphere?) : bool
        var leftTopPos = sph.pos - float2(sph.radius, sph.radius)
        for i in range(leftTopPos.x, leftTopPos.x + radius * 2.0)
            for j in range(leftTopPos.y, leftTopPos.y + radius * 2.0)
                var col = img |> get_pixel(i, j)
                var b = col & 0xFF000000
                if (b > 0u)
                    var newPos = float2(float(i), float(j))
                    var lengthSq = length_sq(sph.pos - float2(float(i), float(j)))
                    if (lengthSq < (sph.radius * sph.radius))
                        addHole(float2(float(i), float(j)), 50.0)
                        return true
        return false;

    
    def addHole(var pos: float2; var r: float)
        var leftTop = float2(pos.x - r, pos.y - r)
        for i in range(leftTop.x, leftTop.x + r * 2.0)
            for j in range(leftTop.y, leftTop.y + r * 2.0)
                var lSq = length_sq(float2(i, j) - pos)
                if (lSq < (r*r))
                    img |> set_pixel(i, j, 0xFFF00FFF)

    def update(dt:float)
        angle += dt * 30.0