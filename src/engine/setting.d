module engine.setting;

import engine.core.setting;

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
        final wstring name() const { return s_name; }

        Variant value() const { return Variant( s_val ); }
        T typeval() const { return s_val; }

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
