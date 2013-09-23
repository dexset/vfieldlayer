import std.stdio;
import desgui.glsdlapp;
import desgui.base.widget;
import std.path, std.file;
import draw.mainview;
import derelict.sdl2.sdl;

void main( string[] args )
{
    DerelictSDL2.load();
    if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
        throw new Exception( "Hui" );
    GLSDLApp app = GLSDLApp.getApp();
    auto mv = new MainView( buildNormalizedPath( dirName( args[0] ), "../data" ) );
    mv.haltSignal.connect( &(app.haltEvent) );
    app.setView( mv );
    while( app.eventProcess() ){}
}
