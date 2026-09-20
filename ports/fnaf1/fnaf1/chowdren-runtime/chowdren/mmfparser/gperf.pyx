from libcpp.string cimport string
from libc.stdlib cimport malloc, free
from libcpp.vector cimport vector

cdef extern from "./gperf/frontend.cc":
    cdef struct KeywordResult:
        string value
        int hash_value

    cdef struct TableInfo:
        int count
        int min_word_length
        int max_word_length
        int min_hash_value
        int max_hash_value

    cdef void init()
    cdef string c_get_hash_function(char * name, object value,
                                    vector[KeywordResult] & out,
                                    TableInfo & info, bint case_sensitive)

class HashFunction(object):
    def __init__(self, code, strings):
        self.code = code
        self.strings = strings

def get_hash_function(bytes name, list strings,
                      bint case_sensitive=True):
    cdef vector[KeywordResult] out
    cdef TableInfo info
    cdef bytes code = c_get_hash_function(name, strings, out, info,
                                          case_sensitive)
    cdef out_strings = {}
    cdef KeywordResult keyword
    for keyword in out:
        out_strings[keyword.value] = keyword.hash_value
    ret = HashFunction(code, out_strings)
    ret.count = info.count
    ret.min_word_length = info.min_word_length
    ret.max_word_length = info.max_word_length
    ret.min_hash_value = info.min_hash_value
    ret.max_hash_value = info.max_hash_value
    return ret

init()
