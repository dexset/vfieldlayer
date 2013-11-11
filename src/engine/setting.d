module engine.setting;

import std.variant;

import engine.item;

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

interface Setting
{
    @property 
    {
        wstring name() const;
        SettingType type() const;
        Variant defaultValue() const;
        Variant permissiveRange() const;

        Variant value() const;
        void value( Variant );
    }
}

interface SettingObject: Item
{
    Setting[] getSettingsList() const;
    void setSetting( wstring name, Variant val );
}

class BoolSetting: Setting
{
    private bool val = false;

    public @property
    {
        abstract wstring name() const;

        final SettingType type() const
        { return SettingType.BOOL; }

        Variant defaultValue() const
        { return Variant(false); }

        final Variant permissiveRange() const
        { return Variant([false,true]); }

        Variant value() const
        { return Variant( val ); }

        void value( Variant v )
        {
            if( v.hasValue )
            {
                assert( v.type == typeid(bool) );
                val = v.get!bool();
            }
            else val = false;
        }
    }
}
