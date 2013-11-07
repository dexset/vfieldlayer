module engine.action;

import engine.setting;
import engine.history;

interface Action
{
    @property string name() const;

    Setting[] getSettingList() const;
    void setSetting( Setting val );

    HistoryDelta apply();
}
