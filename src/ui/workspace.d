module ui.workspace;

import desgui;
import desgl;

import dvf;
import derelict.devil.il;

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

    GLTexture2D tex;
    ColorTexRect plane;
    DVF_FileHeader fhead;
    DVF_FileMeta fmeta;
    DVF_LayerHeader imhead;
    ulong imsz;
    ubyte[] imdata;

public:
    this( Widget par, in irect r )
    {
        super( par );
        reshape( r );

        auto baserect = irect( 5,5, 100, 30 );

        //IL

        fhead.type = "DVF ";
        fhead.major = 0;
        fhead.minor = 1;
        fmeta.layers = 1;

        ILuint im;

        ilGenImages( 1, &im );

        ilBindImage( im );

        import std.stdio;
        if( ilLoadImage( "data/images/im1.jpg" ) == false )
            stderr.writeln( "Error loading image!" );

        imhead.id = 0;
        imhead.name = cast(char[256])("Image");
        imhead.comps = 3;
        imhead.type = DVF_TYPE_UBYTE;
        imhead.pos[] = 0;
        imhead.res[0] = cast(ushort)(ilGetInteger( IL_IMAGE_WIDTH  ));
        imhead.res[1] = cast(ushort)(ilGetInteger( IL_IMAGE_HEIGHT ));
        imhead.mask_id = -1;
        fmeta.res = imhead.res;
        ubyte* rawimdata = ilGetData();
        imsz = imhead.res[0]*imhead.res[1]*3;
        imdata.length = imsz;

        foreach( i, ref d; imdata )
            d = rawimdata[i];

        ///

        tex = new GLTexture2D;
        tex.image( ivec2( imhead.res[0], imhead.res[1] ), GL_RGB, GL_RGB, GL_UNSIGNED_BYTE, imdata.ptr );
                

        auto ploc = info.shader.getAttribLocation( "vertex" );
        auto cloc = info.shader.getAttribLocation( "color" );
        auto tloc = info.shader.getAttribLocation( "uv" );

        plane = new ColorTexRect( ploc, cloc, tloc );
        plane.reshape( irect(10, 10, imhead.res[0], imhead.res[1]) );

        reshape.connect( (r)
                {
                   plane.reshape(irect(0, 0, r.size)); 
                });
        draw.connect( ()
                {
                    plane.draw();
                } );

        idle.connect( { plane.reshape( irect( baserect * zoom ) ); } );

        mouse.connect( &mouse_hook );
    }
}
