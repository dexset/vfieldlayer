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
    SimpleButton slider;
    float pstep = 1;
    lim_t!float lim;
    float pcurr = 0;
    Orientation orient = Orientation.HORISONTAL;
    int ploc, cloc;
    void checkMarks()
    {
        import std.math;
        mark.length = lround(( max - min + 1 ) / pstep);
        foreach( i, ref m; mark )
        {
            m = new ColorRect!()( ploc, cloc );
            import std.stdio;
            if( orient == Orientation.HORISONTAL )
                m.reshape( irect( ( panel.rect.w - step * 2 ) / ( ( max - min ) / pstep ) * i, rect.h/2.0, 2, rect.h / 4 ) );
            else
                m.reshape( irect( 0, ( panel.rect.h + slider.rect.h + slider.rect.h / 2 ) / ( ( max - min ) / pstep ) * i, rect.w / 2, 2 ) );
        }
    }
public:
    this( DiWidget par, ivec2 sz )
    {
        super(par);

        lim = lim_t!float( 0, 10 );
        
        ploc = info.shader.getAttribLocation( "vertex" );
        cloc = info.shader.getAttribLocation( "color" );

        panel = new ColorRect!()( ploc, cloc );

        slider = new SimpleButton( this, irect( 0, 0, 10, sz.y ) );
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

        mouse.connectAlways((p, me)
        {
            void resh( ivec2 pos )
            {
                lim_t!int l;
                int r;
                int sz = panel.rect.w + slider.rect.w / 2;
                sz = cast(int)(sz / ((lim.minimum - lim.maximum)/pstep));

                if( orient == Orientation.HORISONTAL )
                {
                    l = lim_t!int( 0, panel.rect.w - slider.rect.w );
                    r = l( slider.rect.x, pos.x - pos.x % sz );
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

                import std.stdio;
                writeln( pcurr );

            }
            if( drag && me.type == me.Type.MOTION )
            {
                ivec2 pos;
                if( orient == Orientation.HORISONTAL )
                    pos = ivec2( p.x - slider.rect.w, 0 );
                else
                    pos = ivec2( 0, p.y - slider.rect.h );
                resh(pos);
            }
            else
            if( me.type == me.Type.PRESSED && me.btn == me.Button.LEFT )
            {
                ivec2 pos;
                if( orient == Orientation.HORISONTAL )
                    pos = ivec2( p.x - slider.rect.w, 0 );
                else
                    pos = ivec2( 0, p.y - slider.rect.h );
                resh(pos);
            }
            else
            if( me.type == me.Type.WHEEL )
            {
                pcurr = lim( pcurr, pcurr + me.data.y * step );
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

                import std.stdio;
                writeln( pcurr );
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
        });
        reshape( irect(0, 0, sz) );

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
        void min( float v ){ lim.minimum = v; }
        void max( float v ){ lim.maximum = v; }
        void step( float v ){ pstep = v; }
        float min(){ return lim.minimum; }
        float max(){ return lim.maximum; }
        float step(){ return pstep; }
        float curr(){ return pcurr; }
    }
}
