module ui.slider;

import desgui;
import desgl;

class DiSlider : DiWidget
{
enum Orientation
{
    VERTICAL,
    HORISONTAL
}
private:
    ColorRect!() panel;
    ColorRect!()[] mark;

    DiLabel[2] extr;
    DiLabel nout;

    SimpleButton slider;
    float pstep = 1;
    lim_t!float lim;
    float pcurr = 0;
    Orientation orient = Orientation.HORISONTAL;
    int ploc, cloc;

    int marksize = 1;
    void checkMarks()
    {
        auto s = cast(int)(( max - min + 1 ) / pstep );

        if( s > rect.w / 2 )
        {
            mark.length = 2;
            foreach( ref m; mark )
                m = new ColorRect!()(ploc, cloc);

            if( orient == Orientation.HORISONTAL )
            {
                mark[0].reshape( irect( 0, rect.h/2.0, marksize, rect.h / 4 ) );
                mark[1].reshape( irect( panel.rect.w-marksize, rect.h/2.0, marksize, rect.h / 4 ) );
            }
            else
            {
                mark[0].reshape( irect( rect.w/2.0, 0, rect.w / 4, marksize ) );
                mark[1].reshape( irect( rect.w/2.0, panel.rect.h-marksize, rect.w / 4, marksize ) );
            }

            return;
        }
        
        mark.length = s;

        foreach( i, ref m; mark )
        {
            m = new ColorRect!()( ploc, cloc );
            import std.stdio;
            if( orient == Orientation.HORISONTAL )
                m.reshape( irect( ( panel.rect.w - marksize ) / ( ( max - min ) / pstep ) * i, rect.h/2.0, marksize, rect.h / 4 ) );
            else
                m.reshape( irect( rect.w/2.0, ( panel.rect.h - marksize ) / ( ( max - min ) / pstep ) * i, rect.w / 4, marksize ) );
        }
    }

    void checkCurrent()
    {
        update();
        ivec2 pos;
        if( orient == Orientation.HORISONTAL )
        {
            int rx = cast(int)(pcurr * ( ( panel.rect.w - slider.rect.w ) / (lim.maximum-lim.minimum) ));
            pos = ivec2( rx, 0 );
        }
        else
        {
            int ry = cast(int)(pcurr * ( ( panel.rect.h - slider.rect.h ) / (lim.maximum-lim.minimum) ));
            pos = ivec2( 0, ry );
        }
        slider.reshape( irect( pos, slider.rect.size ) );
    }

public:
    this( DiWidget par, wstring name, ivec2 sz )
    {
        super(par);

        lim = lim_t!float(0, 30);
        foreach( ref ex; extr )
            ex = new DiLabel( this, irect( 0, 0, 1, 1 ), "" );
        extr[1].textAlign = DiLabel.TextAlign.RIGHT;

        nout = new DiLabel( this, irect( 0, 0, 1, 1 ), name );
        nout.textAlign = DiLabel.TextAlign.CENTER;
        
        ploc = info.shader.getAttribLocation( "vertex" );
        cloc = info.shader.getAttribLocation( "color" );

        panel = new ColorRect!()( ploc, cloc );

        slider = new SimpleButton( this, irect( 0, 0, 10, sz.y ) );
        slider.release();
        auto drag = false;

        slider.mouse.connect( (p, me)
        {
            if( me.btn == me.Button.LEFT )
            {
                if( me.type == me.Type.PRESSED ) drag = true;
                else
                if( me.type == me.Type.RELEASED ) drag = false;
            }
        });

        update.connect(
        {
            import std.string, std.conv;
            nout.setText( to!wstring( format( "%s:% 5.2f", name, pcurr ) ) );

        });
        
        mouse.connectAlways((p, me)
        {
            auto pp = p - rect.pos;
            void resh( ivec2 pos )
            {
                lim_t!int l;
                int r;
                int sz = panel.rect.w + slider.rect.w / 2;
                sz = cast(int)(sz / ((lim.maximum - lim.minimum)/pstep));

                if( orient == Orientation.HORISONTAL )
                {
                    l = lim_t!int( 0, panel.rect.w - slider.rect.w );
                    if( sz > 0 )
                        r = l( slider.rect.x, pos.x % sz );
                    else
                        r = l( slider.rect.x, pos.x );

                    slider.reshape( irect( r, slider.rect.y, slider.rect.size ) );
                }
                else
                {
                    l = lim_t!int( 0, panel.rect.h - slider.rect.h );
                    r = l( slider.rect.y, pos.y );
                    slider.reshape( irect( slider.rect.x, r, slider.rect.size ) );
                }

                if( orient == Orientation.HORISONTAL )
                    pcurr = r / ( ( panel.rect.w - slider.rect.w ) / ( lim.maximum - lim.minimum ) );
                else
                    pcurr = r / ( ( panel.rect.h - slider.rect.h ) / ( lim.maximum - lim.minimum ) );
                pcurr -= pcurr % pstep;
                update();
            }
            if( drag && me.type == me.Type.MOTION )
            {
                ivec2 pos;
                if( orient == Orientation.HORISONTAL )
                    pos = ivec2( pp.x - slider.rect.w / 2, 0 );
                else
                    pos = ivec2( 0, pp.y - slider.rect.h / 2 );
                resh(pos);
            }
            else
            if( me.type == me.Type.PRESSED && me.btn == me.Button.LEFT )
            {
                ivec2 pos;
                if( orient == Orientation.HORISONTAL )
                    pos = ivec2( pp.x - slider.rect.w / 2, 0 );
                else
                    pos = ivec2( 0, pp.y - slider.rect.h / 2 );
                resh(pos);
            }
            else
            if( me.type == me.Type.RELEASED || !grab )
                drag = false;
            if( me.type == me.Type.WHEEL )
            {
                curr = lim( pcurr, pcurr + me.data.y * step );
                checkCurrent();
            }
        });

        draw.connect( 
        { 
            panel.draw(); 
            foreach( m; mark )
                m.draw();
        });

        reshape.connect( (r)
        {
            if( orient == Orientation.HORISONTAL )
                panel.reshape( irect( 0, rect.h / 2, rect.w-slider.rect.w, 2 ) );
            else
                panel.reshape( irect( rect.w / 2, 0, 2, rect.h-slider.rect.h) );
            checkMarks();
            extr[0].reshape( irect( 0, 0, 50, 20 ) );
            extr[1].reshape( irect( rect.w - 50, 0, 50, 20 ) );
            nout.reshape( irect( 0, 0, rect.w, rect.h / 2 ) );
        });

        reshape( irect(0, 0, sz) );
        size_lim.w.fix = true;
    }

    void setOrientation( Orientation o )
    { 
        if( o == orient )
            return;
        reshape( irect( rect.pos, rect.h, rect.w ) );
        orient = o;
    }

    @property
    {
        void min( float v )
        { 
            lim.minimum = v; 
            import std.conv;
            extr[0].setText( to!wstring(lim.minimum) );
            checkMarks();
            curr = min;
            update();
        }
        void max( float v )
        { 
            lim.maximum = v; 
            import std.conv;
            extr[1].setText( to!wstring(lim.maximum) );
            checkMarks();
            curr = min;
            update();
        }
        void step( float v ){ pstep = v; curr = min; update(); }
        void curr( float v ){ pcurr = v; checkCurrent(); }
        float min(){ return  lim.minimum; }
        float max(){ return  lim.maximum; }
        float step(){ return pstep; }
        float curr(){ return pcurr; }
    }
}
