import desgui.base.widget;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import desmath.types.vector,
       desmath.types.rect;

import desgl.object,
       desgl.shader,
       desgl.helpers,
       desgl.ssready,
       desgl.fbo;

import desutil.helpers;

import std.stdio;

import desgui.base.winfo;
import desgui.base.widget;
import desgui.ready.button;

class MainView: Widget
{
    this( WidgetInfo wi )
    {
        super( wi );

        auto bb = new SimpleButton( this, irect( 50, 50, 300, 500 ) );

        bool btn_state = true;
        auto btn = new SimpleButton( bb, irect( -10, -5, 320, 40 ), 
                "hello world"w, {} );
        btn.onClick.connect( { btn_state = !btn_state; btn.label.setText( ( btn_state ? "hello world"w : "привет мир"w ) ); } );

        reshape( rect );
        update();
    }
}

WidgetInfo info;
MainView view;

SDL_Window *window = null;
SDL_GLContext context;

enum TITLE = "gui test";
ivec2 size = ivec2( 800, 600 );

void init()
{
    DerelictSDL2.load();
    DerelictGL3.load();

    if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
        throw new Exception( "Couldn't init SDL: " ~ toDString(SDL_GetError()) );

    SDL_GL_SetAttribute( SDL_GL_BUFFER_SIZE, 32 );
    SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE,  24 );
    SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );

    window = SDL_CreateWindow( TITLE.ptr,
                               SDL_WINDOWPOS_UNDEFINED,
                               SDL_WINDOWPOS_UNDEFINED,
                               size.x, size.y,
                               SDL_WINDOW_OPENGL | 
                               SDL_WINDOW_SHOWN | 
                               SDL_WINDOW_RESIZABLE );
    if( window is null )
        throw new Exception( "Couldn't create SDL window: " ~ toDString(SDL_GetError()) );

    context = SDL_GL_CreateContext( window );

    if( context is null )
        throw new Exception( "Couldn't create SDL context: " ~ toDString(SDL_GetError()) );

    DerelictGL3.reload();

    SDL_GL_SetSwapInterval(1);
    glClearColor( .0f, .0f, .0f, .0f );
    glEnable( GL_BLEND );

    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );

    glEnable( GL_SCISSOR_TEST );
    glViewport( 0, 0, size.x, size.y );
}

void prepare( string[] args )
{
    import std.file, std.path;
    info = new WidgetInfo;

    info.datapath = buildNormalizedPath( dirName(args[0]), "..", "data" );
    info.font = "font/default.ttf";

    view = new MainView( info );
}

void destroy()
{
    clear( view );

    if( context !is null ) SDL_GL_DeleteContext( context );
    if( window !is null ) SDL_DestroyWindow( window );
    if( SDL_Quit !is null ) SDL_Quit();
}

void draw()
{

}

void resize( in ivec2 sz )
{
    size = sz;
    view.reshape( irect( 0,0, sz ) );
}

void mouse_button_eh( in ivec2 mpos, in SDL_MouseButtonEvent ev ) 
{ 
    auto me = MouseEvent( ev.state == SDL_PRESSED ? MouseEvent.Type.PRESSED : 
                            MouseEvent.Type.RELEASED, 0 );
    switch( ev.button )
    {
        case SDL_BUTTON_LEFT:   me.btn = MouseEvent.Button.LEFT; break;
        case SDL_BUTTON_MIDDLE: me.btn = MouseEvent.Button.MIDDLE; break;
        case SDL_BUTTON_RIGHT:  me.btn = MouseEvent.Button.RIGHT; break;
        case SDL_BUTTON_X1:     me.btn = MouseEvent.Button.X1; break;
        case SDL_BUTTON_X2:     me.btn = MouseEvent.Button.X2; break;
        default: break;
    }
    me.data = mpos;
    view.mouse( mpos, me );
}

void mouse_motion_eh( in ivec2 mpos, in SDL_MouseMotionEvent ev ) 
{ 
    auto me = MouseEvent( MouseEvent.Type.MOTION, 0 );
    me.btn = 
        ( ev.state & SDL_BUTTON_LMASK  ? MouseEvent.Button.LEFT : 0 ) |
        ( ev.state & SDL_BUTTON_MMASK  ? MouseEvent.Button.MIDDLE : 0 ) |
        ( ev.state & SDL_BUTTON_RMASK  ? MouseEvent.Button.RIGHT : 0 ) |
        ( ev.state & SDL_BUTTON_X1MASK ? MouseEvent.Button.X1 : 0 ) |
        ( ev.state & SDL_BUTTON_X2MASK ? MouseEvent.Button.X2 : 0 );
    me.data = mpos;
    view.mouse( mpos, me );
}

void mouse_wheel_eh( in ivec2 mpos, in SDL_MouseWheelEvent ev )
{
    auto me = MouseEvent( MouseEvent.Type.WHEEL, 0 );
    me.data = ivec2( ev.x, ev.y );
    view.mouse( mpos, me );
}

ivec2 mpos = ivec2(0,0);

bool eventProcess()
{
    SDL_Event event;
    while( SDL_PollEvent(&event) )
    {
        switch( event.type )
        {
            case SDL_QUIT: return false;

            case SDL_WINDOWEVENT:
                if( event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED )
                    resize( ivec2( event.window.data1, event.window.data2 ) );
                break;

            case SDL_MOUSEBUTTONDOWN: 
            case SDL_MOUSEBUTTONUP:
                mpos.x = event.button.x;
                mpos.y = event.button.y;
                mouse_button_eh( mpos, event.button );
                break;
            case SDL_MOUSEMOTION:
                mpos.x = event.motion.x;
                mpos.y = event.motion.y;
                mouse_motion_eh( mpos, event.motion );
                break;
            case SDL_MOUSEWHEEL:
                mouse_wheel_eh( mpos, event.wheel );
                break;

            case SDL_KEYDOWN: 
            case SDL_KEYUP: 
                if( event.key.keysym.scancode == SDL_SCANCODE_ESCAPE )
                    return false;
                break;
            default: break;
        }
    }

    view.idle();

    info.view.setClear( irect( ivec2(0,0), size ) );
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    view.draw();

    SDL_GL_SwapWindow( window );
    SDL_Delay(1);

    return true;
}

void testwidget_main( string[] args )
{
    init();
    prepare( args );
    while( eventProcess() ) {}
    destroy();
}

void main() 
{ 

    import core.runtime;
    import std.stdio;
    writeln( Runtime.args );

    testwidget_main( Runtime.args ); 
}
