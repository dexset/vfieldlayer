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
    ivec2 imsz = ivec2(640,480);

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
            auto lp = p - rect.pos - inner;
            auto ip1 = lp * zoom;
            auto old_zoom = zoom;
            zoom = zoom_lim( zoom, zoom + me.data.y * zoom * 0.1 );
            auto ip2 = lp * zoom;
            auto d = ivec2( ( ip1 - ip2 ) / old_zoom );

            inner += d;
            im.reshape( irect( 0, 0, imsz * zoom ) );
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
