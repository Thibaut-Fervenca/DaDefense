require daslib/media
require physObj
require button
require menu
require scene

options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code

enum sceneType
    MENU
    GAME

var
    scene: Scene? = null
    windowX: int = 800
    windowY: int = 600

struct Terrain
    vertices : array<float2>



//todo
def initTerrain(var t : Terrain)
    var rndSeeds = int4( 5, 8, 9, 7 )
    let seed = random_int(rndSeeds)
    for i in range(get_screen_width())
        let curHeight = float(uint_noise_1D(i, 3u)) / 100000000.0;
        var values = float2(float(i), float(curHeight))
        push(t.vertices, values)

struct GameMode
    playerNum: int = 2


// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("DasProject")
    set_resolution(800, 600)
    scene = new Menu()


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

    //drawScene
    if (scene != null)
        scene->draw()

    return
