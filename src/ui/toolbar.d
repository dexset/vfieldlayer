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
        tl.linealign = ALIGN_CENTER;
        tl.justify = false;
        tl.moffset = 2;
        tl.seoffset = 4;
    }
}
