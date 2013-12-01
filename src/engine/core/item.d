module engine.core.item;

public import desil;

interface Item
{
    @property
    {
        wstring name() const;
        const(ImageReadAccess) pic() const;
    }
}
