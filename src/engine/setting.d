module engine.setting;

import std.variant;

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
    STRARR,
    INTARR
}

interface Setting
{
    @property 
    {
        string name() const;
        SettingType type() const;
        Variant defaultValue() const;
        Variant permissiveRange() const;

        Variant value() const;
        void value( Variant );
    }
}

class BoolSetting: Setting
{
    private bool val = false;

    public @property
    {
        abstract string name() const;

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
