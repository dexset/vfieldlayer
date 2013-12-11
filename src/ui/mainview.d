module ui.mainview;

import desgui;
import engine;

import ui.toolbar;
import ui.settingbar;
import ui.wsview;

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
                  "type": Variant(ImageType(ImCompType.UBYTE,3))
                ] );

        setbar = new SettingBar( this, 50 );

        /// TODO TEST

        import ui.slider;
        auto slide = new DiSlider( setbar, ivec2(200, 30) );
        ///
        wsbar = new WSBar( this );

        toolbar = new ToolBar( wsbar, 40 );
        toolbar.toolSelect.connect( &updateTool );
        auto tools = program.getList( program.ItemType.TOOL );
        foreach( tool; tools ) toolbar.addItem( tool );

        if( tools.length ) updateTool( tools[0] );

        wsview = new WSView( wsbar );

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
