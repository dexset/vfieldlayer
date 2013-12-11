module ui.llview;

import desgui;
import ui.item;

class LLView: DiPanel
{
    Signal!Item layerSelect;

    this( DiWidget par, uint w )
    {
        super( par, irect(0,0,w,100) );

        size_lim.w.fix = true;
        auto tl = new DiLineLayout(DiLineLayout.Type.VERTICAL);
        layout = tl;

        tl.stretchDirect = false;
        tl.border = 5;
        tl.space = 5;

    }

    void updateItems( Item[] llist )
    {
        ItemButton[] blist;
        childs.length = 0;
        foreach( layer; llist )
        {
            if( layer is null ) continue;
            auto buf = new ItemButton( this, irect(0,0,50,50), layer );
            buf.itemClick.connect( (i){ layerSelect(i); });
            blist ~= buf;
        }
    }
}
