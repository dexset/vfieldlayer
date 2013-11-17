module ui.menu;

import ui.basewidget;

class Menu : BaseWidget
{
    DiLineLayout ll;

    this( DiWidget par, in irect r )
    {
        super( par, r );

        size_lim.h.fix = true;

        ll = new DiLineLayout();
        ll.border = 5;
        ll.space = 5;

        layout = ll;
    }
}
