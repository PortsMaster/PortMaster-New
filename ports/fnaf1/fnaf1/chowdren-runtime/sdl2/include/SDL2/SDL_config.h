/* Bundled single-architecture (aarch64) SDL2 build - no multiarch
 * indirection needed or wanted. The upstream Debian packaging uses
 * #include <SDL2/_real_SDL_config.h> here, relying on the compiler's
 * default multiarch include search path
 * (/usr/include/<arch>-linux-gnu/) to resolve it - that path only
 * exists on Debian/Ubuntu-style systems. On buildroot-based systems
 * (no multiarch layout) that lookup fails outright:
 *   fatal error: 'SDL2/_real_SDL_config.h' file not found
 * A plain quoted include of the sibling file in this same directory
 * works identically everywhere, regardless of host distro. */
#include "_real_SDL_config.h"
