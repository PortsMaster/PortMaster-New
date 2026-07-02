#!/bin/bash
# Hardware detection for Dead Cells patching pipeline.
#
# Reads PortMaster env vars (DEVICE_CPU, DEVICE_RAM) and prints
# PERF_TIER and MEM_TIER assignments to stdout.
#
# Usage (from other scripts):
#   eval "$("$GAMEDIR/patch/detect_hw.bash")"
#
# Executed (not sourced) to avoid FUSE deadlocks on KNULLI exFAT.

# Performance tier
case "${DEVICE_CPU,,}" in
    rk3326|a133plus|a133p|h700)           PERF_TIER="slow" ;;
    rk356*|a523|sd6*|cortex-a5*)         PERF_TIER="fast" ;;
    sd865|sd8*|cortex-a7*)               PERF_TIER="ultra" ;;
    *)                                   PERF_TIER="slow" ;;
esac

# Memory tier
if [ "${DEVICE_RAM:-1}" -le 1 ]; then
    MEM_TIER="1gig"
    # 1GB can't hold normal maps in RAM — disable lighting regardless of CPU
    PERF_TIER="slow"
else
    MEM_TIER="2gig"
fi

echo "PERF_TIER=$PERF_TIER"
echo "MEM_TIER=$MEM_TIER"
