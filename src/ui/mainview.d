module ui.mainview;

import ui.window;

import desgui;

import ui.workspace;

class MainView : AppWindow
{
    this( string title )
    {
        super( title );

        auto btn1 = new SimpleButton( this, irect( 5, 5, 200, 30 ), "button1"w, {} );
        auto btn2 = new SimpleButton( this, irect( 5, 40, 200, 30 ), "button2"w, {} );

        auto ws = new WorkSpace( this, irect( 205, 5, 400, 400 ) );
    }
}
