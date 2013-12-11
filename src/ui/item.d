module ui.item;

public import engine.core;

import ui.except;
import desgui;

class TestItem: Item
{
    Image item_img;
    string item_name;

    class IRA: ImageReadAccess { const @property ref const(Image) selfImage() { return item_img; } }
    IRA ira;

    this( string N, string img_name )
    {
        import devilwrap;
        item_name = N;
        item_img = loadImageFromFile( img_name );
        ira = new IRA;
    }

    @property
    {
        string name() const { return item_name; }
        const(ImageReadAccess) pic() const { return ira; }
    }
}

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
    import std.conv;

    void prepareChilds()
    {
        image = new DiRectImage( this, irect(0,0,rect.size), item.pic );

        label = new DiLabel( this, irect(0,0,rect.size), to!wstring(item.name), DiLabel.TextAlign.LEFT );
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
            label.setText( to!wstring(item.name) );
            image.reloadImage( item.pic );
        });

        processEvent = 0;
    }
}

class ItemButton : DiButton
{
    DiItem elem;
    Signal!Item itemClick;

    this( DiWidget par, in irect r, Item item )
    {
        super( par, r );
        elem = new DiItem( this, irect( 0,0, r.size ), item );
        reshape.connect( (rr) { elem.reshape( irect(0,0,rect.size) ); } );
        onClick.connect({ itemClick(elem.item); });
    }
}
