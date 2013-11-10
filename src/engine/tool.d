module engine.tool;

import desmath.types.vector;
import desmath.types.map;

import engine.setting;
import engine.image;

import desgui.base.event;

interface Tool: SettingObject
{
    immutable(Image) icon() const;
    immutable(Image) cursor() const;
    void activate();
    void deactivate();
    void mouse_eh( in ivec2 mpos, in MouseEvent me );
    void keyboard_eh( in ivec2 mpos, in KeyboardEvent ke );
}
