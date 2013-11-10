module engine.program;

import engine.programiface;

import engine.tempbuffer;
import engine.workspace;
import engine.viewport;

class Program: PIFilter, PIDrawTool, PIViewTool
{
    TempBuffer getTempBuffer()
    {
        return null;
    }

    Workspace getWorkspace()
    {
        return null;
    }

    Viewport getViewport()
    {
        return null;
    }
}
