#include <sys/time.h>
#include <SDL.h>
#include "chowconfig.h"
#include "../platform.h"
#include "../include_gl.h"
#include "../manager.h"
#include "../mathcommon.h"
#include <tinythread/tinythread.h>
#include <iostream>

GLuint screen_texture;
GLuint screen_fbo;

bool is_fullscreen = false;
bool hide_cursor = false;
bool has_closed = false;
Uint64 start_time;

inline bool check_opengl_extension(const char * name)
{
    if (glewGetExtension(name) == GL_TRUE)
        return true;
    std::cout << "OpenGL extension '" << name << "' not supported." << std::endl;
    return false;
}

const char * extensions[] = {
    "GL_EXT_framebuffer_object",
    "GL_ARB_vertex_shader",
    "GL_ARB_fragment_shader",
    NULL
};

inline bool check_opengl_extensions()
{
    for (int i = 0; extensions[i] != NULL; i++)
        if (!check_opengl_extension(extensions[i]))
            return false;
    return true;
}

void on_key(SDL_KeyboardEvent & e)
{
    if (e.repeat != 0)
        return;
    manager.on_key(e.keysym.sym, e.state == SDL_PRESSED);
}

void on_mouse(SDL_MouseButtonEvent & e)
{
    manager.on_mouse(e.button, e.state == SDL_PRESSED);
}

void platform_init()
{
    unsigned int flags;
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cout << "SDL could not be initialized: " << SDL_GetError()
            << std::endl;
        return;
    }
}

void platform_exit()
{
    SDL_Quit();
}

void platform_poll_events()
{
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        switch (e.type) {
            case SDL_KEYDOWN:
            case SDL_KEYUP:
                on_key(e.key);
                break;
            case SDL_MOUSEBUTTONDOWN:
            case SDL_MOUSEBUTTONUP:
                on_mouse(e.button);
                break;
            case SDL_QUIT:
                has_closed = true;
                break;
            default:
                break;
        }
    }
}

void platform_sleep(double t)
{
}

bool platform_display_closed()
{
    return has_closed;
}

void platform_get_mouse_pos(int * x, int * y)
{
    SDL_GetMouseState(x, y);
}

void platform_create_display(bool fullscreen)
{
    is_fullscreen = fullscreen;

    int flags = SDL_OPENGL | SDL_RESIZABLE;
    if (fullscreen)
        flags |= SDL_WINDOW_FULLSCREEN;
    SDL_SetVideoMode(WINDOW_WIDTH, WINDOW_HEIGHT, 0, flags);

    // check extensions
    if (!check_opengl_extensions()) {
        std::cout << "Not all OpenGL extensions supported. Quitting..."
            << std::endl;
        exit(EXIT_FAILURE);
        return;
    }

    // if the cursor was hidden before the window was created, hide it now
    if (hide_cursor)
        platform_hide_mouse();
}

void platform_begin_draw()
{

}

void platform_swap_buffers()
{
}

void platform_get_size(int * width, int * height)
{
    SDL_GetWindowSize(NULL, width, height);
}

void platform_get_screen_size(int * width, int * height)
{
    platform_get_size(width, height);
}

bool platform_has_focus()
{
    return true;
}

void platform_set_focus(bool value)
{
}

void platform_show_mouse()
{
    hide_cursor = false;
    SDL_ShowCursor(1);
}

void platform_hide_mouse()
{
    hide_cursor = true;
    SDL_ShowCursor(0);
}

const std::string & platform_get_language()
{
    static std::string language("English");
    return language;
}

// time

double platform_get_time()
{
    return SDL_GetTicks() / 1000.0f;
}

// filesystem stuff

#include <sys/stat.h>

size_t get_file_size(const char * filename)
{
    struct stat st;
    stat(filename, &st);
    return st.st_size;
}

void create_directories(const std::string & value)
{
}

const std::string & platform_get_appdata_dir()
{
    static std::string dir(".");
    return dir;
}

// joystick

int get_joystick_last_press(int n)
{
    return -1;
}

bool is_joystick_attached(int n)
{
    return false;
}

bool is_joystick_pressed(int n, int button)
{
    return false;
}

bool any_joystick_pressed(int n)
{
    return false;
}

bool is_joystick_released(int n, int button)
{
    return false;
}

void joystick_vibrate(int n, float l, float r, int ms)
{
}

float get_joystick_axis(int n, int axis)
{
    return 0.0f;
}

// url open

void open_url(const std::string & name)
{
}

// file

bool platform_remove_file(const std::string & file)
{
    return remove(convert_path(file).c_str()) == 0;
}

#include "fileio.cpp"

#define HANDLE_BASE StandardFile

class StandardFile
{
public:
    FILE * fp;

    StandardFile(FSFile * parent, const char * filename, bool is_read)
    {
        const char * real_mode;
        if (is_read)
            real_mode = "rb";
        else
            real_mode = "wb";
        fp = fopen(filename, real_mode);
        parent->closed = fp == NULL;
    }

    bool seek(size_t v, int origin)
    {
        return fseek(fp, v, origin) == 0;
    }

    size_t tell()
    {
        return ftell(fp);
    }

    int getc()
    {
        return fgetc(fp);
    }

    size_t read(void * data, size_t size)
    {
        return fread(data, 1, size, fp);
    }

    size_t write(void * data, size_t size)
    {
        return fwrite(data, 1, size, fp);
    }

    void close()
    {
        fclose(fp);
    }

    bool at_end()
    {
        int c = getc();
        ungetc(c, fp);
        return c == EOF;
    }
};

void FSFile::open(const char * filename, const char * mode)
{
    bool is_read;
    switch (*mode) {
        case 'r':
            is_read = true;
            break;
        case 'w':
            is_read = false;
            break;
    }
    HANDLE_BASE * new_handle = new StandardFile(this, filename, is_read);
    if (closed)
        return;
    handle = (void*)new_handle;
    closed = false;
}

bool FSFile::seek(size_t v, int origin)
{
    return ((HANDLE_BASE*)handle)->seek(v, origin);
}

size_t FSFile::tell()
{
    return ((HANDLE_BASE*)handle)->tell();
}

int FSFile::getc()
{
    return ((HANDLE_BASE*)handle)->getc();
}

size_t FSFile::read(void * data, size_t size)
{
    return ((HANDLE_BASE*)handle)->read(data, size);
}

size_t FSFile::write(void * data, size_t size)
{
    return ((HANDLE_BASE*)handle)->write(data, size);
}

bool FSFile::at_end()
{
    return ((HANDLE_BASE*)handle)->at_end();
}

void FSFile::close()
{
    if (closed)
        return;
    HANDLE_BASE * h = (HANDLE_BASE*)handle;
    h->close();
    delete h;
    closed = true;
}

// path

std::string convert_path(const std::string & v)
{
    return v;
}

// debug

void platform_print_stats()
{

}

// wiiu dummies

void platform_set_remote_setting(const std::string & v)
{

}

int platform_get_remote_value()
{
    return CHOWDREN_TV_TARGET;
}

void platform_set_border(bool v)
{

}



static std::string remote_string("TV");

const std::string & platform_get_remote_setting()
{
    return remote_string;
}

bool platform_has_error()
{
    return false;
}
