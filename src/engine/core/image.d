module engine.core.image;

import std.exception;

public import desmath.types.vector;
public import desmath.types.rect;

alias vec!(2,size_t,"wh") imsize_t;
alias vec!(2,size_t,"xy") imcrd_t;

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

class ImageException : Exception 
{ @safe pure nothrow this( string msg ){ super( msg ); } }

final class Image
{
private:
    ubyte[] data;

    imsize_t imsize;

    ImageType imtype;
    size_t elemSize;

    imcrd_t min, max;

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
    }

    pure void setParams(T)( in imsize_t sz )
    {
        imsize = sz;
        elemSize = T.sizeof;
        imtype.comp = ComponentType.RAWBYTE;
        imtype.channels = cast(ubyte)elemSize;
    }

    pure void allocateData() { data = new ubyte[ elemSize * imsize.w * imsize.h ]; }

public:
    pure this( in imsize_t sz, in ImageType imtp, in ubyte[] dt = null ) 
    { 
        if( dt is null || dt.length == 0 ) allocate( sz, imtp );
        else
        {
            setParams( sz, imtp );
            if( dt.length != sz.w * sz.h * elemSize )
                throw new ImageException( "wrong input data length" );
            data = dt.dup;
            resetAccessRect();
        }
    }

    pure this(T)( in imsize_t sz, in T[] dt ) 
    { 
        setParams!T( sz );
        if( dt.length != sz.w * sz.h )
            throw new ImageException( "wrong input data length" );
        data = cast(ubyte[])dt.dup;
        resetAccessRect();
    }

    pure this( in Image img ) { copy( img ); }

    pure void copy( in Image img )
    {
        setParams( img.imsize, img.imtype );
        data = img.data.dup;
        resetAccessRect();
    }

    pure void allocate( in imsize_t sz, in ImageType imtp, in ubyte[] dt = null )
    {
        setParams( sz, imtp );
        if( dt is null || dt.length == 0 ) allocateData();
        else data = dt.dup;
        resetAccessRect();
    }

    void allocateRaw(T)( in imsize_t sz, in T[] dt = null )
    {
        setParams!T( sz );
        if( dt is null || dt.length == 0 ) allocateData();
        else data = cast(ubyte[])dt.dup;
        resetAccessRect();
    }

    void clearLastChanges()
    {
        auto ar = accessRect;
        if( ar == irect( size.w,size.h,-size.w+1,-size.h+1 ) )
            return;

        foreach( y; ar.y .. ar.y + ar.h )
        {
            foreach( ref v; data[ ( imsize.w * y + ar.x ) * elemSize .. 
                                  ( imsize.w * y + ar.x + ar.w ) * elemSize ] )
                v = 0;
        }

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

    ref T access(T)( in imcrd_t pos ) { return access!T( pos.x, pos.y ); }
    ref T access(T)( size_t x, size_t y ) 
    { 
        if( T.sizeof != elemSize )
            throw new ImageException( "access type size uncompatible with elem size" );
        size_t ind = imsize.w * y + x;
        if( ind >= imsize.w * imsize.h )
            throw new ImageException( "Range violation" );

        if( min.x > x ) min.x = x;
        if( min.y > y ) min.y = y;

        if( max.x < x ) max.x = x;
        if( max.y < y ) max.y = y;

        return (cast(T[])(data))[ ind ];
    }

    T read(T)( in imcrd_t pos ) const { return read!T( pos.x, pos.y ); }
    T read(T)( size_t x, size_t y ) const
    {
        if( T.sizeof != elemSize )
            throw new ImageException( "read type size uncompatible with elem size" );
        size_t ind = imsize.w * y + x;
        if( ind >= imsize.w * imsize.h )
            throw new ImageException( "Range violation" );

        return (cast(T[])(data))[ ind ];
    }

    @property T[] dup(T)() const 
    { 
        if( T.sizeof != elemSize )
            throw new ImageException( "dup type size uncompatible with elem size" );
        return cast(T[])data.dup; 
    }

    void setData(T)( in T[] ndata )
    {
        if( T.sizeof != elemSize )
            throw new ImageException( "setData type size uncompatible with elem size" );
        if( ndata.length != imsize.w * imsize.h )
            throw new ImageException( "bad set data length" );
        data = cast(ubyte[])ndata.dup;
        min = imcrd_t( 0, 0 );
        max = imcrd_t( imsize.w - 1, imsize.h - 1 );
    }
}

unittest
{
    auto img = new Image( imsize_t(3,3), ImageType( ComponentType.NORM_FLOAT, 3 ) );
    img.access!col3( 1, 1 ) = col3( 0.1, 0.2, 0.3 );
    auto val1 = img.read!col3( 1, 1 );
    auto val2 = img.read!vec3( 1, 1 );
    assert( val1 == col3( 0.1, 0.2, 0.3 ) );
    assert( is( typeof(val1) == col3 ) );
    assert( val2 == vec3( 0.1, 0.2, 0.3 ) );

    auto data = img.dup!col3;
    assert( data[4] == col3( 0.1, 0.2, 0.3 ) );

    assert( img.accessRect == irect( 1,1, 1,1 ) );
    img.access!col3( 1, 2 ) = col3( 0.8, 0.7, 0.6 );
    assert( img.accessRect == irect( 1,1, 1,2 ) );

    auto except = false;
    try img.access!col4( 1, 2 ) = col4( 0.0, 0.7, 0.6 );
    catch( Exception e ) except = true;
    assert( except );

    except = false;
    try img.access!col3( 3,4 );
    catch( Exception e ) except = true;
    assert( except );

    img.resetAccessRect();
    assert( img.accessRect == irect( img.size.w,img.size.h,-img.size.w+1,-img.size.h+1 ) );

    img.allocateRaw!vec2( imsize_t( 10, 10 ) );
    img.access!vec2( 2, 1 ) = vec2( 10, 15 );
    auto vdata = img.dup!vec2;
    assert( vdata[12] == vec2( 10, 15 ) );

    auto img2 = new Image( img );
    img2.copy( img );
    img.access!vec2( 2, 1 ) = vec2( 1, 1.4 );
    assert( img2.read!vec2( 2, 1 ) == vec2( 10, 15 ) );

    auto img3 = new Image( img );
    assert( img3.read!vec2( 2, 1 ) == vec2( 1, 1.4 ) );

    img3.resetAccessRect();
    img3.access!vec2( 1, 1 ) = vec2( 3.141592, 2.718281828 );
    assert( img3.read!vec2( 1, 1 ) == vec2( 3.141592, 2.718281828 ) );
    assert( img3.read!vec2( 2, 1 ) == vec2( 1, 1.4 ) );
    img3.clearLastChanges();
    assert( img3.read!vec2( 1, 1 ) == vec2( 0, 0 ) );
    assert( img3.read!vec2( 2, 1 ) == vec2( 1, 1.4 ) );

    auto arr = img3.read!(float[2])( 2, 1 );
    assert( arr[0] == 1 );
    assert( arr[1] == 1.4f );

    auto fimg = new Image( imsize_t( 40, 40 ), ImageType( ComponentType.NORM_FLOAT, 1 ) );
    assert( fimg.size == imsize_t( 40,40 ) );
    fimg.access!float(10,10) = 0.2;

    assert( fimg.read!float(10,10) == 0.2f );
    fimg.clearLastChanges();
    assert( fimg.read!float(10,10) == 0.0f );
}

unittest
{
    bool except = false;
    try
    {
        vec3[] emptyData;
        auto img = new Image( imsize_t( 3, 3 ), emptyData );
    } catch( Exception e ) { except = true; }
    assert( except );

    auto data = [
        vec3( 1,0,0 ), vec3( 0.1,0.2,0 ), vec3( 0,0,0 ),
        vec3( 0,0,0 ), vec3( 0,1,0 ), vec3( 0,0,0 ),
        vec3( 0,0,0 ), vec3( 0,0,0 ), vec3( 0,0,1 )
        ];
    auto img2 = new Image( imsize_t( 3, 3 ), data );

    assert( img2.read!col3(1,0) == col3( 0.1, 0.2, 0 ) );

    auto retdata = img2.dup!vec3;
    assert( retdata == data );

    data[3] = vec3( 1,1,0 );
    img2.setData( data );
    assert( img2.read!vec3(0,1) == vec3( 1,1,0 ) );
    assert( img2.accessRect == irect(0,0,img2.size.w,img2.size.h) );
}
