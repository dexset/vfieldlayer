module testgl;

private 
{
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import desmath.types.vector,
       desmath.types.rect;

import desgl.object,
       desgl.shader,
       desgl.helpers,
       desgl.ssready,
       desgl.fbo;

import std.stdio;

SDL_Window *window = null;
SDL_GLContext context;

enum TITLE = "gl test";
ivec2 size = ivec2( 800, 600 );

void init()
{
    DerelictSDL2.load();
    if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
        throw new Exception( "Failed SDL_Init" );

    DerelictGL3.load();

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

    //glEnable( GL_DEPTH_TEST );
    //glEnable( GL_SCISSOR_TEST );

    glViewport( 0, 0, size.x, size.y );
}

class MyObj: GLObj!()
{
protected:
    GLVBO pos, col;
    ShaderProgram shader;

    ivec2 winsize = ivec2( 800, 600 );

    import std.datetime;

    StopWatch sw;

    float getDeltaTime()
    {
        sw.stop();
        float dt = sw.peek().to!("seconds",float);
        sw.reset();
        sw.start();
        return dt;
    }

    float alpha = 0;

    float[] fps;
    size_t fpsK = 0;

    float calcFPS( float mfps )
    {
        if( fps.length < 60 ) fps ~= mfps;
        else fps[fpsK++%fps.length] = mfps;
        float res = 0;
        foreach( f; fps ) res += f;
        res /= fps.length;
        return res;
    }

public:
    this( ShaderProgram sp, int posloc, int colloc )
    {
        shader = sp;

        pos = new GLVBO( [ 0.0f, 0.0f, 0.5f, 0.5f ] );
        setAttribPointer( pos, posloc, 2, GL_FLOAT );

        col = new GLVBO( [ 1.0f, 0.0f, 0.0f, 0.8f, 0.0f, 1.0f, 0.0f, 1.0f ] );
        setAttribPointer( col, colloc, 4, GL_FLOAT );

        draw.connect( () { glDrawArrays( GL_LINES, 0, 2 ); } );

        sw.start();
    }

    void idle( in vec2 offset, float tt, float sk )
    {
        auto dt = getDeltaTime();
        import std.math;

        alpha += dt * PI * 2 * sk;
        //writeln( calcFPS( 1.0f / dt ) );

        float d = 0.15;
        float x = d * cos( alpha + tt );
        float y = d * sin( alpha + tt );
        pos.setData( [ offset.x + 0.0f, offset.y + 0.0f, 
                offset.x + x, offset.y + y ] );
    }
}

MyObj[] obj;
GLFBODraw!() fxfbo;
GLFBODraw!()[2] mblur;
size_t use_blur = 0;
ShaderProgram shader, fxshdr, mbshdr;

size_t objsz = 20;

void prepare()
{
    shader = new ShaderProgram( SS_SIMPLE );
    auto dposloc = shader.getAttribLocation( "vertex" );
    auto dcolloc = shader.getAttribLocation( "color" );

    foreach( n; 0 .. objsz ^^ 2 )
        obj ~= new MyObj( shader, dposloc, dcolloc );

    fxshdr = new ShaderProgram( SS_WINSZ_SIMPLE_FBO_FX );
    mbshdr = new ShaderProgram( SS_WINSZ_SIMPLE_FBO );
    auto fposloc = fxshdr.getAttribLocation( "vertex" );
    auto fuvloc  = fxshdr.getAttribLocation( "uv" );
    auto fwszloc = fxshdr.getUniformLocation( "winsize" );
    auto fttuloc = fxshdr.getUniformLocation( "ttu" );
    fxfbo = new GLFBODraw!()( fxshdr, fposloc, fuvloc, fwszloc, fttuloc );
    mblur[0] = new GLFBODraw!()( mbshdr, fposloc, fuvloc, fwszloc, fttuloc );
    mblur[1] = new GLFBODraw!()( mbshdr, fposloc, fuvloc, fwszloc, fttuloc );
    //mbshdr.setUniform!float( "alpha", 1 );

    glDisable( GL_DEPTH_TEST );

    float mbcoef = 0.9;

    void drawobj()
    {
        shader.use(); 
        foreach( o; obj ) o.draw(); 
    }

    mblur[0].render.connect( () 
    {
        glClear( GL_COLOR_BUFFER_BIT );

        mbshdr.setUniform!float( "coef", mbcoef );
        mblur[1].draw();
        drawobj();

    });

    mblur[1].render.connect( () 
    {
        glClear( GL_COLOR_BUFFER_BIT );

        mbshdr.setUniform!float( "coef", mbcoef );
        mblur[0].draw();
        drawobj();

    });

    fxfbo.render.connect( () 
    { 
        glClearColor( 0,0,0,0 );
        glClear( GL_COLOR_BUFFER_BIT );

        mbshdr.setUniform!float( "coef", 1 );
        mblur[use_blur].draw(); 
        //drawobj();
    });
}

void idle() 
{ 
    import std.random;
    auto st = 1.0f / objsz;
    foreach( x; 0 .. objsz )
        foreach( y; 0 .. objsz )
            obj[y*objsz+x].idle( vec2(x,y)*st - vec2(0.5,0.5), x+y*0.05, 0.15 );
}

void draw()
{
    glClearColor( 0,0,0,0 );
    glClearDepth( 1 );
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    use_blur = use_blur ? 0 : 1;
    mblur[use_blur].render(); 

    fxfbo.render();
    fxfbo.draw();
}

void resize( in ivec2 sz )
{
    size = sz;
    fxfbo.reshape( irect( 0, 0, size.x, size.y ) );
    mblur[0].reshape( irect( 0, 0, size.x, size.y ) );
    mblur[1].reshape( irect( 0, 0, size.x, size.y ) );
    glViewport( 0, 0, size.x, size.y );
}

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

            case SDL_KEYDOWN: 
            case SDL_KEYUP: 
                if( event.key.keysym.scancode == SDL_SCANCODE_ESCAPE )
                    return false;
                break;
            default: break;
        }
    }

    idle();
    draw();
    SDL_GL_SwapWindow( window );
    SDL_Delay(1);

    return true;
}

void destroy()
{
    foreach( o; obj ) clear( o );
    clear( fxfbo );
    clear( mblur[0] );
    clear( mblur[1] );
    clear( shader );
    clear( fxshdr );
    clear( mbshdr );

    if( context !is null )
        SDL_GL_DeleteContext( context );
    if( window !is null )
        SDL_DestroyWindow( window );

    if( SDL_Quit !is null ) SDL_Quit();
}
}

void testgl_main( string[] args )
{
    init();
    prepare();
    while( eventProcess() ){}
    destroy();
}
