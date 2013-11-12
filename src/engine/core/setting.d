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
