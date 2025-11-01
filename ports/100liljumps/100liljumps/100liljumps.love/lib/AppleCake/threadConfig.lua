local id = "AppleCake.Thread"

return {
  outStreamID = id..".Out",
  infoID      = id..".Info",
  dict = { -- dictionary for string.buffer
    "command",
    "buffer",
    "name",
    "start",
    "finish",
    "args",
    "scope",
    "Memory usage",
    "process_name",
    "thread_name",
    "thread_sort_index",
  }
}