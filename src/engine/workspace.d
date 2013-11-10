module engine.workspace;

import engine.viewport;
import engine.wsdata;

import desgui.base.widget;

class Workspace: Viewport, WSData
{
private:
    ivec2 vp_offset = ivec2(0,0);
    float vp_scale = 1.0f;
    lim_t!float vp_scale_lim = lim_t!float( 0.001, 10000 );

    Image mask_img;

    Layer[] layersList;

public:

    @property
    {
        ivec2 offset() const { return vp_offset; }
        void offset( in ivec2 o ) { vp_offset = o; }

        float scale() const { return vp_scale; }
        void scalse( float sc ) { vp_scale = vp_scale_lim( vp_scale, sc ); }
    }

    @property
    {
        imsize_t size() const
        {
            return mask_img.size;
        }

        TempBuffer buffer()
        {
            return null;
        }

        ref Image mask()
        {
            return mask_img;
        }

        Layer[] layers()
        {
            return layersList;
        }
    }
}
