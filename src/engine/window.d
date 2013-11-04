module engine.window;

import engine.def;
import engine.application;

import desgl.helpers;

class AppWindow : Widget
{
package:
    SDL_Window *window = null;
    SDL_GLContext context;

    WidgetInfo info = null;

    ivec2 mpos;

    void makeCurrent()
    {
        // TODO: add checking of current window and context
        if( SDL_GL_MakeCurrent( window, context ) < 0 )
            throw new AppException( "SDL fails with make current: " ~ toDString( SDL_GetError() ) );
    }

    void process()
    {
        makeCurrent();

        idle();

        info.view.setClear( irect( rect ) );
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
        draw();

        SDL_GL_SwapWindow( window );
    }

    void window_eh( in SDL_WindowEvent ev )
    {
        makeCurrent();
        switch( ev.event ) 
        {
            case SDL_WINDOWEVENT_NONE:         break;
            case SDL_WINDOWEVENT_SHOWN:        
                activate();
                break;
            case SDL_WINDOWEVENT_HIDDEN:       
                release();
                break;
            case SDL_WINDOWEVENT_EXPOSED:      break;
            case SDL_WINDOWEVENT_MOVED:        break;
            case SDL_WINDOWEVENT_RESIZED:      break;
            case SDL_WINDOWEVENT_SIZE_CHANGED: 
                auto rr = irect( ivec2(0,0), ivec2(ev.data1,ev.data2) );
                reshape( rr ); 
                break;
            case SDL_WINDOWEVENT_MINIMIZED:    break;
            case SDL_WINDOWEVENT_MAXIMIZED:    break;
            case SDL_WINDOWEVENT_RESTORED:     break;
            case SDL_WINDOWEVENT_ENTER:        
                activate();
                break;
            case SDL_WINDOWEVENT_LEAVE:        
                release();
                break;
            case SDL_WINDOWEVENT_FOCUS_GAINED: break;
            case SDL_WINDOWEVENT_FOCUS_LOST:   
                release();
                break;
            case SDL_WINDOWEVENT_CLOSE:        
                release();
                break;
            default: break;
        }
    }

    void keyboard_eh( in SDL_KeyboardEvent ev ) 
    { 
        makeCurrent();
        KeyboardEvent oev;
        oev.pressed = (ev.state == SDL_PRESSED);
        oev.scan = ev.keysym.scancode;
        oev.key = ev.keysym.sym;
        oev.repeat = cast(bool)ev.repeat;
        
        oev.mod = 
                  ( ev.keysym.mod & KMOD_LSHIFT ? KeyboardEvent.Mod.LSHIFT : 0 ) |
                  ( ev.keysym.mod & KMOD_RSHIFT ? KeyboardEvent.Mod.RSHIFT : 0 ) |
                  ( ev.keysym.mod & KMOD_LCTRL  ? KeyboardEvent.Mod.LCTRL  : 0 ) |
                  ( ev.keysym.mod & KMOD_RCTRL  ? KeyboardEvent.Mod.RCTRL  : 0 ) | 
                  ( ev.keysym.mod & KMOD_LALT   ? KeyboardEvent.Mod.LALT   : 0 ) |
                  ( ev.keysym.mod & KMOD_RALT   ? KeyboardEvent.Mod.RALT   : 0 ) |
                  ( ev.keysym.mod & KMOD_LGUI   ? KeyboardEvent.Mod.LGUI   : 0 ) |
                  ( ev.keysym.mod & KMOD_RGUI   ? KeyboardEvent.Mod.RGUI   : 0 ) |
                  ( ev.keysym.mod & KMOD_NUM    ? KeyboardEvent.Mod.NUM    : 0 ) |
                  ( ev.keysym.mod & KMOD_CAPS   ? KeyboardEvent.Mod.CAPS   : 0 ) |
                  ( ev.keysym.mod & KMOD_MODE   ? KeyboardEvent.Mod.MODE   : 0 ) |
                  ( ev.keysym.mod & KMOD_CTRL   ? KeyboardEvent.Mod.CTRL   : 0 ) |
                  ( ev.keysym.mod & KMOD_SHIFT  ? KeyboardEvent.Mod.SHIFT  : 0 ) |
                  ( ev.keysym.mod & KMOD_ALT    ? KeyboardEvent.Mod.ALT    : 0 ) |
                  ( ev.keysym.mod & KMOD_GUI    ? KeyboardEvent.Mod.GUI    : 0 );

        keyboard( mpos, oev );
    }

    void mouse_button_eh( in SDL_MouseButtonEvent ev ) 
    { 
        makeCurrent();
        mpos.x = ev.x;
        mpos.y = ev.y;

        auto me = MouseEvent( ev.state == SDL_PRESSED ? MouseEvent.Type.PRESSED : 
                                MouseEvent.Type.RELEASED, 0 );
        switch( ev.button )
        {
            case SDL_BUTTON_LEFT:   me.btn = MouseEvent.Button.LEFT; break;
            case SDL_BUTTON_MIDDLE: me.btn = MouseEvent.Button.MIDDLE; break;
            case SDL_BUTTON_RIGHT:  me.btn = MouseEvent.Button.RIGHT; break;
            case SDL_BUTTON_X1:     me.btn = MouseEvent.Button.X1; break;
            case SDL_BUTTON_X2:     me.btn = MouseEvent.Button.X2; break;
            default: 
                throw new AppException( "Undefined mouse button: " ~ to!string( ev.button ) );
        }

        me.data = mpos;
        mouse( mpos, me );
    }

    void mouse_motion_eh( in SDL_MouseMotionEvent ev ) 
    { 
        makeCurrent();
        mpos.x = ev.x;
        mpos.y = ev.y;

        auto me = MouseEvent( MouseEvent.Type.MOTION, 0 );
        me.btn = 
          ( ev.state & SDL_BUTTON_LMASK  ? MouseEvent.Button.LEFT : 0 ) |
          ( ev.state & SDL_BUTTON_MMASK  ? MouseEvent.Button.MIDDLE : 0 ) |
          ( ev.state & SDL_BUTTON_RMASK  ? MouseEvent.Button.RIGHT : 0 ) |
          ( ev.state & SDL_BUTTON_X1MASK ? MouseEvent.Button.X1 : 0 ) |
          ( ev.state & SDL_BUTTON_X2MASK ? MouseEvent.Button.X2 : 0 );
        me.data = mpos;
        mouse( mpos, me );
    }

    void mouse_wheel_eh( in SDL_MouseWheelEvent ev )
    {
        makeCurrent();
        auto me = MouseEvent( MouseEvent.Type.WHEEL, 0 );
        me.data = ivec2( ev.x, ev.y );
        mouse( mpos, me );
    }

public:
    EmptySignal show, hide;

    this( string title )
    {
        window = SDL_CreateWindow( title.ptr,
                                   SDL_WINDOWPOS_UNDEFINED,
                                   SDL_WINDOWPOS_UNDEFINED,
                                   rect.w, rect.h,
                                   SDL_WINDOW_OPENGL | 
                                   SDL_WINDOW_HIDDEN |
                                   SDL_WINDOW_RESIZABLE );

        if( window is null )
            throw new AppException( "Couldn't create SDL window: " ~ toDString( SDL_GetError() ) );

        context = SDL_GL_CreateContext( window );

        if( context is null )
            throw new AppException( "Couldn't create SDL context: " ~ toDString( SDL_GetError() ) );

        DerelictGL3.reload();

        SDL_GL_SetSwapInterval(1);

        glEnable( GL_BLEND );
        glEnable( GL_SCISSOR_TEST );

        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
        glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );

        Application.singleton.windows[window] = this;

        show.connect({ 
            SDL_ShowWindow( window ); 
        });

        hide.connect({ 
            SDL_HideWindow( window ); 
        });

        info = new WidgetInfo;
        info.font = "font/dejavusansmono.ttf";

        super( info );
    }

    ~this()
    {
        if( context !is null ) SDL_GL_DeleteContext( context );
        if( window !is null ) SDL_DestroyWindow( window );
    }
}
