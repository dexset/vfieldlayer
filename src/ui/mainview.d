module ui.mainview;

import desgui;
import engine;

import ui.toolbar;
import ui.wsview;
import ui.llview;

class MainView : DiAppWindow
{
private:
    Program program;

    ToolBar toolbar;
    WSView wsview;
    LLView llview;

    void updateTool( Item tool )
    {
        program.clickOnItem( program.ItemType.TOOL, tool ); 
    }

public:
    this( string title )
    {
        super( title );
        layout = new DiLineLayout(DiLineLayout.Type.HORISONTAL);

        program = new VFProgram();
        program.create( program.CreateType.LAYER, 
                [ "name": Variant("test"), 
                  "size": Variant(imsize_t(800,600)),
                  "type": Variant(ImageType(ImCompType.UBYTE,3))
                ] );

        program.create( program.CreateType.LAYER, 
                [ "name": Variant("test2"), 
                  "size": Variant(imsize_t(800,600)),
                  "type": Variant(ImageType(ImCompType.UBYTE,3))
                ] );

        toolbar = new ToolBar( this, 40 );

        auto tools = program.getList( program.ItemType.TOOL );
        foreach( tool; tools ) toolbar.addItem( tool );

        if( tools.length ) updateTool( tools[0] );

        wsview = new WSView( this );

        auto layers = program.getList( program.ItemType.LAYER );

        wsview.setLayers( layers );

        if( layers.length )
            program.clickOnItem( program.ItemType.LAYER, layers[0] );

        llview = new LLView( this, 160 );
        llview.updateItems( layers );

        toolbar.toolSelect.connect( &updateTool );

        wsview.mouseAction.connect( (p,m)
        { 
            program.mouse_eh(p,m); 
            wsview.setLayers( program.getList( program.ItemType.LAYER ) );
            //wsview.update();
            llview.update();
        });
        llview.layerSelect.connect( (item)
        {
            program.clickOnItem( program.ItemType.LAYER, item );
            llview.update();
        });

        update();
    }
}
