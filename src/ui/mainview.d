module ui.mainview;

import ui.window;

import desgui;

import ui.workspace;

class MainView : AppWindow
{
    this( string title )
    {
        super( title );

        size_t btn1_cond = 0;
        SimpleButton btn1;
        wstring[] btn_str = [ 
            "as",
            "df",
            "jh",
            "jg",
            "10",
            "j1"
            ];
        btn1 = new SimpleButton( this, irect( 5, 5, 200, 30 ), "button1"w, 
                { btn1.label.setText( btn_str[btn1_cond%$] ); btn1_cond++; } );
        auto btn2 = new SimpleButton( this, irect( 5, 40, 200, 30 ), "button2"w, {} );

        auto ws = new WorkSpace( this, irect( 205, 5, 400, 400 ) );
    }
}
