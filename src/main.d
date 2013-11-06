import engine;
import std.stdio;
import ui;

void main( string[] args )
{
    writeln("test");
    Application.init();

    auto mv = new MainView( "vflayer" );
    mv.show();

    Application.run();

    clear( mv );
    Application.destroy();
}
