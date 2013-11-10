module engine.viewport;

import desmath.types.vector;

interface Viewport
{
    @property
    {
        ivec2 offset() const;
        void offset( ivec2 );

        float scale() const;
        void scalse( float );
    }
}
