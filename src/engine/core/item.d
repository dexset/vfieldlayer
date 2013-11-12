module engine.core.item;

public import engine.core.image;

interface Item
{
    @property
    {
        wstring name() const;
        const(Image) pic() const;
    }
}
