import engine;
import ui;

void main( string[] args )
{
    Application.init();

    auto mv = new MainView( "WWWIwugsdi" );
    mv.show();

    Application.run();

    clear( mv );
    Application.destroy();
}
