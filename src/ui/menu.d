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
        ll.setAlign( ALIGN_CENTER );
        ll.setJustify( false );
        ll.setMainOffset( 1 );
        ll.setSEOffset( 2 );
    }
}
