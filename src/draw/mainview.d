module draw.mainview;
import desgui.base.widget;
import desutil.signal;

import desgui.ready.label;
import desgui.ready.button;

import desgl.draw.rectshape;

import desgl.fbo;
import desgl.ssready;

class MainView : Widget
{
    EmptySignal haltSignal;

    GLFBODraw!() glfbo;
    bool withfbo = false;

    this( string data_path )
    {
        super( null );

        info.datapath = data_path;
        info.font = "font/gost_a.ttf";

        auto k = new SimpleButton( this, irect( 10, 10, 420, 130 ), ""w );
        auto l = new SimpleButton( k, irect( 10,10, 400, 50 ), "simple button #1"w );
        auto i = new SimpleButton( k, irect( 10,70, 400, 50 ), "simple button #2"w );

        auto t = new Label( this, irect( 450, 50, 400, 40 ), "hello world" );

        //auto fx = new ShaderProgram( SS_WINCRD_SIMPLE_FBO_FX );
        auto fx = new ShaderProgram( SS_WINCRD_MINIMAL );

        glfbo = new GLFBODraw!()( fx );

        auto rshape = new RectShape( info.shader );
        rshape.setColor( col4( 0.25, 0.5, 0.75, 1 ) );
        rshape.reshape( irect( 50,35, 300, 800 ) );

        draw.addBeginF( () { if( withfbo ) glfbo.draw.call_begin(); } );
        draw.connect( (){ rshape.draw(); } );
        draw.addEndF( () { if( withfbo ) glfbo.draw.call_end(); } );
        
        reshape.connect( &(glfbo.reshape.opCall) );
        
        keyboard.connectAlways( (p, k){ if( k.key == 27 ) haltSignal(); });
        keyboard.connectAlways( (p, k){ if( k.key == 32 && k.pressed ) withfbo = !withfbo; });
    }
}
