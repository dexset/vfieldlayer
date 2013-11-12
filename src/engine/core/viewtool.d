module engine.coreviewtool;

import engine.core.tool;
public import engine.core.programiface;

interface ViewTool: Tool
{
    void setPI( PIViewTool );
}
