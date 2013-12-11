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
    SimpleButton slider;
    float pmin = 0, pmax = 10, pstep = 1;
    float pcurr = 0;
    Orientation orient = Orientation.HORISONTAL;
public:
    this( DiWidget par, ivec2 sz )
    {
        super(par);
        
        auto ploc = info.shader.getAttribLocation( "vertex" );
        auto cloc = info.shader.getAttribLocation( "color" );
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
            void checkReshape( ivec2 pp )
            {
                int x, y;
                x = ( pp.x < 0 )?0:pp.x;
                x = ( pp.x > rect.w - slider.rect.w )?rect.w - slider.rect.w:pp.x;
                y = ( pp.y < 0 )?0:pp.y;
                y = ( pp.y > rect.h - slider.rect.h )?rect.h - slider.rect.h:pp.y;
                import std.stdio;
                writeln( x,":", pp.x );
                slider.reshape( irect( x, y, slider.rect.size ) );
            }
            if( drag && me.type == me.Type.MOTION )
            {
                ivec2 pos;
                if( orient == Orientation.HORISONTAL )
                    pos = ivec2( p.x - slider.rect.w, 0 );
                else
                    pos = ivec2( 0, p.y - slider.rect.h );
                checkReshape( pos );
            }
            else
            if( me.type == me.Type.PRESSED && me.btn == me.Button.LEFT )
            {
                ivec2 pos;
                if( orient == Orientation.HORISONTAL )
                    pos = ivec2( p.x - slider.rect.w, 0 );
                else
                    pos = ivec2( 0, p.y - slider.rect.h );
                checkReshape( pos );
            }
        });

        draw.connect( { panel.draw(); } );

        reshape.connect( (r)
        {
            if( orient == Orientation.HORISONTAL )
                panel.reshape( irect( 0, rect.h / 2, rect.w, 2 ) );
            else
                panel.reshape( irect( rect.w / 2, 0, 2, rect.h) );
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
        void min( float v ){ pmin = v; }
        void max( float v ){ pmax = v; }
        void step( float v ){ pstep = v; }
        float min(){ return pmin; }
        float max(){ return pmax; }
        float step(){ return pstep; }
        float curr(){ return curr; }
    }
}
