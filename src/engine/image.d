module engine.image;

import desmath.types.vector;

alias vec!(2,size_t,"wh") imsize_t;

enum ComponentType
{
    UBYTE,
    FLOAT,
    NORM_FLOAT
}

struct ImageType
{
    ComponentType comp;
    ubyte channels;
}

struct Image
{
    imsize_t size;
    ImageType type;

    ubyte[] data;
}
