module engine.item;

import engine.image;

interface Item
{
    @property
    {
        wstring name() const;
        const(Image) pic() const;
    }
}
