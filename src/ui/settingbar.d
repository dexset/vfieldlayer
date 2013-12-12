module ui.settingbar;

import desgui;

import engine.core.setting;

import ui.slider;

class SettingBar : DiPanel
{
    this( DiWidget par, int h )
    {
        super(par, irect( 0, 0, 100, h ));

        auto tl = new DiLineLayout( DiLineLayout.Type.HORISONTAL );
        //tl.stretchInderect = false;
        tl.alignInderect = DiLineLayout.Align.START;
        tl.border = 5;
        tl.space = 5;
        layout = tl;
        size_lim.h.fix = true;
    }

    void loadSettings( Setting[] set )
    {
        clearChilds();
        //foreach( ch; childs )
        //    clear(ch);
        foreach( ref s; set )
        {
            final switch(s.type)
            {
                case( SettingType.VARIANT ): break;
                case( SettingType.BOOL ): break;
                case( SettingType.VEC2 ): break;
                case( SettingType.VEC3 ): break;
                case( SettingType.VEC4 ): break;
                case( SettingType.COL3 ): break;
                case( SettingType.COL4 ): break;
                case( SettingType.STRING ): break;
                case( SettingType.IMSIZE ): break;
                case( SettingType.IMTYPE ): break;
                case( SettingType.STRING_ARR ): break;
                case( SettingType.FLOAT_ARR ): break;
                case( SettingType.INT_ARR ): break;

                case( SettingType.INT ): break;
                case( SettingType.FLOAT ):
                    import std.conv;
                    auto w = new DiSlider( this, to!wstring(s.name), ivec2( 200, 50 ) );
                    auto cc = cast(TypeSetting!float)(s);
                    w.curr = cc.typeval;
                    w.min = s.permissiveRange.get!(const(float []))[0];
                    w.max = s.permissiveRange.get!(const(float []))[1];
                    w.step = 1;
                    w.update.connect({ cc.typeval = w.curr; });
                break;
            }
        }
        relayout();
        update();
    }
}
