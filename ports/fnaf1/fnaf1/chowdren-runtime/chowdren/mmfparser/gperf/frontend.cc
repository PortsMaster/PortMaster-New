// this will crash, but we use it to stay compatible with PyPy
#define PyByteArray_FromStringAndSize(s, l) NULL

#include "version.cc"
#include "positions.cc"
#include "keyword.cc"
#include "keyword-list.cc"
#include "bool-array.cc"
#include "hash-table.cc"
#include "search.cc"
#include "output.cc"
// #include "main.cc"
#include "options.cc"
#include "hash.cc"
#include <string>
#include <vector>

void init()
{
    // XXX set options in the future
}

struct TableInfo
{
    int count;
    int min_word_length;
    int max_word_length;
    int min_hash_value;
    int max_hash_value;
};

struct KeywordResult
{
    std::string value;
    int hash_value;
};

std::string c_get_hash_function(char * name, PyObject * list,
                                std::vector<KeywordResult> & res,
                                TableInfo & info, int case_sensitive)
{
    option._hash_name = name;
    if (case_sensitive)
        option._option_word &= ~UPPERLOWER;
    else
        option._option_word |= UPPERLOWER;

    KeywordExt_List * head;
    KeywordExt_List ** tail = &head;

    PyObject * seq = PySequence_Fast(list, "expected a sequence");
    Py_ssize_t  len = PySequence_Size(list);
    for (int i = 0; i < len; i++) {
        PyObject * item = PyList_GET_ITEM(seq, i);

        char * s;
        Py_ssize_t length;
        PyString_AsStringAndSize(item, &s, &length);

        KeywordExt *new_kw = new KeywordExt (s, length, "");
        new_kw->_lineno = 0;
        *tail = new KeywordExt_List (new_kw);
        tail = &(*tail)->rest();
    }
    Py_DECREF(seq);

    /* Search for a good hash function.  */
    Search searcher (head);
    searcher.optimize ();

    /* Output the hash function code.  */
    Output outputter (searcher._head,
                      "struct_decl", // struct_decl,
                      0, // struct_decl_lineno,
                      "return_type", // return_type,
                      "struct_tag", // struct_tag,
                      NULL, // verbatim_declarations,
                      NULL, // verbatim_declarations_end,
                      0, // verbatim_declarations_lineno,
                      NULL, // verbatim_code,
                      NULL, // verbatim_code_end,
                      0, // verbatim_code_lineno,
                      false, // charset_dependent,
                      searcher._total_keys,
                      searcher._max_key_len,
                      searcher._min_key_len,
                      searcher._hash_includes_len,
                      searcher._key_positions,
                      searcher._alpha_inc,
                      searcher._total_duplicates,
                      searcher._alpha_size,
                      searcher._asso_values);
    outputter.output ();

    KeywordExt_List *it;
    for (it = searcher._head; it; it = it->rest()) {
        KeywordExt * k = it->first();
        KeywordResult r;
        r.value = std::string(k->_allchars, k->_allchars_length);
        r.hash_value = k->_hash_value;
        res.push_back(r);
        delete k;
    }

    info.count = outputter._total_keys;
    info.min_word_length = outputter._min_key_len;
    info.max_word_length = outputter._max_key_len;
    info.min_hash_value = outputter._min_hash_value;
    info.max_hash_value = outputter._max_hash_value;

    return outputter.get_str();
}
