module engine.tempbuffer;

public import engine.image;

interface TempBuffer
{
    @property imsize_t size() const;
    Image[] getTempImages( in ImageType[] );
    void clearTempImages();
}
