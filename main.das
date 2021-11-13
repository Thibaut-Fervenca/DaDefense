require daslib/media
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code


require physObj
require button
require gameScene
require scene
require catMulRom



enum sceneType
    MENU
    GAME

var
    scene: Scene? = null
    windowX: int = 800
    windowY: int = 600




//todo
//def initTerrain(var t : Terrain)
//    var rndSeeds = int4( 5, 8, 9, 7 )
//    let seed = random_int(rndSeeds)
//    var pointsToPass : array<float2>
//    //for i in range(t.nbPoints)
//    //    var y = random_float(rndSeeds) * 50.0 + 300.0
//    //    var pts : float2 = float2(((float(i)/float(t.nbPoints))) * float(get_screen_width()), y)
//    //    push(pointsToPass, pts)
//    //t.nbVertices = setSplinePoints(pointsToPass, t.vertices, t.nbPoints)

struct GameMode
    playerNum: int = 2

// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("DasProject")
    var x = 1920
    var y = 1080
    set_resolution(x, y)
    scene = new GameScene()
    //scene->initTerrain()
    //initTerrain(scene.terrain)


// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

    scene->update(dt)

    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    //for xy in scene.terrain.vertices
    //    fill_circle(xy.x, xy.y, 1.0, 0xFFD80404)
    fill_rect(0, 0, get_screen_width(), get_screen_height(), 0x000000)
    //drawScene
    if (scene != null)
        scene->draw()
    fill_rect(0, 0, get_screen_width(), get_screen_height(), 0x000000)

    return
