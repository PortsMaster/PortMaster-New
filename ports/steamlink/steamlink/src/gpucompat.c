#define _GNU_SOURCE

#include <dlfcn.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <drm/msm_drm.h>
#include <drm/panfrost_drm.h>
#include <linux/dma-heap.h>

// Device path options
#define DMA_HEAP_PATH "/dev/dma_heap/vidbuf_cached"
#define REAL_DRM_DEVICE "/dev/dri/renderD128"

// Required fcntl.h defines
#define O_RDWR      00000002
#define O_CLOEXEC   02000000
#define AT_FDCWD        -100

// Static data stores
static int (*real_ioctl)(int, unsigned long, ...);
static char drm_dri_name[16];

// DRM Driver version check
int get_gpu_dri(int fd) {
    struct drm_version version = {
        .name = drm_dri_name,
        .name_len = sizeof(drm_dri_name)
    };
    ioctl(fd, DRM_IOCTL_VERSION, &version);
    if (drm_dri_name[0] == '\0') {
        return -1;
    }
    return 0;
}

// DRM Device FD -> GEM Handle -> DRM Prime FD
int drm_to_dma(int fd, size_t size) {
    if (drm_dri_name[0] == '\0') {
        if (get_gpu_dri(fd) != 0) {
            return -1;
        }
    }

    __u32 gem_handle = 0;
    if (strcmp(drm_dri_name, "msm") == 0) {
        struct drm_msm_gem_new gem = {
            .size = size,
            .flags = MSM_BO_WC
        };
        ioctl(fd, DRM_IOCTL_MSM_GEM_NEW, &gem);
        gem_handle = gem.handle;
    } else if (strcmp(drm_dri_name, "panfrost") == 0) {
        struct drm_panfrost_create_bo gem = {
            .size = size,
            .flags = 0
        };
        ioctl(fd, DRM_IOCTL_PANFROST_CREATE_BO, &gem);
        gem_handle = gem.handle;
    } else {
        return -1;
    }

    struct drm_prime_handle prime = {
        .handle = gem_handle,
        .flags = DRM_RDWR | DRM_CLOEXEC
    };
    ioctl(fd, DRM_IOCTL_PRIME_HANDLE_TO_FD, &prime);

    return prime.fd;
}

// Actual syscall for open
int real_open(const char *path, int flags, __u32 mode) {
    return syscall(SYS_openat, AT_FDCWD, path, flags, mode);
}

// Catch any calls that try to use DMA_HEAP/card0 and provide a device appropriate FD
int open64(const char *path, int flags, __u32 mode) {
    if (strcmp(path, DMA_HEAP_PATH) == 0) {
        return real_open(REAL_DRM_DEVICE, flags, mode);
    }
    return real_open(path, flags, mode);
}

// Because controls don't work unless this is routed this way
int open(const char *path, int flags, __u32 mode) {
    return open64(path, flags, mode);
}

// Catch any calls that try to use DMA_HEAP and provide a usable DMA-BUF FD
int ioctl(int fd, unsigned long request, ...) {
    if (!real_ioctl) { real_ioctl = dlsym(RTLD_NEXT, "ioctl"); }

    va_list args;
    va_start(args, request);

    if (request == DMA_HEAP_IOCTL_ALLOC) {
        struct dma_heap_allocation_data *data = va_arg(args, struct dma_heap_allocation_data*);
        data->fd = drm_to_dma(fd, data->len);
        va_end(args);
        return 0;
    }

    void *data = va_arg(args, void*);
    int ret = real_ioctl(fd, request, data);
    va_end(args);
    return ret;
}
