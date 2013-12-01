module engine.core.wsdata;

public import engine.core.layer;
public import engine.core.tempbuffer;
public import engine.core.setting;
public import desil;

interface WSData: SettingObject
{
    @property
    {
        imsize_t size() const;
        TempBuffer buffer();
        ImageFullAccess mask();
        ref Layer[] layers();
    }
}
