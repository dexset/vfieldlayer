module engine.core.layer;

public import desil;
public import engine.core.setting;
public import desmath.types.vector;
public import desmath.types.rect;

interface Layer: SettingObject
{
    @property
    {
        irect bbox() const;
        ImageFullAccess image();

        bool select() const;
        void select( bool );
    }

    void move( in ivec2 );
    void setPos( in ivec2 );
}
