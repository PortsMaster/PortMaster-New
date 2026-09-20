cdef extern from "./webp/frontend.cpp":
    cdef bytes encode_webp(char * rgba, int width, int height)

def encode(data, width, height):
    return encode_webp(data, width, height)