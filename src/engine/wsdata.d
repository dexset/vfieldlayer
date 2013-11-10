module engine.wsdata;

import engine.layer;
import engine.tempbuffer;
import engine.image;

interface WSData
{
    @property
    {
        imsize size() const;
        TempBuffer buffer();
        ref Image mask();
        Layer[] layers();
    }
}
