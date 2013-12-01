module engine.core.viewport;

public import desmath.types.vector;

interface Viewport
{
    @property
    {
        ivec2 offset() const;
        void offset( in ivec2 );

        float zoom() const;
        void zoom( float );
    }
}
