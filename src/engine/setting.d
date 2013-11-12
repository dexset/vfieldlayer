module engine.setting;

import std.variant;
import std.exception;

import engine.item;

import desutil.signal;

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

interface SettingObject: Item { Setting[] getSettingsList(); }

class BoolSetting: Setting
{
    private bool val = false;
    private VarSignal sig_update;

    protected ref VarSignal getUpdateSignal() { return sig_update; }

    public @property
    {
        this()
        {
            sig_update.connect( (Variant v)
            {
                if( v.hasValue )
                {
                    if( v.type != typeid(bool) )
                        throw new SettingException( "bad value type" );
                    val = v.get!bool();
                }
                else val = false;
            });
        }

        abstract wstring name() const;

        final SettingType type() const
        { return SettingType.BOOL; }

        Variant defaultValue() const
        { return Variant(false); }

        final Variant permissiveRange() const
        { return Variant([false,true]); }

        Variant value() const
        { return Variant( val ); }
    }

    void updateConnect( void delegate(Variant) d ) { sig_update.connect( d ); }
}
