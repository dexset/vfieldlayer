module ui.mainview;

import desgui;

import desgl.draw.rectshape;

import ui.workspace;

class ToolBar : Widget
{
public:
    ColorRect shape;

    this( Widget par, in irect r )
    {
        import std.stdio;
        super( par );
        auto ploc = info.shader.getAttribLocation( "vertex" );
        auto cloc = info.shader.getAttribLocation( "color" );
        shape = new ColorRect( ploc, cloc );
        shape.setColor( col4( 1.0f, 1.0f, 1.0f, 0.5f ) );
        draw.connect( ()
                {
                    shape.draw();
                } );
        reshape.connect( (r)
                {
                    auto inrect = irect( 0, 0, r.w, r.h );
                    shape.reshape(inrect);
                });
        reshape( r );
        size_lim.w.fix = true;
        layout = new LineLayout(V_LAYOUT,false);
        LineLayout tl = cast(LineLayout)(layout);
        tl.setAlign( ALIGN_CENTER );
        tl.setJustify( false );
        tl.setMainOffset( 2 );
        tl.setSEOffset( 4 );
    }
}

class MyButton : SimpleButton
{
    this( Widget par, irect r, wstring caption, void delegate() onclick = null )
    {
        super( par, r, caption, onclick );
        size_lim.w.fix = false;
        size_lim.h.fix = true;
    }
}

class MainView : AppWindow
{
private:

public:
    ToolBar tb;
    WorkSpace wspace;
    this( string title )
    {
        super( title );

        tb = new ToolBar( this, irect( 0, 20, 50, 400 ) );
        wspace = new WorkSpace( this, irect( 130, 5, 40, 40 ) );

        SimpleButton[10] btn;
        import std.random;
        foreach( i, ref b; btn )
        {
            import std.string;
            import std.conv;
            b = new MyButton( tb, irect( i, 5, 30, 30 ), to!wstring(format( "%d", i )), {} );
        }
        size_t cond = 0;
        SimpleButton btn_test;
        wstring[] btn_str = [ 
            "as",
            "df",
            "jh",
            "jg",
            "10",
            "j1"
            ];
        btn_test = new SimpleButton( tb, irect( 5, 5, 30, 30 ), "bt"w, 
                { btn_test.label.setText( btn_str[cond%$] ); cond++; } );

        layout = new LineLayout(H_LAYOUT);

    }
}
