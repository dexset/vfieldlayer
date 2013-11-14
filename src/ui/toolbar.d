module ui.toolbar;

import ui.basewidget;

class ToolBar : BaseWidget
{
    this( DiWidget par, in irect r )
    {
        super( par, r );

        size_lim.w.fix = true;
        layout = new DiLineLayout(V_LAYOUT,false);
        auto tl = cast(DiLineLayout)(layout);
        tl.linealign = ALIGN_CENTER;
        tl.justify = false;
        tl.moffset = 2;
        tl.seoffset = 4;
    }
}
