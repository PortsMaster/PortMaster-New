cdef extern from "./zopfli/frontend.cpp":
    cdef bytes compress_zopfli(char * data, size_t size)
    cdef void init_zopfli()

init_zopfli()

def compress(data, level=None):
    return compress_zopfli(data, len(data))
