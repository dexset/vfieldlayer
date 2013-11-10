module engine.layer;

import engine.setting;

import desmath.types.rect;

interface Layer: SettingObject
{
    @property
    {
        irect bbox() const;
        ref Image image();

        // TODO: const ref
        Image pic() const;

        bool select() const;
        void select( bool );
    }
}
