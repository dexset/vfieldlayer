module ui.mainview;

import desgui;
import engine;

import ui.toolbar;
import ui.settingbar;
import ui.wsview;
import ui.llview;

class WSBar : DiPanel
{
    this( DiWidget par )
    {
        super( par, irect( 0, 0, 1, 1 ) );
        layout = new DiLineLayout( DiLineLayout.Type.HORISONTAL );
    }
}

class MainView : DiAppWindow
{
private:
    Program program;

    WSBar wsbar;
    ToolBar toolbar;
    SettingBar setbar;
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
        layout = new DiLineLayout(DiLineLayout.Type.VERTICAL);
        
        program = new VFProgram();
        program.create( program.CreateType.LAYER, 
                [ "name": Variant("test"), 
                  "size": Variant(imsize_t(800,600)),
                  "type": Variant(ImageType(ImCompType.UBYTE,4))
                ] );

        setbar = new SettingBar( this, 50 );

        //program.create( program.CreateType.LAYER, 
        //        [ "name": Variant("test2"), 
        //          "size": Variant(imsize_t(800,600)),
        //          "type": Variant(ImageType(ImCompType.FLOAT,2))
        //        ] );

        import ui.slider;
        wsbar = new WSBar( this );
        //import ui.colorpick;
        //auto cpick = new DiColorPicker( wsbar, irect( 0, 0, 100, 100 ) );

        toolbar = new ToolBar( wsbar, 40 );
        toolbar.toolSelect.connect( (it)
        {
            updateTool(it);
            setbar.loadSettings( program.getSettings( program.SettingType.TOOL ) );
        });
        auto tools = program.getList( program.ItemType.TOOL );
        foreach( tool; tools ) toolbar.addItem( tool );

        if( tools.length ) updateTool( tools[0] );

        wsview = new WSView( wsbar );

        auto layers = program.getList( program.ItemType.LAYER );

        wsview.setLayers( layers );

        if( layers.length )
            program.clickOnItem( program.ItemType.LAYER, layers[0] );

        llview = new LLView( wsbar, 160 );
        llview.updateItems( layers );

        toolbar.toolSelect.connect( &updateTool );

        wsview.mouseAction.connect( (p,m)
        { 
            program.mouse_eh(p,m); 
            wsview.setLayers( program.getList( program.ItemType.LAYER ) );
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
