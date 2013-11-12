module engine.imagelayer;

import engine.core.item;
import engine.core.setting;
import engine.core.layer;

import engine.setting;

class ImageLayer: Layer
{
private:
    Image data;
    ivec2 pos = ivec2(0,0);
    wstring l_name;

    bool is_selected = false;

    BoolSetting visible;

public:

    this( wstring Name, in imsize_t sz, in ImageType it )
    {
        data = new Image( sz, it );
        l_name = Name;

        visible = new BoolSetting( "visible" );
        visible.typeval = true;
    }

    @property
    {
        wstring name() const { return l_name; }
        const(Image) pic() const { return data; }

        irect bbox() const { return irect( pos, data.size ); }
        Image image() { return data; }

        bool select() const { return is_selected; }
        void select( bool s ) { is_selected = s; }
    }

    void move( in ivec2 m ) { pos += m; }
    void setPos( in ivec2 p ) { pos = p; }

    Setting[] getSettings()
    {
        return [ visible ];
    }
}

unittest
{
    auto il = new ImageLayer( "test layer", imsize_t( 800, 600 ), 
            ImageType( ComponentType.NORM_FLOAT, 1 ) );

    auto ss = il.getSettings();

    assert( ss[0].value == true );
    ss[0].value = false;

    auto ss2 = il.getSettings();
    assert( ss2[0].value == false );
    assert( ss[0].value == false );

    ss2 ~= new BoolSetting( "okda" );
    auto ss3 = il.getSettings();
    assert( ss3.length == ss.length );
    assert( ss3[0].name == "visible" );

    il.move( ivec2(10,15) );
    assert( il.bbox == irect( 10, 15, 800, 600 ) );

    auto pic = il.pic;
    assert( pic.size == imsize_t( 800, 600 ) );
    assert( !__traits(compiles, pic.access!float( 10, 10 ) ) );
    assert( __traits(compiles, pic.read!float( 10, 10 ) ) );

    auto img = il.image;
    img.access!float( 10, 10 ) = 0.1f;
    assert( pic.read!float(10,10) == 0.1f );
}
