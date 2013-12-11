module ui.mainview;

import desgui;
import engine;

import ui.toolbar;
import ui.wsview;

class MainView : DiAppWindow
{
private:
    Program program;

    ToolBar toolbar;
    WSView wsview;

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

        toolbar = new ToolBar( this, 40 );
        toolbar.toolSelect.connect( &updateTool );

        auto tools = program.getList( program.ItemType.TOOL );
        foreach( tool; tools ) toolbar.addItem( tool );

        if( tools.length ) updateTool( tools[0] );

        wsview = new WSView( this );

        auto layers = program.getList( program.ItemType.LAYER );

        wsview.setLayers( layers );
        wsview.mouseAction.connect( (p,m)
        { 
            program.mouse_eh(p,m); 
            wsview.setLayers( program.getList( program.ItemType.LAYER ) );
        });

        if( layers.length )
            program.clickOnItem( program.ItemType.LAYER, layers[0] );
    }
}
