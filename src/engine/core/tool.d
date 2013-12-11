module engine.core.tool;

public import desmath.types.vector;
public import desil;
public import desgui.base.event;
import engine.core.setting;

interface Tool: SettingObject
{
    const(ImageReadAccess) cursor() const;
    void activate();
    void deactivate();
    void mouse_eh( in vec2 mpos, in DiMouseEvent me );
    void keyboard_eh( in vec2 mpos, in DiKeyboardEvent ke );
}
