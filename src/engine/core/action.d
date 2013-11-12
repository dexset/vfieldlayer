module engine.core.action;

public import engine.core.history;
import engine.core.setting;

interface Action: SettingObject
{
    HistoryItem apply();
}
