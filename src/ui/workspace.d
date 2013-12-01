module ui.workspace;

import desgui;
import desgl;

import dvf;
import desil;

import devilwrap;
import desutil.helpers;

class WorkSpace: DiWidget
{
private:

    lim_t!float zoom_lim = lim_t!float(0.001, 10000);
    float zoom = 1.0f;

    ivec2 old_mpos;

    void mouse_hook( in ivec2 p, in DiMouseEvent me )
    {
        if( me.type == me.Type.RELEASED && me.btn == me.Button.MIDDLE )
            grab = 0;
        else 
        if( me.type == me.Type.PRESSED && me.btn == me.Button.MIDDLE )
            grab = 1;
        else 
        if( me.type == me.Type.MOTION && grab ) inner += p - old_mpos;

        if( me.type == me.Type.WHEEL )
        {
            zoom = zoom_lim( zoom, zoom + me.data.y * zoom * 0.2 );
            auto lp = p - rect.pos;
            inner += ivec2( -(lp-inner) * me.data.y * zoom );
            im.reshape( irect( 0, 0, ivec2(640,480) * zoom ) );
        }

        old_mpos = p;
    }

    GLTexture2D tex;
    DiImage im;

public:
    this( DiWidget par, in irect r )
    {
        super( par );
        reshape( r );

        Image image = loadImageFromFile( "data/images/im1.jpg" );
        im = new DiImage( this, irect( 20, 20, 640, 480 ), image );
        im.aspectRatio = im.AspectRatio.FIT;
        tex = new GLTexture2D;
        tex.image( image );
                
        reshape.connect( (r)
        {
            im.reshape(irect(0, 0, r.size)); 
        });
        mouse.connectAlways( &mouse_hook );
    }
}
