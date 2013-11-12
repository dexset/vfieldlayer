module engine.workspace;

import engine.viewport;
import engine.wsdata;
import engine.history;

import std.variant;
import desgui.base.widget;

class Workspace: Viewport, WSData, TempBuffer
{
private:
    ivec2 vp_offset = ivec2(0,0);
    float vp_scale = 1.0f;

    lim_t!float vp_scale_lim = lim_t!float( 0.001, 10000 );

    Image mask_img = null;

    Image[ImageType] temp_list;

    Layer[] layers_list;

    wstring ws_name;

public:

    this( in imsize_t sz, wstring Name )
    {
        mask_img = new Image( sz, ImageType( ComponentType.NORM_FLOAT, 1 ) );
        ws_name = Name;
    }

    @property
    {
        wstring name() const { return ws_name; }
        const(Image) pic() const { return null; }

        ivec2 offset() const { return vp_offset; }
        void offset( in ivec2 o ) { vp_offset = o; }

        float scale() const { return vp_scale; }
        void scale( float sc ) { vp_scale = vp_scale_lim( vp_scale, sc ); }

        imsize_t size() const { return mask_img.size; }

        TempBuffer buffer() { return this; }

        Image mask() { return mask_img; }

        ref Layer[] layers() { return layers_list; }
    }

    Setting[] getSettingsList() { return []; }

    // TempBuffer
    Image[] getTempImages( in ImageType[] it_list )
    {
        Image[] ret;
        foreach( it; it_list )
            if( it in temp_list )
                ret ~= temp_list[it];
            else
            {
                auto buf = new Image( size, it );
                temp_list[it] = buf;
                ret ~= buf;
            }
        return ret;
    }

    void clearTempImages()
    {
        foreach( it, img; temp_list )
            img.clearLastChanges();
    }
}

unittest
{
    import std.stdio;

    auto ws = new Workspace( imsize_t( 40, 40 ), "test workspace" );
    assert( ws.size == imsize_t( 40, 40 ) );

    ws.offset = ivec2( 10, 15 );
    assert( ws.offset == ivec2( 10, 15 ) );

    ws.scale = 0;
    assert( ws.scale == 0.001f );

    auto tb = ws.buffer;

    auto tmp_img = tb.getTempImages( [ ImageType( ComponentType.NORM_FLOAT, 1 ) ] );
    assert( tmp_img[0].size == imsize_t( 40,40 ) );
    tmp_img[0].access!float(10,10) = 0.2;
    assert( tmp_img[0].read!float(10,10) == 0.2f );
    tb.clearTempImages();
    assert( tmp_img[0].read!float(10,10) == 0.0f );

    class TestLayer: Layer
    {
    private:
        Image img;
        ivec2 pos = ivec2(0,0);
        bool selected = 0;
        bool visible = 1;

        BoolSetting visible_set;

    public:
        this( in imsize_t sz )
        {
            img = new Image( sz, ImageType( ComponentType.NORM_FLOAT, 1 ) );
            visible_set = new class BoolSetting
            {
                public override wstring name() const { return "visible"; }
            };
        }

        @property
        {
            wstring name() const { return "test layer"; }
            const(Image) pic() const { return img; }
            irect bbox() const { return irect( pos, img.size ); }
            Image image() { return img; }
            bool select() const { return selected; }
            void select( bool s ) { selected = s; }
        }

        Setting[] getSettingsList() { return [ visible_set ]; }

        bool isvisible() const { return visible; }
    }

    ws.layers ~= new TestLayer( imsize_t( 10, 10 ) );
    auto tlset = ws.layers[0].getSettingsList();
    bool setting_updated = false;
    tlset[0].updateConnect( (v) { setting_updated = true; } );

    assert( tlset[0].name == "visible" );
    assert( tlset[0].value == false );
    assert( setting_updated == false );

    tlset[0].value = true;

    assert( tlset[0].value == true );
    assert( setting_updated == true );

    setting_updated = false;
    assert( setting_updated == false );

    tlset[0].value = false;

    assert( tlset[0].value == false );
    assert( setting_updated == true );

    bool excpt = false;
    try tlset[0].value = 10;
    catch( SettingException e ) excpt = true;
    assert( excpt );
}
