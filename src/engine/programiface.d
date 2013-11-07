module engine.programiface;

import engine.tempbuffer;
import engine.workspace;
import engine.viewport;

interface PIDrawTool
{
    TempBuffer getTempBuffer();
}

interface PIFilter
{
    Workspace getWorkspace();
}

interface PIViewTool
{
    Viewport getViewport();
}
