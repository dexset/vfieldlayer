module engine.application;

import engine.def;
import engine.window;

class Application
{
package:
    static Application singleton;

    AppWindow[SDL_Window*] windows;

private:
    SDL_Joystick  *joy_dev = null;

    this()
    {
        DerelictSDL2.load();
        DerelictGL3.load();
        DerelictIL.load();

        ilInit();

        if( SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK ) < 0 )
            throw new AppException( "Couldn't init SDL: " ~ toDString( SDL_GetError() ) );

        SDL_GL_SetAttribute( SDL_GL_BUFFER_SIZE, 32 );
        SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE,  24 );
        SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
    }

    ~this()
    {
        if( SDL_JoystickClose !is null && joy_dev !is null )
            SDL_JoystickClose( joy_dev );

        if( SDL_Quit !is null ) SDL_Quit();
    }

    ulong count = 1000;

    bool work()
    {
        SDL_Event event;

        AppWindow selectWindow( uint id )
        {
            auto wid = SDL_GetWindowFromID( event.window.windowID ) in windows;
            if( wid ) return *wid;
            else return null;
        }

        while( SDL_PollEvent(&event) )
        {
            switch( event.type )
            {
                case SDL_QUIT: return false;

                case SDL_WINDOWEVENT:
                    auto w = selectWindow( event.window.windowID );
                    if(w) w.window_eh( event.window );
                    break;
                case SDL_KEYDOWN:
                case SDL_KEYUP: 
                    auto w = selectWindow( event.key.windowID );
                    if(w) w.keyboard_eh( event.key );
                    break;
                //case SDL_TEXTEDITING: break;
                case SDL_TEXTINPUT: 
                    //textinput_eh( event.text );
                    break;

                case SDL_MOUSEMOTION: 
                    auto w = selectWindow( event.motion.windowID );
                    if(w) w.mouse_motion_eh( event.motion );
                    break;
                case SDL_MOUSEBUTTONDOWN:
                case SDL_MOUSEBUTTONUP: 
                    auto w = selectWindow( event.button.windowID );
                    if(w) w.mouse_button_eh( event.button );
                    break;
                case SDL_MOUSEWHEEL: 
                    auto w = selectWindow( event.wheel.windowID );
                    if(w) w.mouse_wheel_eh( event.wheel );
                    break;

                case SDL_JOYAXISMOTION: break;
                case SDL_JOYBALLMOTION: break;
                case SDL_JOYHATMOTION: break;
                case SDL_JOYBUTTONDOWN: break;
                case SDL_JOYBUTTONUP: break;
                case SDL_JOYDEVICEADDED: break;
                case SDL_JOYDEVICEREMOVED: break;

                case SDL_CONTROLLERAXISMOTION: break;
                case SDL_CONTROLLERBUTTONDOWN: break;
                case SDL_CONTROLLERBUTTONUP: break;
                case SDL_CONTROLLERDEVICEADDED: break;
                case SDL_CONTROLLERDEVICEREMOVED: break;
                case SDL_CONTROLLERDEVICEREMAPPED: break;

                case SDL_FINGERDOWN: break;
                case SDL_FINGERUP: break;
                case SDL_FINGERMOTION: break;

                case SDL_DOLLARGESTURE: break;
                case SDL_DOLLARRECORD: break;
                case SDL_MULTIGESTURE: break;

                case SDL_CLIPBOARDUPDATE: break;

                case SDL_DROPFILE: break;
                default: break;
            }
        }

        foreach( id, win; windows ) win.process();

        return true;
        //return cast(bool)(--count);
    }

public:
    static void init()
    {
        destroy();
        singleton = new Application;
    }

    static void run() 
    { 
        if( singleton is null ) init();
        while( singleton.work() ) SDL_Delay(1); 
    }

    static void destroy()
    {
        if( singleton !is null ) clear( singleton );
    }
}
