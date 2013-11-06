import engine;
import ui;

void main( string[] args )
{
    Application.init();

    auto mv = new MainView( "vflayer" );
    mv.show();

    Application.run();

    clear( mv );
    Application.destroy();
}
