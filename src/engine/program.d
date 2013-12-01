module engine.program;

import engine.core.programiface;

import engine.core.tempbuffer;
import engine.core.viewport;
import engine.core.wsdata;

import engine.workspace;
import engine.uiapi;

class Program: PIFilter, PIDrawTool, PIViewTool
{
    Workspace current_ws;

public:

    TempBuffer getTempBuffer() { return current_ws; }
    WSData getWorkspace() { return current_ws; }
    Viewport getViewport() { return current_ws; }
}

//class Program
//{
//protected:
//    UIAPI uiapi;
//
//    Workspace[] workspaces;
//    Workspace current_ws;
//
//public:
//    this( UIAPI i2i )
//    {
//        uiapi = i2i;
//    }
//}
