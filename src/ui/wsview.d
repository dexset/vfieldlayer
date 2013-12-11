module ui.wsview;

import desgui;
import engine;

class WSView: DiWidget
{
private:

    lim_t!float zoom_lim = lim_t!float(0.01, 10000);
    float zoom = 1.0f;

    ivec2 old_mpos;
    ivec2 imsz = ivec2(800,600);

    ubyte state;

    void mouse_hook( in ivec2 p, in DiMouseEvent me )
    {
        if( me.type == me.Type.RELEASED ) grab = 0;
        else if( me.type == me.Type.PRESSED ) grab = 1;

        if( me.btn == me.Button.LEFT ) state = 1;
        else
        if( me.btn == me.Button.MIDDLE ) state = 2;
        else state = 0;

        if( me.type == me.Type.MOTION )
            if( state == 2 ) inner += p - old_mpos;

        auto loc = (p - rect.pos - inner) * zoom;
        mouseAction( loc, me );

        if( me.type == me.Type.WHEEL )
        {
            auto lp = p - rect.pos - inner;
            auto ip1 = lp * zoom;
            auto old_zoom = zoom;
            zoom = zoom_lim( zoom, zoom + me.data.y * zoom * 0.1 );
            if( zoom != old_zoom) 
            {
                auto ip2 = lp * zoom;
                auto d = ivec2( ( ip1 - ip2 ) / old_zoom );

                inner += d;
                foreach( im; imlist )
                    im.reshape( irect( 0, 0, imsz * zoom ) );
            }
        }

        old_mpos = p;
    }

    DiImage[] imlist;

public:

    alias ref const(vec2) in_vec2;
    Signal!(in_vec2, in_DiMouseEvent) mouseAction;

    this( DiWidget par )
    {
        super( par );

        mouse.connectAlways( &mouse_hook );
    }

    void setLayers( Item[] llist )
    {
        imlist.length = llist.length;
        childs.length = 0;
        foreach( i, ref im; imlist )
        {
            auto ll = cast(Layer)llist[i];
            if( ll is null ) continue;
            if( im is null ) im = new DiImage( this, irect(ll.bbox) );
            im.reloadImage( ll.pic );
        }
    }
}
