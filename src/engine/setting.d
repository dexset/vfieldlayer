module engine.setting;

import engine.core.setting;

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
