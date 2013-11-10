module engine.tempbuffer;

import engine.image;

interface TempBuffer
{
    @property imsize_t size() const;
    Image[] getTempImage( ImageType[] );
}
