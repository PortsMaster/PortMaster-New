#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/mman.h>

#define CODE_PLUS   115  // Volume Up
#define CODE_MINUS  114  // Volume Down
#define CODE_MENU0  314  // Menu key 2
#define CODE_MENU2  316  // Menu key 0

#define PRESSED 1
#define RELEASED 0
#define REPEAT 2

#define VOLUME_MIN 0
#define VOLUME_MAX 20

#define INPUT_COUNT 5

#define SHM_PATH "/dev/shm/SharedSettings"

static int inputs[INPUT_COUNT];
static struct input_event ev;
static volatile int quit = 0;

static void on_term(int sig) {
    quit = 1;
}

void send_volume_to_godot(int volume) {
    const char *host = "127.0.0.1";
    const char *port = "23456";
	
	int scaled = (volume * 100) / 20;

    char cmd[128];
    snprintf(cmd, sizeof(cmd), "echo \"%d\" | nc %s %s 2>/dev/null &", scaled, host, port);
    system(cmd);
}



typedef struct {
    int version;
    int brightness;
    int colortemperature;
    int headphones;
    int speaker;
    int mute;
    int contrast;
    int saturation;
    int exposure;
    int toggled_brightness;
    int toggled_colortemperature;
    int toggled_contrast;
    int toggled_saturation;
    int toggled_exposure;
    int toggled_volume;
    int disable_dpad_on_mute;
    int emulate_joystick_on_mute;
    int turbo_a;
    int turbo_b;
    int turbo_x;
    int turbo_y;
    int turbo_l1;
    int turbo_l2;
    int turbo_r1;
    int turbo_r2;
    int unused[2];
    int jack;
    int audiosink;
} SettingsV10;

int get_volume() {
    int fd = open(SHM_PATH, O_RDONLY);
    if (fd < 0)
        return 10;  // safe fallback

    SettingsV10 *settings = mmap(NULL, sizeof(SettingsV10),
                                  PROT_READ, MAP_SHARED, fd, 0);

    if (settings == MAP_FAILED) {
        close(fd);
        return 10;
    }

    int volume;

    if (settings->mute && settings->toggled_volume != 0)
        volume = settings->toggled_volume;
    else if (settings->jack || settings->audiosink != 0)
        volume = settings->headphones;
    else
        volume = settings->speaker;

    munmap(settings, sizeof(SettingsV10));
    close(fd);

    if (volume < VOLUME_MIN) volume = VOLUME_MIN;
    if (volume > VOLUME_MAX) volume = VOLUME_MAX;

    return volume;
}

int main() {
    signal(SIGTERM, on_term);
    signal(SIGINT, on_term);

    char path[32];
    for (int i = 0; i < INPUT_COUNT; i++) {
        snprintf(path, sizeof(path), "/dev/input/event%d", i);
        inputs[i] = open(path, O_RDONLY | O_NONBLOCK | O_CLOEXEC);
        if (inputs[i] < 0) inputs[i] = -1;
    }

    uint32_t menu_pressed = 0;
    uint32_t menu2_pressed = 0;

    uint32_t up_pressed = 0;
    uint32_t up_just_pressed = 0;
    uint32_t up_repeat_at = 0;

    uint32_t down_pressed = 0;
    uint32_t down_just_pressed = 0;
    uint32_t down_repeat_at = 0;

    uint32_t then, now;
    struct timeval tod;

    int volume = get_volume(); // starting volume

    gettimeofday(&tod, NULL);
    then = tod.tv_sec * 1000 + tod.tv_usec / 1000;

    while (!quit) {
        gettimeofday(&tod, NULL);
        now = tod.tv_sec * 1000 + tod.tv_usec / 1000;

        for (int i = 0; i < INPUT_COUNT; i++) {
            int fd = inputs[i];
            if (fd < 0) continue;

            while (read(fd, &ev, sizeof(ev)) == sizeof(ev)) {
                if (ev.type != EV_KEY || ev.value > REPEAT) continue;

                switch (ev.code) {
                    case CODE_MENU2:
                        menu_pressed = ev.value;
                        break;
                    case CODE_MENU0:
                        menu2_pressed = ev.value;
                        break;
                    case CODE_PLUS:
                        up_pressed = up_just_pressed = ev.value;
                        if (ev.value == PRESSED)
                            up_repeat_at = now + 300;
                        break;
                    case CODE_MINUS:
                        down_pressed = down_just_pressed = ev.value;
                        if (ev.value == PRESSED)
                            down_repeat_at = now + 300;
                        break;
                    default:
                        break;
                }
            }
        }

        // Handle volume UP
        if (up_just_pressed || (up_pressed && now >= up_repeat_at)) {
            if (!menu_pressed && !menu2_pressed) {
				if (volume < VOLUME_MAX) {
					volume++;
				}
                printf("VOL_UP -> %d\n", volume);
                fflush(stdout);
				send_volume_to_godot(volume);
            }
            if (up_just_pressed) up_just_pressed = 0;
            else up_repeat_at += 100;
        }

        // Handle volume DOWN
        if (down_just_pressed || (down_pressed && now >= down_repeat_at)) {
            if (!menu_pressed && !menu2_pressed) {
				if (volume > VOLUME_MIN) {
					volume--;
				}
                printf("VOL_DOWN -> %d\n", volume);
                fflush(stdout);
				send_volume_to_godot(volume);
            }
            if (down_just_pressed) down_just_pressed = 0;
            else down_repeat_at += 100;
        }

        then = now;
        usleep(16666); // ~60fps
    }

    for (int i = 0; i < INPUT_COUNT; i++)
        if (inputs[i] >= 0) close(inputs[i]);

    return 0;
}
