module engine.core.tool;

public import desmath.types.vector;
public import engine.core.image;
public import desgui.base.event;
import engine.core.setting;

interface Tool: SettingObject
{
    const(Image) cursor() const;
    const(Image) effectArea() const;
    void activate();
    void deactivate();
    void mouse_eh( in ivec2 mpos, in DiMouseEvent me );
    void keyboard_eh( in ivec2 mpos, in DiKeyboardEvent ke );
}
