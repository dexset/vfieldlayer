module engine.core.program;

import engine.core.item;
import engine.core.setting;

import desgui.base.event;

class ProgramException: Exception
{ @safe pure nothrow this( string msg ) { super(msg); } }

interface Program
{
    enum ItemType
    {
        TOOL,
        LAYER,
        WORKSPACE
    }

    enum SettingType
    {
        TOOL,
        LAYER,
        WORKSPACE
    }

    enum CreateType
    {
        LAYER,
        WORKSPACE
    }

    Item[] getList( ItemType );
    Setting[] getSettings( SettingType );

    void clickOnItem( ItemType, Item );
    void create( CreateType, Variant[string] );

    void mouse_eh( in vec2, in DiMouseEvent );
    void keyboard_eh( in vec2, in DiKeyboardEvent );
}
