module ui.workspace;

import desgui;
import desgl;

class WorkSpace: Widget
{
private:

    lim_t!float zoom_lim = lim_t!float(0.1, 10000);
    float zoom = 1.0f;

    ivec2 old_mpos;

    void mouse_hook( in ivec2 p, in MouseEvent me )
    {
        if( me.type == me.Type.RELEASED && 
            me.btn == me.Button.MIDDLE )
            grab = 0;
        else 
        if( me.type == me.Type.PRESSED && 
            me.btn == me.Button.MIDDLE )
            grab = 1;
        else 
        if( me.type == me.Type.MOTION && grab )
            inner += p - old_mpos;

        if( me.type == me.Type.WHEEL )
        {
            zoom = zoom_lim( zoom, zoom + me.data.y * zoom * 0.2 );

            auto lp = p - rect.pos;
            inner += ivec2( -(lp-inner) * me.data.y * zoom );
        }

        old_mpos = p;
    }

    SimpleButton btn;

public:
    this( Widget par, in irect r )
    {
        super( par );
        reshape( r );

        auto baserect = irect( 5,5, 100, 30 );

        btn = new SimpleButton( this, baserect, "ok btn"w, {} );

        idle.connect( { btn.reshape( irect( baserect * zoom ) ); } );

        mouse.connect( &mouse_hook );
    }
}
