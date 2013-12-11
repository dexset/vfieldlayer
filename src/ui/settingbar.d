module ui.settingbar;

import desgui;

class SettingBar : DiPanel
{
    this( DiWidget par, int h )
    {
        super(par, irect( 0, 0, 100, h ));

        auto tl = new DiLineLayout( DiLineLayout.Type.VERTICAL );
        tl.stretchInderect = false;
        tl.alignInderect = DiLineLayout.Align.START;
        tl.border = 5;
        tl.space = 5;
        layout = tl;
        size_lim.h.fix = true;
    }
}
