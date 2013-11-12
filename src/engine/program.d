module engine.program;

import engine.core.programiface;

import engine.core.tempbuffer;
import engine.core.viewport;
import engine.core.wsdata;

import engine.workspace;

class Program: PIFilter, PIDrawTool, PIViewTool
{
private:

    Workspace[] workspaces;
    Workspace current_ws;

public:

    TempBuffer getTempBuffer() { return current_ws; }
    WSData getWorkspace() { return current_ws; }
    Viewport getViewport() { return current_ws; }
}
