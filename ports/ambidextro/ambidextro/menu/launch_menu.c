#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480
#define FONT_SIZE 24
#define MAX_OPTIONS 100
#define MAPPING_COUNT (sizeof(mapping_names)/sizeof(mapping_names[0]))

typedef struct {
  char   name[32];
  char       type;
  int         hat;
  int       value;
  int    inverted;
} MappingEntry;

#define BA_INDEX        0
#define BB_INDEX        1
#define BL2_INDEX      15
#define BR2_INDEX      16
#define BDUP_INDEX     17
#define LSTICKH_INDEX  11
#define LSTICKV_INDEX  12
#define RSTICKH_INDEX  13
#define RSTICKV_INDEX  14
#define BDDOWN_INDEX   18
#define BDLEFT_INDEX   19
#define BDRIGH_INDEX   20

const char *mapping_names[] = {
  "a", "b", "x", "y",
  "back", "guide", "start",
  "leftshoulder", "rightshoulder",
  "leftstick", "rightstick",
  "leftx", "lefty", "rightx", "righty",
  "lefttrigger", "righttrigger",
  "dpup", "dpdown", "dpleft", "dpright"
};

const char *mapping_show_names[] = {
  "a", "b", "x", "y",
  "select", "guide", "start",
  "l1", "r1",
  "L stick (pressed)",
  "R stick (pressed)",
  "L stick horizontal",
  "L stick vertical",
  "R stick horizontal",
  "R stick vertical",
  "l2", "r2",
  "up", "down", "left", "right"
};

const SDL_Color WHITE  = {255, 255, 255, 255};
const SDL_Color YELLOW = {255, 255,   0, 255};

char *menu_options[MAX_OPTIONS];
int option_count = 0;

bool load_menu(const char *filename) {
  FILE *file = fopen(filename, "r");
  if (!file) {
    fprintf(stderr, "Error opening menu file: %s\n", filename);
    return false;
  }

  char line[256];
  while (fgets(line, sizeof(line), file) && option_count < MAX_OPTIONS - 1) {
    line[strcspn(line, "\n")] = 0;
    if (strlen(line) == 0) continue;

    menu_options[option_count] = strdup(line);
    if (!menu_options[option_count]) {
      fprintf(stderr, "Memory allocation error.\n");
      fclose(file);
      return false;
    }

    printf("Loaded menu option [%d]: %s\n", option_count, menu_options[option_count]);
    option_count++;
  }
  fclose(file);

  menu_options[option_count] = strdup("Joystick Mapper");
  option_count++;
  menu_options[option_count] = strdup("Restore");
  option_count++;
  menu_options[option_count] = strdup("Exit");
  option_count++;

  return true;
}

void render_text(SDL_Renderer *renderer, TTF_Font *font, const char *text, int x, int y, SDL_Color color) {
  SDL_Surface *surface = TTF_RenderText_Solid(font, text, color);
  if (!surface) return;
  SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);
  SDL_Rect dst = {x, y, surface->w, surface->h};
  SDL_RenderCopy(renderer, texture, NULL, &dst);
  SDL_FreeSurface(surface);
  SDL_DestroyTexture(texture);
}

void render_menu(SDL_Renderer *renderer, TTF_Font *font, int selected) {
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
  SDL_RenderClear(renderer);
  int y = 15;

  for (int i = 0; i < option_count; i++) {
    if (!menu_options[i]) continue;
    render_text(renderer, font, menu_options[i], 15, y, (i == selected) ? YELLOW : WHITE);
    y += 35;
  }

  SDL_RenderPresent(renderer);
}

int wait_for_input(int i, int b_button, SDL_Joystick *joystick, MappingEntry *mapping, SDL_Renderer *renderer, TTF_Font *font, const char *prompt) {
  SDL_Event e;
  bool waiting = true;
  SDL_JoystickID joystick_id = SDL_JoystickInstanceID(joystick);

  while (SDL_PollEvent(&e));

  while (waiting) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);

    if (i > 1)
      render_text(renderer, font, "Press B to skip", 15, 15, WHITE);
    render_text(renderer, font, prompt, 15, 40, WHITE);
    SDL_RenderPresent(renderer);

    while (SDL_PollEvent(&e)) {
      if (e.type == SDL_QUIT) exit(0);
      if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) return 0;

      // skip button
      if (i > 1 && e.type == SDL_JOYBUTTONDOWN && e.jbutton.which == joystick_id) {
        int button = e.jbutton.button;
        if (button == b_button) return 0;
      }

      if (e.type == SDL_JOYBUTTONDOWN && e.jbutton.which == joystick_id) {
        mapping->value = e.jbutton.button;
        mapping->type  = 'b';
        return 1;
      }

      if (e.type == SDL_JOYAXISMOTION && e.jaxis.which == joystick_id) {
        if (abs(e.jaxis.value) > 8000) {
          mapping->value    = e.jaxis.axis;
          mapping->inverted = 1 ? e.jaxis.value > 0 : 0;
          mapping->type     = 'a';
          return 1;
        }
      }

      if (e.type == SDL_JOYHATMOTION && e.jhat.which == joystick_id) {
        mapping->value = e.jhat.value;
        mapping->hat   = e.jhat.hat;
        mapping->type  = 'h';
        return 1;
      }
    }
    SDL_Delay(10);
  }
  return 0;
}

int confirm_input(int i, SDL_Renderer *renderer, TTF_Font *font, const char *info, int input_value, SDL_JoystickID joystick_id, int a_button, int b_button) {
  SDL_Event e;
  bool waiting = true;

  while (SDL_PollEvent(&e));

  while (waiting) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);
    render_text(renderer, font, info, 15, 15, WHITE);

    if (i < 2) {
      render_text(renderer, font, "Press same input to confirm,", 15, 70, WHITE);
      render_text(renderer, font, "any other to retry", 15, 90, WHITE);
    } else {
      render_text(renderer, font, "Press A to confirm,", 15, 70, WHITE);
      render_text(renderer, font, "B to retry", 15, 90, WHITE);
    }

    SDL_RenderPresent(renderer);

    while (SDL_PollEvent(&e)) {
      if (e.type == SDL_QUIT) exit(0);
      if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) return 0;

      if (i < 2) {
        if (e.type == SDL_JOYBUTTONDOWN && e.jbutton.which == joystick_id) {
          return (e.jbutton.button == input_value) ? 1 : 0;
        }
      } else {
        if (e.type == SDL_JOYBUTTONDOWN && e.jbutton.which == joystick_id) {
          int button = e.jbutton.button;
          if (button == a_button) return 1;
          if (button == b_button) return 0;
        }
      }
    }
    SDL_Delay(10);
  }
  return 0;
}

void save_mapping(const char *filename, SDL_Joystick *joystick, const char *guid, MappingEntry *mappings, int count,
    SDL_Renderer *renderer, TTF_Font *font) {
  FILE *f = fopen(filename, "w");
  if (!f) {
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    render_text(renderer, font, "Failed to save mapping file.", 15, 15, WHITE);
    SDL_RenderPresent(renderer);
    SDL_Delay(2000);
    return;
  }

  const char *joystick_name = SDL_JoystickName(joystick);
  fprintf(f, "%s,%s", guid, joystick_name ? joystick_name : "UnknownController");
  for (int i = 0; i < count; i++) {
    if (mappings[i].name[0] == '\0') continue;
    if (mappings[i].type == 'h')
      fprintf(f, ",%s:%c%d.%d", mappings[i].name, mappings[i].type, mappings[i].hat, mappings[i].value);
    else if (mappings[i].inverted == 1)
      fprintf(f, ",%s:%c%d~", mappings[i].name, mappings[i].type, mappings[i].value);
    else
      fprintf(f, ",%s:%c%d", mappings[i].name, mappings[i].type, mappings[i].value);
  }
  fprintf(f, ",platform:Linux\n");
  fclose(f);

  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
  SDL_RenderClear(renderer);
  render_text(renderer, font, "Mapping saved to controller.map", 15, 15, WHITE);
  SDL_RenderPresent(renderer);
  SDL_Delay(3000);
}
void joystick_restore(SDL_Renderer *renderer, TTF_Font *font, const char * text) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);
    render_text(renderer, font, text, 15, 15, WHITE);
    SDL_RenderPresent(renderer);
    SDL_Delay(2000);
    return;
}

void joystick_mapper(SDL_Renderer *renderer, TTF_Font *font) {
  if (SDL_NumJoysticks() < 1) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);
    render_text(renderer, font, "No joystick detected.", 15, 15, WHITE);
    SDL_RenderPresent(renderer);
    SDL_Delay(2000);
    return;
  }

  SDL_Joystick *joystick = SDL_JoystickOpen(0);
  if (!joystick) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);
    render_text(renderer, font, "Failed to open joystick.", 15, 15, WHITE);
    SDL_RenderPresent(renderer);
    SDL_Delay(2000);
    return;
  }

  char guid[64];
  SDL_JoystickGUID joystick_guid = SDL_JoystickGetGUID(joystick);
  SDL_JoystickGetGUIDString(joystick_guid, guid, sizeof(guid));
  SDL_JoystickID joystick_id = SDL_JoystickInstanceID(joystick);

  MappingEntry mappings[MAPPING_COUNT];
  memset(mappings, 0, sizeof(mappings));

  int a_button = -1;
  int b_button = -1;
  for (int i = 0; i < (int)(MAPPING_COUNT); i++) {
    bool done = false;
    while (!done) {
      char prompt[128];
      if (i == LSTICKH_INDEX)
        snprintf(prompt, sizeof(prompt), "Move L stick to the LEFT");
      else if (i == LSTICKV_INDEX)
        snprintf(prompt, sizeof(prompt), "Move L stick UP");
      else if (i == RSTICKH_INDEX)
        snprintf(prompt, sizeof(prompt), "Move R stick to the LEFT");
      else if (i == RSTICKV_INDEX)
        snprintf(prompt, sizeof(prompt), "Move R stick UP");
      else
        snprintf(prompt, sizeof(prompt), "Press input for %s:", mapping_show_names[i]);

      int got = wait_for_input(i, b_button, joystick, &mappings[i], renderer, font, prompt);

      if (!got) {
        if (i < 2) continue; // Force mapping for 'a' and 'b'
        mappings[i].name[0] = '\0';
        done = true;
      } else {
        char info[128];
        if (mappings[i].type == 'h') {
          snprintf(info, sizeof(info), "Detected %c%d.%d for %s", mappings[i].type, mappings[i].hat, mappings[i].value, mapping_show_names[i]);
        } else if (i == LSTICKH_INDEX || i == LSTICKV_INDEX || i == RSTICKH_INDEX || i == RSTICKV_INDEX) {
          char sign = '\0';
          if (mappings[i].inverted == 1) sign = '~';
          snprintf(info, sizeof(info), "Detected %c%d%c for %s", mappings[i].type, mappings[i].value, sign, mapping_show_names[i]);
        } else {
          snprintf(info, sizeof(info), "Detected %c%d for %s", mappings[i].type, mappings[i].value, mapping_show_names[i]);
        }
        strncpy(mappings[i].name, mapping_names[i], sizeof(mappings[i].name));

        // Get pre-registered 'a' and 'b' buttons
        if (strcmp(mappings[BA_INDEX].name, "a") == 0) a_button = mappings[BA_INDEX].value;
        if (strcmp(mappings[BB_INDEX].name, "b") == 0) b_button = mappings[BB_INDEX].value;

        int conf = confirm_input(i, renderer, font, info, mappings[i].value, joystick_id, a_button, b_button);
        if (conf == 1) done = true;
        else if (conf == 0) continue;
      }
    }
  }

  save_mapping("controller.map", joystick, guid, mappings, MAPPING_COUNT, renderer, font);
  SDL_JoystickClose(joystick);
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    printf("Usage: %s <menu_file.txt> <font.ttf>\n", argv[0]);
    return 1;
  }

  const char *menu_file = argv[1];
  const char *font_file = argv[2];

  if (!load_menu(menu_file)) return 1;

  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK) != 0 || TTF_Init() != 0) {
    fprintf(stderr, "Initialization failed: %s\n", SDL_GetError());
    return 1;
  }

  SDL_Window *window = SDL_CreateWindow("Launch Menu", 
      SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
      SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_BORDERLESS);

  SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  TTF_Font *font = TTF_OpenFont(font_file, FONT_SIZE);

  int selected = 0;
  int exitcode = 0;
  bool running = true;
  SDL_Event e;

  while (running) {
    render_menu(renderer, font, selected);

    while (SDL_PollEvent(&e)) {
      if (e.type == SDL_QUIT) running = false;
      else if (e.type == SDL_KEYDOWN) {
        switch (e.key.keysym.sym) {
          case SDLK_UP: selected = (selected - 1 + option_count) % option_count; break;
          case SDLK_DOWN: selected = (selected + 1) % option_count; break;
          case SDLK_RETURN:
                          if (strcmp(menu_options[selected], "Joystick Mapper") == 0) {
                            // prevent input
                            SDL_Delay(150);
                            joystick_mapper(renderer, font);
                            // prevent input
                            SDL_Delay(150);
                          } else if (strcmp(menu_options[selected], "Restore") == 0) {
                            const char * fmap = "controller.map";

                            FILE * f = fopen(fmap, "r");
                            if (f){
                              fclose(f);
                              if (remove(fmap) == 0) joystick_restore(renderer, font, "controller.map removed");
                              else joystick_restore(renderer, font, "error restoring mapping");
                            } else {
                              joystick_restore(renderer, font, "controller.map removed");
                            }
                          } else if (strcmp(menu_options[selected], "Exit") == 0) {
                            exitcode = 0;
                            running = false;
                          } else {
                            printf("[MENU] You selected: %s\n", menu_options[selected]);
                            exitcode = selected + 2;
                            running = false;
                          }
                          break;
        }
      }
    }
    SDL_Delay(16);
  }

  // Cleanup
  for (int i = 0; i < option_count; i++) free(menu_options[i]);
  TTF_CloseFont(font);
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  TTF_Quit();
  SDL_Quit();
  return exitcode;
}
