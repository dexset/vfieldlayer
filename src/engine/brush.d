module engine.brush;

import engine.core.tool;
import engine.core.wsdata;
import engine.core.setting;

import desil;

class BrushException : Exception
{ @safe pure nothrow this( string msg ) { super( msg ); } }

class BrushUserException : BrushException
{
    enum Reason
    {
        NONE,
        MULTIPLELAYER,
        NOLAYER,
        NOWORKSPACE,
        BADIMGTYPE
    }

    Reason reason;

    @safe pure nothrow this( string msg, Reason r = Reason.NONE ) 
    { 
        super( msg ); 
        reason = r; 
    } 
}

class Brush : Tool
{
protected:
    WSData delegate() retWS;

    Image icon;
    Image curs;

    string bname;
    ImageReadAccess icon_ira, curs_ira;
    WSData curws;
    PositiveFloatSetting size;

    bool sel = false;

public:
    this( string N, WSData delegate() rws )
    {
        if( rws is null ) throw new BrushException( "return wsdata delegate is null" );
        retWS = rws;
        bname = N;
        icon_ira = new PointerIRA( &icon );
        curs_ira = new PointerIRA( &curs );

        size = new PositiveFloatSetting( "size", 0, 200 );
    }

    @property
    {
        string name() const { return bname; }
        const(ImageReadAccess) pic() const { return icon_ira; }

        void select( bool s ) 
        { 
            sel = s; 
            if( s ) activate();
            else deactivate();
        }

        bool select() const { return sel; }
    }

    Setting[] getSettings()
    { return [ cast(Setting)size ]; }

    const(ImageReadAccess) cursor() const { return curs_ira; }

    void activate() { curws = retWS(); }

    void deactivate() { }

    abstract void mouse_eh( in vec2 mpos, in DiMouseEvent me );
    abstract void keyboard_eh( in vec2 mpos, in DiKeyboardEvent ke );
}

class TestColorBrush : Brush
{
protected:
    ColorSetting color;

    Layer work;
    bool draw_state = false;
    alias vec!(4,ubyte,"rgba") bcol4;

    void draw(T)( in vec2 mpos )
        if( is(T==ubyte) || is(T==float) )
    {
        auto sz = size.typeval;

        static if( is(T==ubyte) )
        {
            alias bcol4 trueColor;
            auto clr = bcol4( color.typeval * 255 );
        }
        else static if( is(T==float) )
        {
            alias col4 trueColor;
            auto clr = color.typeval;
        }

        auto lp = mpos - vec2(work.bbox.pos);

        for( float x = -sz; x < sz; x+=1 )
            for( float y = -sz; y < sz; y+= 1 )
            {
                if( x*x + y*y > sz ) continue;
                auto p = imcrd_t( lp.x+x, lp.y+y );
                if( ivec2(p) in work.bbox )
                work.image.access!trueColor(p) = clr;
            }
    }

public:
    this( WSData delegate() rws )
    {
        super( "color_brush", rws );
        color = new ColorSetting( "color" );
        color.typeval = col4(1,1,1,1);
        size.typeval = 10;

        import devilwrap;
        icon = loadImageFromFile( "data/images/brush.png" );
    }

    override
    {
        Setting[] getSettings()
        { return super.getSettings() ~ color; }

        void mouse_eh( in vec2 mpos, in DiMouseEvent me )
        {
            if( curws is null )
                throw new BrushUserException( "no current workspace", BrushUserException.Reason.NOWORKSPACE );

            if( me.type == me.Type.PRESSED && me.btn == me.Button.LEFT )
            {
                draw_state = true;
                work = null;
                auto ll = curws.layers;

                foreach( l; ll )
                {
                    if( l.select )
                    {
                        if( work is null ) work = l;
                        else throw new BrushUserException( "drawing on multiple layers are not available", 
                                BrushUserException.Reason.MULTIPLELAYER );
                    }
                }
                if( work.image.type.channels != 4 ) throw new BrushUserException( "bad layer image component count", BrushUserException.Reason.BADIMGTYPE );
            }
            else if( me.type == me.Type.RELEASED && me.btn == me.Button.LEFT )
            {
                draw_state = false;
                work = null;
            }

            if( draw_state )
            {
                if( work is null ) throw new BrushUserException( "no select layers", BrushUserException.Reason.NOLAYER );

                switch( work.image.type.comp )
                {
                    case ImCompType.UBYTE: draw!ubyte( mpos ); break;
                    case ImCompType.NORM_FLOAT: draw!float( mpos ); break;
                    default: throw new BrushUserException( "bad layer image type", 
                                     BrushUserException.Reason.BADIMGTYPE );
                }
            }
        }

        void keyboard_eh( in vec2 mpos, in DiKeyboardEvent ke ) { }
    }
}
