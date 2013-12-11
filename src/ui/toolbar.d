module ui.toolbar;

import desgui;
import ui.item;

class ToolBar: DiPanel
{
    Signal!Item toolSelect;

    this( DiWidget par, uint w )
    {
        super( par, irect(0,0,w,100) );

        size_lim.w.fix = true;
        auto tl = new DiLineLayout(DiLineLayout.Type.VERTICAL);
        layout = tl;

        tl.stretchDirect = false;
        tl.border = 2;
        tl.space = 2;
    }

    void addItem( Item tool )
    {
        auto buf = new ItemButton( this, irect(0,0,40,40), tool );
        buf.itemClick.connect( (i){ toolSelect(i); });
    }
}
