module engine.programiface;

import engine.tempbuffer;
import engine.wsdata;
import engine.viewport;

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
