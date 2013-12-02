module ui.item;

import ui.except;

import desgui;
import engine.core.item;

class DiRectImage : DiImage
{
    this( DiWidget par, in irect r, in ImageReadAccess ira )
    {
        super( par, r, ira );
        size_lim.h.fix = true;
        size_lim.w.fix = true;

        reshape.connect( (r)
        {
            if( r.w != r.h )
            {
                auto m = rect.w > rect.h ? rect.h : rect.w;
                forceReshape( irect( rect.pos, m,m ) );
            }
        });
    }
}

class DiItem : DiWidget
{
protected:

    void prepareChilds()
    {
        image = new DiRectImage( this, irect(0,0,rect.size), item.pic );

        label = new DiLabel( this, irect(0,0,rect.size), item.name, DiLabel.TextAlign.LEFT );
        label.fixH = true;
        label.height = 27;
    }

public:

    Item item;
    DiLineLayout llayout;

    DiLabel label;
    DiImage image;

    this( DiWidget par, in irect r, Item i )
    {
        if( i is null ) throw new UIException( "item is null" );
        super( par );
        item = i;

        reshape(r);
        prepareChilds();

        llayout = new DiLineLayout( DiLineLayout.Type.HORISONTAL );
        layout = llayout;
        
        llayout.alignDirect = llayout.Align.CENTER;
        llayout.border = 5;
        llayout.space = 5;

        update.connect(
        {
            label.setText( item.name );
            image.reloadImage( item.pic );
        });

        processEvent = 0;
    }
}

class ItemButton : DiButton
{
    DiItem elem;

    this( DiWidget par, in irect r, Item item )
    {
        super( par, r );
        elem = new DiItem( this, irect( 0,0, r.size ), item );
        reshape.connect( (rr) { elem.reshape( irect(0,0,rect.size) ); } );
    }
}
