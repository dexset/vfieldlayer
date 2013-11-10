module engine.image;

import desmath.types.vector;
import desmath.types.rect;

alias vec!(2,size_t,"wh") imsize_t;

enum ComponentType
{
    RAWBYTE,
    UBYTE,
    FLOAT,
    NORM_FLOAT
}

struct ImageType
{
    ComponentType comp;
    ubyte channels;
}

struct Image
{
private:
    ubyte[] data;

    imsize_t imsize;

    ImageType imtype;
    size_t elemSize;
    //TypeInfo rawtype = null;

    imsize_t min, max;

    pure void setParams( in imsize_t sz, in ImageType imtp )
    {
        imsize = sz;
        imtype = imtp;
        size_t compSize;
        final switch( imtype.comp )
        {
            case ComponentType.RAWBYTE:
            case ComponentType.UBYTE:
                compSize = ubyte.sizeof;
                break;
            case ComponentType.FLOAT:
            case ComponentType.NORM_FLOAT:
                compSize = float.sizeof;
                break;
        }
        elemSize = compSize * imtype.channels;
        //rawtype = null;
    }

    void setParams(T)( in imsize_t sz )
    {
        imsize = sz;
        elemSize = T.sizeof();
        imtype.comp = ComponentType.RAWBYTE;
        imtype.channels = elemSize;
        //rawtype = typeid( T );
    }

    pure void allocateData() { data = new ubyte[ elemSize * imsize.w * imsize.h ]; }

public:
    pure this( in imsize_t sz, in ImageType imtp ) { allocate( sz, imtp ); }

    pure this( in imsize_t sz, in ImageType imtp, in ubyte[] dt ) 
    { 
        setParams( sz, imtp );
        data = dt.dup;
        resetAccessRect();
    }

    pure this( in Image img ) { copy( img ); }

    pure void copy( in Image img )
    {
        setParams( img.imsize, img.imtype );
        data = img.data.dup;
        //rawtype = new TypeInfo( img.rawtype );
        resetAccessRect();
    }

    pure void allocate( in imsize_t sz, in ImageType imtp )
    {
        setParams( sz, imtp );
        allocateData();
        resetAccessRect();
    }

    void allocateRaw(T)( in imsize_t sz )
    {
        setParams!T( sz );
        allocateData();
        resetAccessRect();
    }

    @property irect accessRect() const
    {
        return irect( min, max - min + ivec2(1,1) );
    }

    @property imsize_t size() const { return imsize; }
    @property ImageType type() const { return imtype; }

    pure void resetAccessRect()
    {
        min = imsize_t( imsize.w, imsize.h );
        max = imsize_t( 0, 0 );
    }

    ref T access(T)( in imsize_t pos )
    {
        if( min.x > pos.x ) min.x = pos.x;
        if( min.y > pos.y ) min.y = pos.y;
        if( max.x < pos.x ) max.x = pos.x;
        if( max.y < pos.y ) max.y = pos.y;

        return *( cast(T*)( data.ptr + ( imsize.w * pos.y + pos.x ) * T.sizeof() ) );
    }

    ref T access(T)( size_t x, size_t y ) { return access!T( imsize_t(x,y) ); }

    @property T[] dup(T=ubyte)() const { return cast(T[])data.dup; }
}

unittest
{
    auto img = Image( imsize_t(800,600), ImageType( ComponentType.NORM_FLOAT, 3 ) );

}
