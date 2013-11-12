module engine.viewtool;

import engine.tool;
import engine.programiface;

interface ViewTool: Tool
{
    void setPI( PIViewTool );
}
