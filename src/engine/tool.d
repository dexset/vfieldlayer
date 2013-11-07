module engine.tool;

import desmath.types.vector;
import desmath.types.map;

import engine.setting;

import desgui.base.event;

alias map!(2,"wh",float) grayImg;

interface Tool
{
    @property string name() const;
    immutable(grayImg) icon() const;
    immutable(grayImg) sursor() const;
    void activate();
    void deactivate();
    void mouse_eh( in ivec2 mpos, in MouseEvent me );
    void keyboard_eh( in ivec2 mpos, in KeyboardEvent ke );

    Setting[] getSettingList() const;
    void setSetting( Setting val );
}
