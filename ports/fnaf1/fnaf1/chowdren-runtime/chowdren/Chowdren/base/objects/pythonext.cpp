// I don't know why these are defined
#ifdef _MSC_VER
#undef HAVE_UNISTD_H
#undef HAVE_STDINT_H
#endif

#define Py_PYMATH_H
#define FORCE_PYTHON_RELEASE

#if defined(_DEBUG) && defined(FORCE_PYTHON_RELEASE)
#undef _DEBUG
#include <Python.h>
#define _DEBUG
#else
#include <Python.h>
#endif

#include "pythonext.h"
#include <iostream>

void PythonInterpreter::initialize()
{
    static bool initialized = false;
    if (initialized)
        return;
    initialized = true;
    Py_NoSiteFlag = 1;
    Py_SetPythonHome(".");
    Py_Initialize();
    main_module = PyImport_AddModule("__main__");
    interface_module = Py_InitModule("interface", NULL);
    functions_module = PyModule_New("functions");
    PyModule_AddObject(interface_module, "functions", functions_module);
}

void PythonInterpreter::add_function(const char * name, void * fp)
{
    initialize();
    PyCFunction f = (PyCFunction)fp;
    PyMethodDef * methd = new PyMethodDef;
    methd->ml_name = name;
    methd->ml_meth = f;
    methd->ml_flags = METH_VARARGS;
    methd->ml_doc = NULL;
    PyObject * py_f = PyCFunction_New(methd, NULL);
    PyModule_AddObject(functions_module, name, py_f);
    print_errors();
}

PythonInterpreter::PythonInterpreter(int x, int y, int type_id)
: FrameObject(x, y, type_id), parameters(NULL), returns(NULL)
{
    initialize();
}

void PythonInterpreter::print_errors()
{
    if (PyErr_Occurred() != NULL) {
        std::cout << "Error!" << std::endl;
        PyErr_Print();
    }
}

void PythonInterpreter::run_string(std::string str)
{
    str.erase(std::remove(str.begin(), str.end(), '\r'), str.end());
    PyObject * globals = PyModule_GetDict(main_module);
    PyObject * result = PyRun_String(str.c_str(), Py_file_input,
        globals, globals);
    print_errors();
}

void PythonInterpreter::add_parameter(PyObject * v)
{
    if (parameters == NULL)
        parameters = PyList_New(0);
    PyList_Append(parameters, v);
}

void PythonInterpreter::add_parameter(double v)
{
    add_parameter(to_object(v));
}

PyObject * PythonInterpreter::get_none()
{
    return Py_None;
}

PyObject * PythonInterpreter::get_tuple_item(PyObject * t, int i)
{
    return PyTuple_GetItem(t, i);
}

double PythonInterpreter::to_double(PyObject * value)
{
    return *((double*)&value);
}

PyObject * PythonInterpreter::create_object(const std::string & v)
{
    return PyString_FromStringAndSize(v.data(), v.size());
}

PyObject * PythonInterpreter::create_object(int value)
{
    return PyInt_FromLong(value);
}

PyObject * PythonInterpreter::eval(std::string str)
{
    str.erase(std::remove(str.begin(), str.end(), '\r'), str.end());
    PyObject * globals = PyModule_GetDict(main_module);
    PyObject * result = PyRun_String(str.c_str(), Py_eval_input,
        globals, globals);
    print_errors();
    return result;
}

double PythonInterpreter::list_append(double listd, PyObject * value)
{
    PyObject * list = to_object(listd);
    PyList_Append(list, value);
    return listd;
}

double PythonInterpreter::create_list()
{
    return to_double(PyList_New(0));
}

void PythonInterpreter::call_global(const std::string & name)
{
/*        std::cout << "Calling " << name << " from application" << std::endl;*/
    print_errors();
    PyObject * globals = PyModule_GetDict(main_module);
    const char * function_name = name.c_str();
    PyObject * function = PyRun_String(function_name, Py_eval_input,
        globals, globals);
    if (function == NULL) {
        PyErr_Format(PyExc_AttributeError,
            "no global exists with the name '%s'", function_name);
        print_errors();
        return;
    }

    PyObject * parameters;
    if (this->parameters == NULL) {
        parameters = PyTuple_New(0);
    } else {
        parameters = PyList_AsTuple(this->parameters);
        Py_DECREF(this->parameters);
    }
    this->parameters = NULL;
    Py_XDECREF(returns);
    PyObject * result = PyObject_Call(function, parameters, NULL);

    if (result == NULL) {
        Py_INCREF(Py_None);
        returns = Py_None;
        print_errors();
    } else {
        if (!PyTuple_Check(result)) {
            returns = Py_BuildValue("(O)", result);
        } else {
            returns = result;
        }
    }

/*        std::cout << "Call for " << name << " returning to application" << std::endl;*/
    Py_DECREF(parameters);
}

std::string PythonInterpreter::as_string(PyObject * v)
{
    char * buf;
    Py_ssize_t len;
    PyString_AsStringAndSize(PyObject_Str(v), &buf, &len);
    return std::string(buf, len);
}

int PythonInterpreter::as_number(PyObject * v)
{
    return PyInt_AsLong(v);
}

std::string PythonInterpreter::as_string(double v)
{
    return as_string(to_object(v));
}

PyObject * PythonInterpreter::main_module = NULL;
PyObject * PythonInterpreter::interface_module = NULL;
PyObject * PythonInterpreter::functions_module = NULL;
