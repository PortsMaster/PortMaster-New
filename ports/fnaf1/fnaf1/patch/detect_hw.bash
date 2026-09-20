#!/bin/bash

case "${DEVICE_CPU,,}" in
    rk3326|a133plus|a133p|h700)  PERF_TIER="slow" ;;
    rk356*|a523|sd6*|cortex-a5*) PERF_TIER="fast" ;;
    sd865|sd8*|cortex-a7*)       PERF_TIER="ultra" ;;
    *)                           PERF_TIER="slow" ;;
esac

if [ "${DEVICE_RAM:-1}" -le 1 ]; then
    MEM_TIER="1gig"
    CHOWDREN_WORKERS=1
    CHOWDREN_MAKE_JOBS=1
elif [ "${DEVICE_RAM:-1}" -le 2 ]; then
    MEM_TIER="2gig"
    CHOWDREN_WORKERS=2
    CHOWDREN_MAKE_JOBS=2
else
    MEM_TIER="4gig+"
    CHOWDREN_WORKERS=4
    CHOWDREN_MAKE_JOBS="$(nproc 2>/dev/null || echo 4)"
fi

case "${DEVICE_CPU,,}" in
    rk3326)
        MEM_TIER="1gig"
        CHOWDREN_WORKERS=1
        CHOWDREN_MAKE_JOBS=1
        ;;
esac

echo "PERF_TIER=$PERF_TIER"
echo "MEM_TIER=$MEM_TIER"
echo "CHOWDREN_WORKERS=$CHOWDREN_WORKERS"
echo "CHOWDREN_MAKE_JOBS=$CHOWDREN_MAKE_JOBS"
