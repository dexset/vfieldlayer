module engine.action;

import engine.setting;
import engine.history;

import std.variant;

interface Action: SettingObject
{
    HistoryItem apply();
}
