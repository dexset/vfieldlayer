module engine.drawtool;

import engine.action;
import engine.tool;
import engine.programiface;

interface DrawTool: Action, Tool
{
    void setPI( PIDrawTool );
}
