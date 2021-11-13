

let hexAlpha: uint = 0xFF000000
let hexRed: uint = 0x00FF0000
let hexGreen: uint = 0x0000FF00
let hexBlue: uint = 0x000000FF


def multColor(color: uint; v: float): uint
    var red = uint(float((color & hexRed) >> 16u) * v) << 16u
    var green = uint(float((color & hexGreen) >> 8u) * v) << 8u
    var blue  = uint(float((color & hexBlue)) * v)
    var alpha = color & hexAlpha
    return alpha+red+green+blue;