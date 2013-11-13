module ui.mainview;

import desgui;

import desgl.draw.rectshape;

import ui.basewidget;
import ui.workspace;
import ui.menu;
import ui.toolbar;

class MyButton : SimpleButton
{
    this( Widget par, in irect r, wstring caption, void delegate() onclick = null )
    {
        super( par, r, caption, onclick );
        size_lim.w.fix = false;
        size_lim.h.fix = true;
    }
}

class LayerView: BaseWidget
{
    this( Widget par, in irect r )
    {
        super( par, r );
        size_lim.w.fix = true;
        size_lim.h.fix = false;
    }
}

class MainView : AppWindow
{
private:
    ToolBar tb;
    Menu menu;
    WorkSpace wspace;

public:
    this( string title )
    {
        super( title );

        menu = new Menu( this, irect( 0, 0, 400, 30 ) );
        auto menuList = 
        [
            "File"w,
            "Edig"w,
            "View"w,
            "Help"
        ];
        foreach( i, mitem; menuList )
            auto mi = new SimpleButton( menu, irect( 0, 0, 100, 30 ), mitem );

        auto cw = new Widget( this );
        cw.layout = new LineLayout(H_LAYOUT);

        tb = new ToolBar( cw, irect( 0, 20, 50, 400 ) );
        wspace = new WorkSpace( cw, irect( 130, 5, 40, 40 ) );
        auto lv = new LayerView( cw, irect( 0,0, 200, 400 ) );

        foreach( i; 0 .. 10 )
        {
            import std.string;
            import std.conv;
            auto b = new MyButton( tb, irect( i, 5, 30, 30 ), to!wstring(format( "%d", i )), {} );
        }

        size_t cond = 0;
        SimpleButton btn_test;
        wstring[] btn_str = [ "as", "df", "jh", "jg", "10", "j1" ];
        btn_test = new SimpleButton( tb, irect( 5, 5, 30, 30 ), "bt"w, 
                { btn_test.label.setText( btn_str[cond%$] ); cond++; } );

        layout = new LineLayout(V_LAYOUT);
    }
}
