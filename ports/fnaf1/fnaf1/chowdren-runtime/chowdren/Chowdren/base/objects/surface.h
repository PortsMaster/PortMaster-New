#ifndef CHOWDREN_SURFACE_H
#define CHOWDREN_SURFACE_H

#include "frameobject.h"
#include "image.h"
#include <string>
#include "color.h"
#include "fbo.h"

class Active;

struct SurfaceImage
{
    Image * handle;
    TransparentColor transparent;

    // Simulated - actually modifies bitmap
    int width, height; // Resize
    int canvas_width, canvas_height; // Resize (canvas)
    int scroll_x, scroll_y; // Scroll, resize canvas
    bool wrap; // Scroll
    bool has_reverse_x; // Reverse X

    SurfaceImage()
    {
    }

    // Create blank image with specified size
    void reset(int w = 0, int h = 0);
    void set_image(Image * image);

    int get_display_width()
    {
        if (handle == NULL)
            return width;
        return canvas_width * width / double(handle->width);
    }
    int get_display_height()
    {
        if (handle == NULL)
            return height;
        return canvas_height * height / double(handle->height);
    }
};

struct SurfaceBlit
{
    int x, y;
    int scroll_x, scroll_y;
    double scale_x, scale_y;
    Image * image;
    int effect;

    SurfaceBlit()
    {
    }
};

struct SurfacePoint
{
    int x, y;
};

struct SurfaceQuad
{
    SurfacePoint points[4];
    Color color;
};

struct SurfaceLine
{
    SurfacePoint points[2];
    Color color;
    int size;
};

class SurfaceObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(SurfaceObject)

    // Edit-time flags
    bool use_blur;
    bool display_selected;
    bool use_abs_coords;

    // Runtime stuff
    bool use_fbo_blit, use_image_blit;
    Color clear_color;
    vector<SurfaceBlit> blit_images;
    int dest_width, dest_height;
    int dest_x, dest_y;
    int src_width, src_height;
    int stretch_mode;
    int blit_effect;

    // Image array
    vector<SurfaceImage> images;

    // Current images
    SurfaceImage * displayed_image;
    int displayed_index;
    SurfaceImage * selected_image;
    int selected_index;

    // File loading
    std::string filename;
    bool load_failed;

    // Polygon draw
    int vert_index;
    SurfaceQuad quad;
    vector<SurfaceQuad> quads;
    vector<SurfaceLine> lines;

    SurfaceObject(int x, int y, int type_id);
    ~SurfaceObject();
    void update();
    void draw();
    void load(const std::string & filename, const std::string & ignore_ext);
    void load(const std::string & filename);
    void resize(int w, int h);
    void resize_canvas(int x, int y, int w, int h);
    void set_stretch_mode(int mode);
    void set_dest_pos(int x, int y);
    void set_dest_size(int w, int h);
    void blit(Active * obj);
    void blit(SurfaceObject * obj, int image);
    void blit_background();
    void blit_alpha(int image);
    void blit_image(int image);
    void set_alpha_mode(int mode);
    void set_effect(int index);
    void set_display_image(int index);
    void set_edit_image(int index, bool display = false);
    void create_alpha(int index);
    void clear_alpha(int index);
    void clear(const Color & color);
    void clear(int value);
    void apply_matrix(double div, double offset, double iterations,
                      double x1y1, double x1y2, double x1y3,
                      double x2y1, double x2y2, double x2y3,
                      double x3y1, double x3y2, double x3y3);
    void save(const std::string & filename, const std::string & ext);
    void reverse_x();
    void add_image(int w, int h);
    void set_transparent_color(const Color & color, bool replace);
    int get_edit_width();
    int get_edit_height();
    int get_image_width(int index);
    void scroll(int x, int y, int wrap);
    void set_src_size(int w, int h);
    void draw_line(int x1, int y1, int x2, int y2, Color color, int width);
    void draw_polygon(int x, int y, Color color, int outline_size,
                      Color outline);
    void draw_rect(int x, int y, int w, int h, Color color,
                   int outline_size, Color outline);
    void insert_point(int index, int x, int y);
};

#endif // CHOWDREN_SURFACE_H
