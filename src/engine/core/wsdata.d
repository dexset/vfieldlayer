module engine.core.wsdata;

public import engine.core.layer;
public import engine.core.tempbuffer;
public import engine.core.image;
public import engine.core.setting;

interface WSData: SettingObject
{
    @property
    {
        imsize_t size() const;
        TempBuffer buffer();
        Image mask();
        ref Layer[] layers();
    }
}
