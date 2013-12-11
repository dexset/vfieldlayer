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
        const(ImageReadAccess) image() const;
        ImageFullAccess image();
    }

    void move( in ivec2 );
    void setPos( in ivec2 );
}
