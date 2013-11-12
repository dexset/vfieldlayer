module engine.core.programiface;

import engine.core.tempbuffer;
import engine.core.wsdata;
import engine.core.viewport;

interface PIDrawTool
{
    TempBuffer getTempBuffer();
    //vec2[2] getCurrentVectors();
    //col4[2] getCurrentColors();
}

interface PIFilter
{
    WSData getWorkspace();
}

interface PIViewTool
{
    Viewport getViewport();
}
