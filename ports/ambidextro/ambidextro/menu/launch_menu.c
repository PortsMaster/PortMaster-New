/*
 * Copyright (C) 2025  Vinicio Valbuena (lowlevel.1989)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <stdio.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <linux/input.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#define MAX_KEY 2048
#define MAX_ABS 2048
#define MAX_EVENT_DEVICES 32
#define BSWAP16(x) ((__u16)(((x) << 8) | ((x) >> 8)))
#define NBITS(x) ((((x)-1)/8/sizeof(long))+1)
#define test_bit(nr, addr) (((1UL << ((nr) % (8*sizeof(long)))) & ((addr)[(nr)/ (8*sizeof(long))])) != 0)

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480
#define FONT_SIZE 24
#define MAX_OPTIONS 100
#define MAPPING_COUNT (sizeof(mapping_names)/sizeof(mapping_names[0]))

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

typedef struct {
  char         name[32];
  char         type;
  int          hat;
  int          value;
  int          inverted;
} MappingEntry;

int key_map[MAX_KEY];
int abs_map[MAX_ABS];
int abs_max[MAX_ABS];
int abs_min[MAX_ABS];

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

int normalize_axis(int value, int min, int max) {
  if (max == min) return 0;
  float scaled = (2.0f * (value - min) / (float)(max - min)) - 1.0f;
  return (int)(scaled * 32767);
}


int open_joystick_device() {
  printf("Opening joystick device...\n");
  for (int i = 0; i < 32; i++) {
    char path[256];
    sprintf(path, "/dev/input/event%d", i);
    printf("Trying input device: %s\n", path);
    int fd = open(path, O_RDONLY | O_NONBLOCK);
    if (fd < 0) {
      if (errno != EACCES) {
        printf("Failed to open %s: %s\n", path, strerror(errno));
      }
      continue;
    }

    unsigned long evbit[NBITS(EV_MAX)] = {0};
    if (ioctl(fd, EVIOCGBIT(0, sizeof(evbit)), evbit) < 0 || 
        !test_bit(EV_ABS, evbit) || !test_bit(EV_KEY, evbit)) {
      printf("Device %s doesn't have required capabilities\n", path);
      close(fd);
      continue;
    }
    printf("Using input device: %s\n", path);
    return fd;
  }
  printf("No suitable joystick device found\n");
  return -1;
}

// GODOT: map code event
void setup_joypad_properties(int fd) {
  printf("Setting up joypad properties for fd: %d\n", fd);

  unsigned long keybit[NBITS(KEY_MAX)] = { 0 };
  unsigned long absbit[NBITS(ABS_MAX)] = { 0 };

  for (int i = 0; i < MAX_KEY; i++) key_map[i] = -1;
  for (int i = 0; i < MAX_ABS; i++) abs_map[i] = -1;

  if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(keybit)), keybit) < 0 ||
      ioctl(fd, EVIOCGBIT(EV_ABS, sizeof(absbit)), absbit) < 0) {
    perror("ioctl EVIOCGBIT");
    return;
  }

  int num_buttons = 0;
  for (int code = BTN_JOYSTICK; code < KEY_MAX; ++code) {
    if (test_bit(code, keybit)) {
      key_map[code] = num_buttons++;
      printf("Mapped button code %d to key_map[%d] = %d\n", code, code, key_map[code]);
    }
  }
  for (int code = BTN_MISC; code < BTN_JOYSTICK; ++code) {
    if (test_bit(code, keybit)) {
      key_map[code] = num_buttons++;
      printf("Mapped misc button code %d to key_map[%d] = %d\n", code, code, key_map[code]);
    }
  }

  int num_axes = 0;
  for (int code = 0; code < ABS_MISC; ++code) {
    // Skip hats
    if (code == ABS_HAT0X) {
      code = ABS_HAT3Y;
      continue;
    }
    if (test_bit(code, absbit)) {
      struct input_absinfo abs_info;

      ioctl(fd, EVIOCGABS(code), &abs_info);

      abs_map[code] = num_axes++;
      abs_min[code] = abs_info.minimum;
      abs_max[code] = abs_info.maximum;
      printf("Mapped axis code %d to abs_map[%d] = %d min %d max %d\n", code, code, abs_map[code], abs_min[code], abs_max[code]);
    }
  }
}

int read_input_event(int fd, struct input_event *ev) {
  ssize_t bytes = read(fd, ev, sizeof(struct input_event));
  return (bytes == sizeof(struct input_event));
}

int wait_for_input(int i, int b_button, int fd, MappingEntry *mapping, SDL_Renderer *renderer, TTF_Font *font, const char *prompt) {
  struct input_event ev;

  bool waiting = true;

  while (waiting) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);

    if (i > 1)
      render_text(renderer, font, "Press B to skip", 15, 15, WHITE);
    render_text(renderer, font, prompt, 15, 40, WHITE);
    SDL_RenderPresent(renderer);

    if (read_input_event(fd, &ev)) {
      if (ev.type == EV_KEY && ev.value == 1) { // button down
        if (i > 1 && key_map[ev.code] == b_button) return 0;
        mapping->value = key_map[ev.code];
        mapping->type = 'b';
        printf("Mapped button code %d to key_map[%d] = %d\n", ev.code, ev.code, key_map[ev.code]);
        return 1;
      }

      if (ev.type == EV_ABS && abs(normalize_axis(ev.value, abs_min[ev.code], abs_max[ev.code])) > 8000) {
        mapping->value = abs_map[ev.code];
        mapping->type = 'a';
        mapping->inverted = (normalize_axis(ev.value, abs_min[ev.code], abs_max[ev.code]) > 0) ? 1 : 0;
        printf("Mapped axis code %d to abs_map[%d] = %d %d\n", ev.code, ev.code, ev.value, normalize_axis(ev.value, abs_min[ev.code], abs_max[ev.code]));
        return 1;
      }

      if (ev.type == EV_ABS && (ev.code == ABS_HAT0X || ev.code == ABS_HAT0Y)) {
        mapping->value = 100; // test value
        mapping->hat   =   0;
        mapping->type =  'h';

        if (ev.code == ABS_HAT0X) {
          mapping->value = SDL_HAT_RIGHT;
          if (ev.value < 0)
            mapping->value = SDL_HAT_LEFT;
        }
        else if (ev.code == ABS_HAT0Y) {
          mapping->value = SDL_HAT_DOWN;
          if (ev.value < 0)
            mapping->value = SDL_HAT_UP;
        }
        return 1;
      }
    }
    SDL_Delay(10);
  }
  return 0;
}



int wait_for_input_SDL(int i, int b_button, SDL_Joystick *joystick, MappingEntry *mapping, SDL_Renderer *renderer, TTF_Font *font, const char *prompt) {
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


int confirm_input(int i, SDL_Renderer *renderer, TTF_Font *font, const char *info, int input_value, int fd, int a_button, int b_button) {
  struct input_event ev;
  bool waiting = true;

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

    if (read_input_event(fd, &ev)) {
      if (ev.type == EV_KEY && ev.value == 1) {
        if (i < 2)
          return (key_map[ev.code] == input_value) ? 1 : 0;
        else {
          if (key_map[ev.code] == a_button) return 1;
          if (key_map[ev.code] == b_button) return 0;
        }
      }
    }
    SDL_Delay(10);
  }
  return 0;
}

int confirm_input_SDL(int i, SDL_Renderer *renderer, TTF_Font *font, const char *info, int input_value, SDL_JoystickID joystick_id, int a_button, int b_button) {
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

void save_mapping(const char *filename, const char *name, const char *guid, MappingEntry *mappings, int count,
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

  const char *joystick_name = name;
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

void joystick_mapper_godot(SDL_Renderer *renderer, TTF_Font *font) {
  int fd = open_joystick_device();
  if (fd < 0) {
    SDL_SetRenderDrawColor(renderer, 0,0,0,255);
    SDL_RenderClear(renderer);
    render_text(renderer, font, "No joystick detected.", 15, 15, WHITE);
    SDL_RenderPresent(renderer);
    SDL_Delay(2000);
    return;
  }

  // godot
  char guid[128];
  char name[128];

  struct input_id inpid;

  ioctl(fd, EVIOCGNAME(sizeof(name)), name);
  ioctl(fd, EVIOCGID, &inpid);

  uint16_t vendor = BSWAP16(inpid.vendor);
  uint16_t product = BSWAP16(inpid.product);
  uint16_t version = BSWAP16(inpid.version);

  // guid for godot v4
  snprintf(guid, sizeof(guid), "%04x%04x%04x%04x%04x%04x%04x%04x",
      BSWAP16(inpid.bustype), 0,
      vendor,  0,
      product, 0,
      version, 0);

  printf("%s\n", name);
  printf("vendor = 0x%04X, product = 0x%04X, version = 0x%04X\n", vendor, product, version);

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

      int got = wait_for_input(i, b_button, fd, &mappings[i], renderer, font, prompt);

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

        int conf = confirm_input(i, renderer, font, info, mappings[i].value, fd, a_button, b_button);
        if (conf == 1) done = true;
        else if (conf == 0) continue;
      }
    }
  }

  save_mapping("controller.map", name, guid, mappings, MAPPING_COUNT, renderer, font);
  close(fd);
}


void joystick_mapper_SDL(SDL_Renderer *renderer, TTF_Font *font) {
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

      int got = wait_for_input_SDL(i, b_button, joystick, &mappings[i], renderer, font, prompt);

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

        int conf = confirm_input_SDL(i, renderer, font, info, mappings[i].value, joystick_id, a_button, b_button);
        if (conf == 1) done = true;
        else if (conf == 0) continue;
      }
    }
  }

  save_mapping("controller.map", SDL_JoystickName(joystick), guid, mappings, MAPPING_COUNT, renderer, font);
  SDL_JoystickClose(joystick);
}

int main(int argc, char *argv[]) {

  // Forzar vaciamiento inmediato del buffer de salida
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stderr, NULL, _IONBF, 0);

  bool godot_flag = false;
  const char *menu_file = NULL;
  const char *font_file = NULL;

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--godot") == 0) {
      godot_flag = true;
    } else if (!menu_file) {
      menu_file = argv[i];
    } else if (!font_file) {
      font_file = argv[i];
    }
  }

  if (!menu_file || !font_file) {
    printf("Usage: %s <menu_file.txt> <font.ttf> [--godot]\n", argv[0]);
    return 1;
  }

  printf("Menu file: %s\n", menu_file);
  printf("Font file: %s\n", font_file);
  printf("--godot flag is %s\n", godot_flag ? "ON" : "OFF");

  if (!load_menu(menu_file)) return 1;

  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_TIMER) != 0 || TTF_Init() != 0) {
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

  int fd;
  fd = open_joystick_device();
  setup_joypad_properties(fd);
  close(fd);

  Uint32 ignore_input_until = 0;
  while (running) {
    render_menu(renderer, font, selected);

    while (SDL_PollEvent(&e)) {
      if (SDL_GetTicks() < ignore_input_until) continue;

      if (e.type == SDL_QUIT) running = false;
      else if (e.type == SDL_KEYDOWN) {
        switch (e.key.keysym.sym) {
          case SDLK_UP: selected = (selected - 1 + option_count) % option_count; break;
          case SDLK_DOWN: selected = (selected + 1) % option_count; break;
          case SDLK_RETURN:
                          if (strcmp(menu_options[selected], "Joystick Mapper") == 0) {
                            if (godot_flag)
                              joystick_mapper_godot(renderer, font);
                            else
                              joystick_mapper_SDL(renderer, font);
                            ignore_input_until = SDL_GetTicks() + 300; 
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
