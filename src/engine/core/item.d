module engine.core.item;

public import desil;

interface Item
{
    @property
    {
        string name() const;
        const(ImageReadAccess) pic() const;
    }
}
