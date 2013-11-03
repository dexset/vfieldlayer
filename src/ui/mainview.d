module ui.mainview;

import engine.window;

import desgui;

class MainView : AppWindow
{
    this( string title )
    {
        super( title );

        auto btn1 = new SimpleButton( this, irect( 25, 10, 300, 40 ), "button1"w, {} );
        auto btn2 = new SimpleButton( this, irect( 25, 60, 300, 40 ), "button2"w, {} );
    }
}
