module engine.core.drawtool;

import engine.core.action;
import engine.core.tool;
public import engine.core.programiface;

interface DrawTool: Action, Tool
{
    void setPI( PIDrawTool );
}
