/*
 * sdl2fb - Reads raw BGRA frames from stdin, displays in an SDL2 window.
 * For PortMaster ports that render to framebuffer but need Sway/Wayland support.
 *
 * Compile: gcc -O2 -o sdl2fb sdl2fb.c $(sdl2-config --cflags --libs)
 */
#include <SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    int width = 640, height = 480;
    const char *w_env = getenv("DISPLAY_WIDTH");
    const char *h_env = getenv("DISPLAY_HEIGHT");
    if (w_env) width = atoi(w_env);
    if (h_env) height = atoi(h_env);
    if (width <= 0) width = 640;
    if (height <= 0) height = 480;

    int frame_size = width * height * 4;

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "sdl2fb: SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Window *window = SDL_CreateWindow("PuzzleScript",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_FULLSCREEN_DESKTOP);
    if (!window) {
        fprintf(stderr, "sdl2fb: SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer)
        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_SOFTWARE);
    if (!renderer) {
        fprintf(stderr, "sdl2fb: SDL_CreateRenderer failed: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    SDL_RenderSetLogicalSize(renderer, width, height);

    SDL_Texture *texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_BGRA32, SDL_TEXTUREACCESS_STREAMING,
        width, height);
    if (!texture) {
        fprintf(stderr, "sdl2fb: SDL_CreateTexture failed: %s\n", SDL_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    unsigned char *buf = (unsigned char *)malloc(frame_size);
    if (!buf) return 1;

    /* Render a black frame immediately so the window is mapped in Wayland
       and the compositor can find/fullscreen it before data arrives */
    memset(buf, 0, frame_size);
    SDL_UpdateTexture(texture, NULL, buf, width * 4);
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);

    while (1) {
        int total = 0;
        while (total < frame_size) {
            int n = read(STDIN_FILENO, buf + total, frame_size - total);
            if (n <= 0) goto done;
            total += n;
        }

        SDL_UpdateTexture(texture, NULL, buf, width * 4);
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);

        SDL_Event ev;
        while (SDL_PollEvent(&ev)) {
            if (ev.type == SDL_QUIT) goto done;
        }
    }

done:
    free(buf);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
