module engine.program;

import engine.programiface;

import engine.tempbuffer;
import engine.workspace;
import engine.viewport;
import engine.wsdata;

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
