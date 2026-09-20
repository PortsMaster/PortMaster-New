#ifndef CROSSRAND_H
#define CROSSRAND_H

#define CROSS_RAND_MAX 0x7FFF

// portable rand functions

// BUG FIX: `static` here gives this variable internal linkage, meaning
// every single .cpp file that includes this header gets its own separate,
// independently-zero-initialized copy of cross_seed. cross_srand() in
// run.cpp was only ever seeding run.cpp's own private copy - every other
// compiled file (all the generated events_N.cpp files, where actual
// gameplay RNG checks like Fusion's "random(1000)" live) had cross_seed
// permanently stuck at 0, regardless of the real seed used at boot.
// Confirmed via direct instrumentation: seed_before=0 on every single
// roll, across multiple runs with different (correctly random) boot-time
// seeds - only the actual per-process sequence of calls advanced the LCG,
// while every process's FIRST roll after boot was deterministically
// whatever cross_rand() produces from seed=0, which is why a "1 in 1000"
// check appeared to fire far more often than real 1/1000 odds: it wasn't
// re-seeded per real entropy at all for any file other than run.cpp.
extern unsigned int cross_seed;
inline void cross_srand(unsigned int value)
{
    cross_seed = value;
}

inline unsigned int cross_rand()
{
    cross_seed = cross_seed * 214013 + 2531011;
    return (cross_seed >> 16) & CROSS_RAND_MAX;
}

#endif // CROSSRAND_H
