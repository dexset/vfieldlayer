module engine.program;

import engine.core.tempbuffer;
import engine.core.viewport;
import engine.core.wsdata;

import engine.workspace;
import engine.uiapi;

class Program
{
protected:
    UIAPI uiapi;

    Workspace[] workspaces;
    Workspace current_ws;

public:
    this( UIAPI i2i )
    {
        uiapi = i2i;
    }
}
