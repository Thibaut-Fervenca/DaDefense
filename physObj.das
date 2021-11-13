
require daslib/media

enum PhysType
    SPHERE
    RECT

class physObj
    physType: PhysType


class Box : physObj
    pos: float2
    width: float
    height: float

    def Box(_pos: float2; _scale: float2)
        pos = _pos
        width = _scale.x
        height = _scale.y

    def rescale(v : float)
        width = width * v
        height = height * v

    def grow(v:float)
        width = width + width * v
        height = height + height * v

    def setScale(v:float2)
        width = v.x
        height = v.y

class Sphere : physObj
    pos: float2
    radius: float

    def Sphere(_pos: float2; _radius: float)
        pos = _pos
        radius = _radius
    def rescale(v : float)
        radius = radius * v
    def grow(v:float)
        radius = radius + radius * v

//////// function ///////


def colTest(s1: Sphere?; s: Sphere?) :bool
    var dir = s1.pos - s.pos
    var l: float
    l = length_sq(dir)
    var radiusSq = sqr(s.radius + s1.radius)
    if (l < radiusSq)
        return true
    return false

def colTest(b1: Box?; b2: Box?):bool
    //return true
    if (b1.pos.x - (b1.width * 0.5) >= b2.pos.x - (b2.width * 0.5) &&
      b1.pos.x + (b1.width * 0.5) <= b2.pos.x + (b2.width * 0.5) &&
      b1.pos.y - (b1.height * 0.5) >= b2.pos.y - (b2.height * 0.5) &&
      b1.pos.y + (b1.height * 0.5) <= b2.pos.y + (b2.height * 0.5))
        return true
    return false

def colTest(b: Box?; p: float2):bool
    var left = b.pos.x - (b.width * 0.5)
    var right = b.pos.x + (b.width * 0.5)
    var top = b.pos.y - (b.height * 0.5)
    var bottom  = b.pos.y + (b.height * 0.5)
    if ( left <= p.x &&
      right >= p.x &&
      bottom >= p.y &&
      top <= p.y)
        return true
    return false

def colTest(b1: Box?; s: Sphere?):bool
    var topRight = b1.pos + float2(b1.width, b1.height) * 0.5
    var topLeft = b1.pos + float2(-b1.width, b1.height) * 0.5
    var bottomRight = b1.pos + float2(b1.width, -b1.height) * 0.5
    var bottomLeft = b1.pos + float2(-b1.width, -b1.height) * 0.5
    var radiusSq = sqr(s.radius)
    if (length_sq(topRight - s.pos) <= radiusSq ||
      length_sq(topLeft - s.pos) <= radiusSq ||
      length_sq(bottomRight - s.pos) <= radiusSq ||
      length_sq(bottomLeft - s.pos) <= radiusSq)
        return true
    return false
////////////////////////////






