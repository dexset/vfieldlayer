module engine.workspace;

import engine.core.viewport;
import engine.core.wsdata;
import engine.core.history;
import engine.core.setting;

import std.variant;
import desutil.helpers;

class Workspace: Viewport, WSData, TempBuffer
{
private:
    ivec2 vp_offset = ivec2(0,0);
    float vp_zoom = 1.0f;

    lim_t!float vp_zoom_lim = lim_t!float( 0.001, 10000 );

    Image mask_img;

    class MaskFA: ImageFullAccess
    { 
        @property ref const(Image) selfImage() const { return mask_img; } 
        protected void accessHook( size_t x, size_t y ){}
        protected @property ref Image selfImage() { return mask_img; } 
    }

    MaskFA mask_access;

    class TempFA: ImageFullAccess
    {
        Image ti;
        this( imsize_t sz, ImageType tp ) { ti.allocate( sz, tp ); }
        @property ref const(Image) selfImage() const { return ti; } 
        protected void accessHook( size_t x, size_t y ){}
        protected @property ref Image selfImage() { return ti; }
    }

    TempFA[ImageType] temp_list;

    Layer[] layers_list;

    string ws_name;

    bool sel = false;

public:

    this( string Name, in imsize_t sz )
    {
        ws_name = Name;
        mask_img.allocate( sz, ImageType( ImCompType.NORM_FLOAT, 1 ) );
        mask_access = new MaskFA;
    }

    @property
    {
        string name() const { return ws_name; }
        const(ImageReadAccess) pic() const { return null; }

        ivec2 offset() const { return vp_offset; }
        void offset( in ivec2 o ) { vp_offset = o; }

        float zoom() const { return vp_zoom; }
        void zoom( float z ) { vp_zoom = vp_zoom_lim( vp_zoom, z ); }

        imsize_t size() const { return mask_img.size; }

        TempBuffer buffer() { return this; }

        ImageFullAccess mask() { return mask_access; }

        ref Layer[] layers() { return layers_list; }

        bool select() const { return sel; }
        void select( bool s ) { sel = s; }
    }

    Setting[] getSettings() { return []; }
    Setting[] getSelectLayersSettings() { return []; }

    // TempBuffer
    ImageFullAccess[] getTempImages( in ImageType[] it_list )
    {
        ImageFullAccess[] ret;
        foreach( it; it_list )
            if( it in temp_list )
                ret ~= (temp_list[it]);
            else
            {
                auto buf = new TempFA( size, it );
                temp_list[it] = buf;
                ret ~= buf;
            }
        return ret;
    }

    void clearTempImages() { foreach( it, img; temp_list ) img.clear(); }

    void selectLayer( Layer sl, bool multi=false )
    {
        if( sl is null ) return;
        foreach( l; layers_list )
            if( multi )
            {
                if( l == sl ) l.select = !l.select;
            }
            else
            {
                if( l == sl ) l.select = true;
                else l.select = false;
            }
    }
}

unittest
{
    import std.stdio;

    auto ws = new Workspace( "test workspace", imsize_t( 40, 40 ) );
    assert( ws.size == imsize_t( 40, 40 ) );

    ws.offset = ivec2( 10, 15 );
    assert( ws.offset == ivec2( 10, 15 ) );

    ws.zoom = 0;
    assert( ws.zoom == 0.001f );

    auto tb = ws.buffer;

    auto tmp_img = tb.getTempImages( [ ImageType( ImCompType.NORM_FLOAT, 1 ) ] );
    assert( tmp_img[0].size == imsize_t( 40,40 ) );
    tmp_img[0].access!float(10,10) = 0.2;
    assert( tmp_img[0].read!float(10,10) == 0.2f );
    tb.clearTempImages();
    assert( tmp_img[0].read!float(10,10) == 0.0f );
}
