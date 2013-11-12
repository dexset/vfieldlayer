module engine.core.tempbuffer;

public import engine.core.image;

interface TempBuffer
{
    @property imsize_t size() const;
    Image[] getTempImages( in ImageType[] );
    void clearTempImages();
}
