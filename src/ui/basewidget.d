module ui.basewidget;

public import desgui;
public import desgl.draw.rectshape;

class BaseWidget : Widget
{
protected:
    ColorRect shape;

public:
    this( Widget par, in irect r )
    {
        super( par );
        auto ploc = info.shader.getAttribLocation( "vertex" );
        auto cloc = info.shader.getAttribLocation( "color" );
        shape = new ColorRect( ploc, cloc );
        shape.setColor( col4( 1.0f, 1.0f, 1.0f, 0.2f ) );
        draw.connect({ shape.draw(); });
        reshape.connect( (r)
        {
            auto inrect = irect( 0, 0, r.w, r.h );
            shape.reshape(inrect);
        });
        reshape( r );
    }
}
