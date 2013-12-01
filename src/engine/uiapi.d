module engine.uiapi;

public
{
    import engine.core.tool;
    import engine.core.layer;
}

interface UIAPI
{
    void setToolList( Tool[] );
    void setLayers( Layer[] );
    void updateViewImage( in Image );
    void updateViewPos( in ivec2 offset, float scale );

    void update();
}
