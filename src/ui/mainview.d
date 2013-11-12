module ui.mainview;

import ui.window;

import desgui;

import ui.workspace;

import desgl.draw.rectshape;

import std.stdio;

enum
{
    H_LAYOUT = true,
    V_LAYOUT = false
}

enum 
{
    ALIGN_LEFT = 0,
    ALIGN_TOP = 0,
    ALIGN_RIGHT = 1,
    ALIGN_BOTTOM = 1,
    ALIGN_CENTER = 2,
    ALIGN_JUSTIFY = 3
}

class LineLayout(bool L) : Layout
{
    private 
    {
        bool isStretched;
        bool isJustify;
        int mainoffset;
        int seoffset;
        int tboffset;
        int al; 
    }

    this( bool stretched = true )
    {
        isStretched = stretched;
    }

    void setAlign( int val ){ al = val; }
    void setJustify( bool val ){ isJustify = val; }
    void setSEOffset( int val ){ mainoffset = val; }
    
    void opCall( irect r, Widget[] ws )
    {
        int f_size, s_size;

        int offset;
        irect trect;

        int mval;

        if( L == H_LAYOUT )
            mval = r.w;
        else
            mval = r.h;

        int f_count, s_count;

        bool isFix( Widget w )
        {
            if( L == H_LAYOUT )
                return w.lims.w.fix;
            return w.lims.h.fix;
        }
        foreach( w; ws )
        {
            if( L == H_LAYOUT )
                if( w.lims.w.fix )
                {
                    f_size += w.rect.w;
                    f_count++;
                }
            if( L == V_LAYOUT )
                if( w.lims.h.fix )
                {
                    f_size += w.rect.h;
                    f_count++;
                }
        }
        s_count = cast(int)(ws.length) - f_count;
        if( s_count != 0 )
            s_size = ( mval - f_size ) / s_count;

        if( isStretched )
        {
            int poff;
            int n_size;
            foreach( ref w; ws )
            {
                if( isFix(w) )
                {
                    if( L == H_LAYOUT )
                    {
                        trect = irect( offset, 0, w.rect.w, r.h );
                        offset += w.rect.w;
                    }
                    else
                    {
                        trect = irect( 0, offset, r.w, w.rect.h );
                        offset += w.rect.h;    
                    }
                }
                else
                {
                    if( L == H_LAYOUT )
                    {
                        n_size = w.lims.w( w.rect.w, s_size );
                        trect = irect( offset, 0, n_size, r.h );
                    }
                    else
                    {
                        n_size = w.lims.h( w.rect.h, s_size );
                        trect = irect( 0, offset, r.w, n_size );
                    }
                    s_count--;
                    if( n_size != s_size )
                    {
                        s_size = ( mval - f_size - n_size ) / s_count;
                    }
                    offset += n_size;
                }
                w.reshape( trect );
            }
        }
        //else
        //{
        //    int toffset;
        //    if( L == H_LAYOUT )
        //       toffset 
        //    if( isJustify )
        //    {
        //        if( L == H_LAYOUT )

        //    }
        //    else
        //    {

        //    }
        //}
    }
}

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
        layout = new LineLayout!V_LAYOUT(false);
        //ivec2 old_vec;
        //ivec2 grab_vec;

        //mouse.connect( ( in ivec2 p, in MouseEvent me )
        //        {
        //            if( me.type == me.Type.PRESSED && 
        //                p.x > rect.w-20 )
        //            {
        //                grab = true;
        //                grab_vec = p - rect.size;
        //            }
        //            if( me.type == me.Type.RELEASED )
        //            {
        //                grab = false;
        //            }
        //            if( grab )
        //            {
        //                auto inrect = irect( rect.pos , p.x - grab_vec.x, rect.h  );
        //                reshape( inrect );
        //                parent.reshape( parent.rect );
        //            }
        //        });
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

        tb = new ToolBar( this, irect( 0, 20, 100, 400 ) );
        wspace = new WorkSpace( this, irect( 130, 5, 40, 40 ) );

        SimpleButton[10] btn;
        import std.random;
        foreach( i, ref b; btn )
        {
            import std.string;
            import std.conv;
            b = new MyButton( tb, irect( i, 5, 30+uniform( 0, 20 ), 30 ), to!wstring(format( "%d", i )), {} );
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
        btn_test = new SimpleButton( tb, irect( 5, 5, 40, 30 ), "brn"w, 
                { btn_test.label.setText( btn_str[cond%$] ); cond++; } );

        layout = new LineLayout!H_LAYOUT;

    }
}
