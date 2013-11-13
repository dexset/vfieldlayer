import engine;
import desgui;
import ui;
import derelict.devil.il;

void main( string[] args )
{
    DerelictIL.load();
    ilInit();
    Application.init();

    auto mv = new MainView( "vflayer" );
    mv.show();

    Application.run();

    clear( mv );
    Application.destroy();
}
