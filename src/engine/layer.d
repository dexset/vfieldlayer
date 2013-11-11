module engine.layer;

import engine.setting;
import engine.image;

import desmath.types.rect;

interface Layer: SettingObject
{
    @property
    {
        irect bbox() const;
        Image image();

        bool select() const;
        void select( bool );
    }
}
