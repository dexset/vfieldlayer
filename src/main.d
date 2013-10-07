//import desgui.base.widget;
//import desgui.sdlapp;
//
//import desgl.helpers;
//
//class MainView: Widget
//{
//    this( string datapath )
//    {
//        super( null );
//        info.datapath = datapath;
//        inof.font = "font/gost_b.ttf";
//
//        reshape( rect );
//        update();
//    }
//}
//
//void main( string[] args )
//{
//    DerelictSDL2.load();
//    DerelictGL3.load();
//
//    if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
//        throw new Exception( "Couldn't init SDL: " ~ toDString(SDL_GetError()) );
//    
//    auto app = SDLApp.getApp( args );
//    auto view = new MainView( buildNormalizedPath( dirName(args[0]), "..", "data" ) );
//    view.halt.connect( &(app.halt) );
//    auto window = app.wrap( "test gui", view );
//
//    while( app.eventProcess() ) {}
//
//    clear( view );
//}
