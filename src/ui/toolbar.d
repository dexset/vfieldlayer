module ui.toolbar;

import ui.basewidget;

class ToolBar : BaseWidget
{
    this( Widget par, in irect r )
    {
        super( par, r );

        size_lim.w.fix = true;
        layout = new LineLayout(V_LAYOUT,false);
        LineLayout tl = cast(LineLayout)(layout);
        tl.setAlign( ALIGN_CENTER );
        tl.setJustify( false );
        tl.setMainOffset( 2 );
        tl.setSEOffset( 4 );
    }
}
