module ui.toolbar;

import ui.basewidget;

class ToolBar : BaseWidget
{
    this( DiWidget par, in irect r )
    {
        super( par, r );

        size_lim.w.fix = true;
        auto tl = new DiLineLayout(DiLineLayout.Type.VERTICAL);
        layout = tl;

        tl.stretchDirect = false;
        tl.border = 2;
        tl.space = 2;
    }
}
