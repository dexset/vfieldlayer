module engine.core.setting;

public import std.variant;
public import desutil.signal;

import engine.core.item;

enum SettingType
{
    BOOL,
    INT,
    FLOAT,
    VEC2,
    VEC3,
    VEC4,
    COL3,
    COL4,
    STR,

    STR_ARR,
    INT_ARR,
    FLOAT_ARR,
}

alias Signal!Variant VarSignal;

class SettingException: Exception { @safe pure nothrow this( string msg ){ super(msg); } }

interface Setting
{
    protected ref VarSignal getUpdateSignal();

    @property 
    {
        wstring name() const;
        SettingType type() const;
        Variant defaultValue() const;
        Variant permissiveRange() const;

        Variant value() const;

        void value(T)( T val ) { (getUpdateSignal())( Variant(val) ); }
    }

    void updateConnect( void delegate(Variant) );
}

interface SettingObject: Item { Setting[] getSettings(); }

class TypeSetting(T): Setting
{
private:
    VarSignal sig_update;
    wstring s_name;

    final void update_hook( Variant v )
    {
        if( v.hasValue )
        {
            if( v.type != typeid(T) )
                throw new SettingException( "bad value type" );
            s_val = v.get!T();
        }
    }

protected:

    T s_val;
    ref VarSignal getUpdateSignal(){ return sig_update; }

public:
    this( wstring Name )
    {
        s_name = Name;
        sig_update.connect( &update_hook );
        sig_update( defaultValue );
    }

    @property
    {
        final 
        {
            wstring name() const { return s_name; }

            Variant value() const { return Variant( s_val ); }

            T typeval() const { return s_val; }

            void typeval( T nv )
            {
                s_val = nv;
                sig_update( Variant( nv ) );
            }
        }

        abstract
        {
            SettingType type() const;
            Variant defaultValue() const;
            Variant permissiveRange() const;
        }
    }

    final void updateConnect( void delegate(Variant) d ) { sig_update.connect( d ); }
}

class BoolSetting: TypeSetting!bool
{
    this( wstring Name ) { super( Name ); }

    override @property
    {
        final SettingType type() const { return SettingType.BOOL; }
        Variant defaultValue() const { return Variant(false); }
        final Variant permissiveRange() const { return Variant([false,true]); }
    }
}

unittest
{
    Setting val = new BoolSetting( "test" );

    bool val_update = false;
    val.updateConnect( (v) { val_update = true; } );

    assert( val.name == "test" );
    assert( val.value == false );
    assert( val_update == false );

    val.value = true;

    assert( val.value == true );
    assert( val_update == true );

    val_update = false;
    assert( val_update == false );

    val.value = false;
    assert( val.value == false );
    assert( val_update == true );

    val_update = false;
    bool excpt = false;
    try val.value = 10;
    catch( SettingException e ) excpt = true;
    assert( excpt );
    assert( val_update == false );

    auto bval = cast(BoolSetting)val;
    assert( bval !is null );
    
    bval.typeval = true;
    assert( bval.value == true );
    assert( bval.typeval == true );
    assert( val_update == true );
}
