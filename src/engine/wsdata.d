module engine.wsdata;

public import engine.layer;
public import engine.tempbuffer;
public import engine.image;
public import engine.setting;

interface WSData: SettingObject
{
    @property
    {
        imsize_t size() const;
        TempBuffer buffer();
        Image mask();
        Layer[] layers();
    }
}
