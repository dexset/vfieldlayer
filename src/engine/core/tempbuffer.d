module engine.core.tempbuffer;

public import desil;

interface TempBuffer
{
    @property imsize_t size() const;
    ImageFullAccess[] getTempImages( in ImageType[] );
    void clearTempImages();
}
