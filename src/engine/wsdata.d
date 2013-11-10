module engine.wsdata;

public import engine.layer;
public import engine.tempbuffer;
public import engine.image;

interface WSData
{
    @property
    {
        imsize_t size() const;
        TempBuffer buffer();
        ref Image mask();
        Layer[] layers();
    }
}
