#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>

#define SHM_PATH "/dev/shm/SharedSettings"

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

int main(int argc, char *argv[]) {

    if (argc != 2) {
        fprintf(stderr, "Usage: %s [volume|brightness]\n", argv[0]);
        return 1;
    }

    int fd = open(SHM_PATH, O_RDONLY);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    SettingsV10 *settings = mmap(NULL, sizeof(SettingsV10),
                                  PROT_READ, MAP_SHARED, fd, 0);

    if (settings == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return 1;
    }

    if (strcmp(argv[1], "volume") == 0) {

        int volume;

        if (settings->mute && settings->toggled_volume != 0)
            volume = settings->toggled_volume;
        else if (settings->jack || settings->audiosink != 0)
            volume = settings->headphones;
        else
            volume = settings->speaker;

        printf("%d\n", volume);

    } else if (strcmp(argv[1], "brightness") == 0) {

        printf("%d\n", settings->brightness);

    } else {
        fprintf(stderr, "Invalid setting. Use volume or brightness.\n");
        munmap(settings, sizeof(SettingsV10));
        close(fd);
        return 1;
    }

    munmap(settings, sizeof(SettingsV10));
    close(fd);

    return 0;
}