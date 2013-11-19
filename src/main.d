import engine;
import desgui;
import ui;

void main( string[] args )
{
    DiApplication.init();

    auto mv = new MainView( "vflayer" );
    mv.show();

    DiApplication.run();

    clear( mv );
    DiApplication.destroy();
}
