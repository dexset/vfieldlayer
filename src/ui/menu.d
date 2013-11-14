module ui.menu;

import ui.basewidget;

class Menu : BaseWidget
{
    this( DiWidget par, in irect r )
    {
        super( par, r );

        size_lim.h.fix = true;

        auto ll = new DiLineLayout(H_LAYOUT,false);
        layout = ll;
        ll.linealign = ALIGN_CENTER;
        ll.justify = false;
        ll.moffset = 1;
        ll.seoffset = 2;
    }
}
