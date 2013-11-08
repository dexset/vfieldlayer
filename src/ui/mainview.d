module ui.mainview;

import ui.window;

import desgui;

import ui.workspace;

import desgl.draw.rectshape;

class VLayout : Layout
{
    enum
    {
        ALIGN_RIGHT = 0,
        ALIGN_CENTER,
        ALIGN_LEFT
    }

    int offsety;
    bool isStreched;
    int lalign;

    this( bool stry = false, int al = ALIGN_RIGHT, int oy = 2 )
    {
        isStreched = stry;
        lalign = al;
        offsety = oy;
    }

    void opCall( irect r, Widget[] ws )
    {
        int summ;
        if( isStreched )
        {
            foreach( w; ws )
                summ += w.rect.h;
            offsety = cast(int)( ( r.h - summ ) / ( ws.length ));
        }
        summ = offsety / 2;
        irect t;
        int ox;
        if( lalign == ALIGN_LEFT )
            ox = 5;
        foreach( ref w; ws )
        {
            if( lalign == ALIGN_RIGHT )
                ox = r.w - w.rect.w - 5;
            if( lalign == ALIGN_CENTER )
                ox = r.w / 2 - w.rect.w / 2;
            t = irect( ox, summ, w.rect.w, w.rect.h );
            w.reshape( t );
            summ += offsety + w.rect.h;
        }
    }
}

class ToolBar( int A ) : Widget
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
        layout = new VLayout( false, A, 10 );
        bool grabed;
        ivec2 old_vec;
        ivec2 grab_vec;

        mouse.connect( ( in ivec2 p, in MouseEvent me )
                {
                    if( me.type == me.Type.PRESSED && 
                        p.x > rect.w-20 )
                    {
                        writeln( "Grabed" );
                        grabed = true;
                        grab_vec = p - rect.size;
                    }
                    if( me.type == me.Type.RELEASED )
                    {
                        grabed = false;
                        writeln( "Ungrabed" );
                    }
                    if( grabed )
                    {
                        auto inrect = irect( rect.pos , p.x - grab_vec.x, rect.h  );
                        reshape( inrect );
                    }
                });
    }
}

class MainView : AppWindow
{
private:

    class MLayout : Layout
    {
        void opCall( irect r, Widget[] ws )
        {
            tb.reshape( irect( 0, 0, tb.rect.w, r.h ) ); 
            wspace.reshape( irect( tb.rect.w, 0, r.w - tb.rect.w, r.h ) );
        }
    }

public:
    ToolBar!(VLayout.ALIGN_LEFT) tb;
    WorkSpace wspace;
    this( string title )
    {
        super( title );

        tb = new ToolBar!(VLayout.ALIGN_LEFT)( this, irect( 0, 20, 100, 400 ) );
        wspace = new WorkSpace( this, irect( 130, 5, 400, 400 ) );

        SimpleButton[10] btn1;
        import std.random;
        foreach( i, ref b; btn1 )
        {
            import std.string;
            import std.conv;
            b = new SimpleButton( tb, irect( i, 5, 30+uniform( 0, 20 ), 30 ), to!wstring(format( "%d", i )), {} );
        }

        layout = new MLayout();

        import std.stdio;
    }
}
