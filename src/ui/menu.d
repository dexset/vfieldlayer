module ui.menu;

import ui.basewidget;

class Menu : BaseWidget
{
    this( Widget par, in irect r )
    {
        super( par, r );

        size_lim.h.fix = true;

        layout = new LineLayout(H_LAYOUT,false);
        auto ll = cast(LineLayout)layout;
        ll.linealign = ALIGN_CENTER;
        ll.justify = false;
        ll.moffset = 1;
        ll.seoffset = 2;
    }
}
