import engine;
import ui;

void main( string[] args )
{
    Application.init();

    auto mv = new MainView( "window 1" );
    mv.show();

    //auto mv2 = new MainView( "window 2" );
    //mv2.show();

    Application.run();

    clear( mv );
    //clear( mv2 );
    Application.destroy();
}
