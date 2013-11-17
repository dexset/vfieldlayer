module ui.mainview;

import desgui;

import desgl.draw.rectshape;

import ui.basewidget;
import ui.workspace;
import ui.menu;
import ui.toolbar;

class MyButton : SimpleButton
{
    this( DiWidget par, in irect r, wstring caption, void delegate() onclick = null )
    {
        super( par, r, caption, onclick );
        size_lim.w.fix = false;
        size_lim.h.fix = true;
    }
}

class LayerView: BaseWidget
{
    import desgui.ready.droplist;

    this( DiWidget par, in irect r )
    {
        super( par, r );
        size_lim.w.fix = true;
        size_lim.h.fix = false;

        import std.string, std.conv;
        wstring[] items;
        foreach( i; 0 .. 20 )
            items ~= to!wstring( format( "item[%02d]"w, i ) );

        auto dl = new DiDropList( this, irect( 10, 10, 180, 30 ), items );
        import std.stdio;
        dl.onSelect.connect( (v){ stderr.writeln( "droplist select: ", v ); });

        auto ll = new DiLineLayout(V_LAYOUT,false);
        layout = ll;
        ll.linealign = ALIGN_CENTER;
        ll.moffset = 5;
        ll.seoffset = 5;

        static class FixSimpleButton: SimpleButton
        {
            this( DiWidget par, in irect r, wstring str )
            {
                super( par, r, str );
                size_lim.h.fix = true;
            }
        }

        auto btn = new FixSimpleButton( this, irect( 0, 0, 180, 30 ), "button"w );

        auto dl2 = new DiDropList( this, irect( 10, 10, 180, 30 ), items[ 10 .. 15 ] );

        update();
    }
}

class MainView : DiAppWindow
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
            "Edit"w,
            "View"w,
            "Help"
        ];
        foreach( i, mitem; menuList )
            auto mi = new SimpleButton( menu, irect( 0, 0, 100, 30 ), mitem );

        auto cw = new DiWidget( this );
        cw.layout = new DiLineLayout(H_LAYOUT);

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

        layout = new DiLineLayout(V_LAYOUT);
    }
}
