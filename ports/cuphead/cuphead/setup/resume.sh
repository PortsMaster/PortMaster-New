# The conversion run again when the kernel kills it (sourced by the setups, after their pm()). On a
# 1 GB handheld without swap the converter's biggest textures can need more memory than is free
# beside the firmware, and the kernel kills it (an RG351MP: twice in the textures, each time on a
# file a new launch then converted at once). Every step of `pmunity convert` journals each file it
# finishes (<data>/.pmunity.json), so a new process continues after the last one: pm_convert
# starts one by itself while the killed runs keep finishing files.

pm_convert() {   # pm_convert <data folder> <pmunity convert args>
  local j="$1/.pmunity.json" n rc
  while :; do
    n=$(journal_files "$j")
    pm convert "$@"; rc=$?
    [ "$rc" = 137 ] && [ "$(journal_files "$j")" -gt "$n" ] || return "$rc"   # (137: SIGKILL)
    # (the kernel's reason, with the process's size when it was killed, where dmesg can be read)
    dmesg 2>/dev/null | grep -a -i -E 'out of memory|killed process' | tail -n 2
    echo "The conversion was stopped by the system (out of memory?): it starts again where it stopped."
  done
}

journal_files() {   # journal_files <.pmunity.json>: the files its steps have finished (0 before the first)
  PYTHONHOME="$python_dir" LD_LIBRARY_PATH="$python_dir/libs:$LD_LIBRARY_PATH" "$python_dir/bin/python3" -c \
    'import json, sys; print(sum(map(len, json.load(open(sys.argv[1]))["done"].values())))' "$1" 2>/dev/null || echo 0
}
