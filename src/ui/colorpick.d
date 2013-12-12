module ui.colorpick;

import desgl;
import desgui;
import desmath;

class DiColorPicker : DiWidget
{
private:
    static col3[] cdata;
    static this()
    {
        int V = 100;
        float R, G, B;
        for( int S = 99; S >= 0; S-- )
            for( int H = 0; H < 360; H++ )
            {
                float Hi = H / 60;
                float Vmin = ( 100 - S ) * V / 100;
                float a = (V - Vmin)*( H % 60 ) / 60;

                float Vinc = Vmin + a;
                float Vdec = V - a;

                if( Hi >= 0 && Hi < 1 )
                {
                    R = V;
                    G = Vinc;
                    B = Vmin;
                }

                if( Hi >= 1 && Hi < 2 )
                {
                    R = Vdec; 
                    G = V;
                    B = Vmin;
                }

                if( Hi >= 2 && Hi < 3 )
                {
                    R = Vmin;
                    G = V;
                    B = Vinc;
                }

                if( Hi >= 3 && Hi < 4 )
                {
                    R = Vmin; 
                    G = Vdec; 
                    B = V;
                }

                if( Hi >= 4 && Hi < 5 )
                {
                    R = Vinc;
                    G = Vmin;
                    B = V;
                }

                if( Hi >= 5 && Hi < 6 )
                {
                    R = V;
                    G = Vmin;
                    B = Vdec;
                }

                R /= 100;
                G /= 100;
                B /= 100;

                cdata ~= col3( R, G, B );
            }
    }

    ColorTexRect!() cplane;
    GLTexture2D ctex;
public:
    this( DiWidget par, irect r )
    {
        super( par );

        ctex = new GLTexture2D;
        ctex.image( ivec2(360, 100), GL_RGB, GL_RGB, GL_FLOAT, cdata.ptr );

        auto ploc = info.shader.getAttribLocation( "vertex" ); 
        auto cloc = info.shader.getAttribLocation( "color" );
        auto tloc = info.shader.getAttribLocation( "uv" );

        cplane = new ColorTexRect!()( ploc, cloc, tloc );

        reshape.connect( (r)
        {
            cplane.reshape(rect);
        });

        draw.connect(()
        {
            ctex.bind();
            info.shader.setUniform!int( "use_texture", 2 );
            cplane.draw();
        });
    }
}
