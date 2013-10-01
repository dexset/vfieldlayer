module draw.mainview;
import desgui.base.widget;
import desutil.signal;

class MainView : Widget
{
    EmptySignal haltSignal;
    this( string data_path )
    {
        super( null );

        info.datapath = data_path;
        info.font = "font/gost_a.ttf";
        
        keyboard.connectAlways( (p, k){ if( k.key == 27 ) haltSignal(); });
    }
}
