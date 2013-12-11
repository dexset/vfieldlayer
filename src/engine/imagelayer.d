module engine.imagelayer;

import engine.core.item;
import engine.core.setting;
import engine.core.layer;
import engine.core.setting;

class ImageLayer: Layer
{
private:
    Image img;
    ivec2 pos = ivec2(0,0);
    string l_name;

    bool is_selected = false;

    BoolSetting visible;

    class IRA: ImageReadAccess
    { const @property ref const(Image) selfImage() { return img; } }

    class IFA: ImageFullAccess
    { 
        @property ref const(Image) selfImage() const { return img; } 
        protected void accessHook( size_t x, size_t y ){}
        protected @property ref Image selfImage() { return img; } 
    }

    IRA pic_access;
    IFA img_access;

public:

    this( string Name, in irect rt, in ImageType it )
    {
        img.allocate( imsize_t(rt.size), it );
        l_name = Name;

        pos = rt.pos;

        visible = new BoolSetting( "visible" );
        visible.typeval = true;

        pic_access = new IRA;
        img_access = new IFA;
    }

    this( string Name, in imsize_t sz, in ImageType it )
    { this( Name, irect(0,0,sz), it ); }

    @property
    {
        string name() const { return l_name; }
        const(ImageReadAccess) pic() const { return pic_access; }

        irect bbox() const { return irect( pos, img.size ); }
        ImageFullAccess image() { return img_access; }
        const(ImageReadAccess) image() const { return img_access; }

        bool select() const { return is_selected; }
        void select( bool s ) { is_selected = s; }
    }

    void move( in ivec2 m ) { pos += m; }
    void setPos( in ivec2 p ) { pos = p; }

    Setting[] getSettings() { return [ visible ]; }
}

unittest
{
    auto il = new ImageLayer( "test layer", imsize_t( 800, 600 ), 
            ImageType( ImCompType.NORM_FLOAT, 1 ) );

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
