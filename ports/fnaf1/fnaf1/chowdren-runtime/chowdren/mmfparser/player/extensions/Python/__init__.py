# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

"""
Python.mfx
Python object - Mathias Kaerlev
Copyright 2012 Mathias Kaerlev

Provides a Python interpreter, useful for eg. game scripting.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Run string

    Parameters:
    0: Python script to run (EXPSTRING, ExpressionParameter)
    1: ID (EXPRESSION, ExpressionParameter)
    2: Block? (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        data = self.evaluate_index(0)
        id = self.evaluate_index(1)
        block = self.evaluate_index(2)
        instance.objectPlayer.execute_data(data, id, block)

class Action1(Action):
    """
    Run file

    Parameters:
    0: Python module to run (FILENAME, Filename)
    1: ID (EXPRESSION, ExpressionParameter)
    2: Block? (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.get_filename(self.get_parameter(0))
        id = self.evaluate_index(1)
        block = self.evaluate_index(2)
        instance.objectPlayer.execute_file(filename, id, block)

class Action2(Action):
    """
    Pointers->Delete object

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pointer = self.evaluate_index(0)
        pointer.value = None

class Action3(Action):
    """
    MMF functions->Add return

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pointer = self.evaluate_index(0)
        instance.objectPlayer.outReturn.append(get_object(pointer))

class Action4(Action):
    """
    Pointers->Save object

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action5(Action):
    """
    Python functions->Add parameter

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pointer = self.evaluate_index(0)
        instance.objectPlayer.outArguments.append(get_object(pointer))

class Action6(Action):
    """
    Python functions->Set keyword

    Parameters:
    0: Key (EXPSTRING, ExpressionParameter)
    1: Pointer (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        key = self.evaluate_index(0)
        pointer = self.evaluate_index(1)
        instance.objectPlayer.outKeywords[key] = get_object(pointer)

class Action7(Action):
    """
    Python functions->Call registered function

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        instance.objectPlayer.call_registered(name)

class Action8(Action):
    """
    Python functions->Call global

    Parameters:
    0: Global name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        instance.objectPlayer.call_global(name)

class Action9(Action):
    """
    Run single line

    Parameters:
    0: Python line to run (EXPSTRING, ExpressionParameter)
    1: ID (EXPRESSION, ExpressionParameter)
    2: Block? (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        line = self.evaluate_index(0)
        id = self.evaluate_index(1)
        block = self.evaluate_index(2)
        instance.objectPlayer.execute_single(data, id, block)

# Conditions

class Condition0(Condition):
    """
    On print
    """

    def created(self):
        self.add_handlers(
            on_print = self.on_print)
    
    def on_print(self, instance):
        self.generate()

    def check(self, instance):
        return True

class Condition1(Condition):
    """
    On error
    """
    
    def created(self):
        self.add_handlers(
            on_error = self.on_error)
    
    def on_error(self, instance):
        self.generate()

    def check(self, instance):
        return True

class Condition2(Condition):
    """
    MMF functions->On function

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    1: Number of arguments (EXPRESSION, ExpressionParameter)
    """
    
    def created(self):
        self.name = self.evaluate_index(0)
        self.arguments = self.evaluate_index(1)
        if self.name not in functions:
            functions[self.name] = {}
        if self.arguments in functions[self.name]:
            functions[self.name][self.arguments].append(self)
        else:
            functions[self.name][self.arguments] = [self]

    def check(self, instance):
        return True
    
    def on_detach(self):
        functions[self.name][self.arguments].remove(self)

class Condition3(Condition):
    """
    MMF functions->Has keyword

    Parameters:
    0: Keyword (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        name = self.evaluate_index(0)
        return name in instance.objectPlayer.inKeywords

class Condition4(Condition):
    """
    Pointers->Checking->Is str

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        pointer = self.evaluate_index(0)
        return isinstance(get_object(pointer), str)

class Condition5(Condition):
    """
    Pointers->Checking->Is int

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        pointer = self.evaluate_index(0)
        return isinstance(get_object(pointer), int)

class Condition6(Condition):
    """
    Pointers->Checking->Is sequence

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        pointer = self.evaluate_index(0)
        value = get_object(pointer)
        try:
            iter(value)
            return True
        except TypeError:
            return False

class Condition7(Condition):
    """
    Pointers->Checking->Is valid

    Parameters:
    0: Pointer (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        pointer = self.evaluate_index(0)
        return hasattr(pointer, 'value')

class Condition8(Condition):
    """
    Execution finished

    Parameters:
    0: ID (EXPRESSION, ExpressionParameter)
    """

    def created(self):
        self.add_handlers(
            script_finished = self.script_finished)
    
    def script_finished(self, instance, id):
        if self.evaluate_index(0) != id:
            return
        self.generate()

    def check(self, instance):
        return True

# Expressions

class Expression0(Expression):
    """
    Object->Create->From evaluation

    Parameters:
    0: Script (String)
    Return type: Float
    """

    def get(self, instance):
        data = self.next_argument()
        try:
            value = eval(data, instance.objectPlayer.variables)
        except:
            value = None
        return make_object(value)

class Expression1(Expression):
    """
    Errors->Exception name
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.exception.__class__.__name__

class Expression2(Expression):
    """
    Errors->Details
    Return type: String
    """

    def get(self, instance):
        try:
            tb_type, tb_value, tb = instance.objectPlayer.exception
        except ValueError:
            return ''
        return tb_value

class Expression3(Expression):
    """
    Errors->Traceback
    Return type: String
    """

    def get(self, instance):
        try:
            tb_type, tb_value, tb = instance.objectPlayer.exception
        except ValueError:
            return ''
        if tb is None:
            val = traceback.format_exception_only(tb_type, tb_value)
        else:
            val = traceback.format_exception(tb_type, tb_value, tb)
        return ''.join(val)

class Expression4(Expression):
    """
    Get current print string
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.printLine

class Expression5(Expression):
    """
    MMF functions->Arguments->Get number of arguments
    Return type: Float
    """

    def get(self, instance):
        return len(instance.objectPlayer.inArguments)

class Expression6(Expression):
    """
    MMF functions->Arguments->Get argument pointer

    Parameters:
    0: Position (Int)
    Return type: Float
    """

    def get(self, instance):
        index = self.next_argument()
        return make_object(instance.objectPlayer.inArguments[index])

class Expression7(Expression):
    """
    MMF functions->Arguments->Get keyword pointer

    Parameters:
    0: Key (String)
    Return type: Float
    """

    def get(self, instance):
        key = self.next_argument()
        return make_object(instance.objectPlayer.inKeywords[key])

class Expression8(Expression):
    """
    Pointers->Value->As string

    Parameters:
    0: Pointer (Int)
    Return type: String
    """

    def get(self, instance):
        pointer = self.next_argument()
        return str(get_object(pointer))

class Expression9(Expression):
    """
    Pointers->Value->As representation

    Parameters:
    0: Pointer (Int)
    Return type: String
    """

    def get(self, instance):
        pointer = self.next_argument()
        return repr(get_object(pointer))

class Expression10(Expression):
    """
    Pointers->Value->As number

    Parameters:
    0: Pointer (Int)
    Return type: Float
    """

    def get(self, instance):
        pointer = self.next_argument()
        value = get_object(pointer)
        if value.__class__ in (int, float):
            return value
        try:
            try:
                value = float(value)
            except ValueError:
                return int(value)
        except:
            return 0

class Expression11(Expression):
    """
    Pointers->Get type name

    Parameters:
    0: Pointer (Int)
    Return type: String
    """

    def get(self, instance):
        pointer = self.next_argument()
        return get_object(pointer).__class__.__name__

class Expression12(Expression):
    """
    Object->Create->From number

    Parameters:
    0: Number (Int)
    Return type: Float
    """

    def get(self, instance):
        return make_object(self.next_argument())

class Expression13(Expression):
    """
    Object->Create->From string

    Parameters:
    0: String (String)
    Return type: Float
    """

    def get(self, instance):
        return make_object(self.next_argument())

class Expression14(Expression):
    """
    Object->List->Create list
    Return type: Float
    """

    def get(self, instance):
        return make_object([])

class Expression15(Expression):
    """
    Object->List->Append object

    Parameters:
    0: List object (Int)
    1: Item to add (Int)
    Return type: Float
    """

    def get(self, instance):
        pointer = self.next_argument()
        item = self.next_argument()
        get_object(pointer).append(get_object(item))
        return pointer

class Expression16(Expression):
    """
    Object->List->Get index

    Parameters:
    0: List object (Int)
    1: Index (Int)
    Return type: Float
    """

    def get(self, instance):
        list_object = get_object(self.next_argument())
        index = self.next_argument()
        return make_object(list_object[index])

class Expression17(Expression):
    """
    Python functions->Get return count
    Return type: Float
    """

    def get(self, instance):
        return len(instance.objectPlayer.inReturn)

class Expression18(Expression):
    """
    Python functions->Get return value

    Parameters:
    0: Index (Int)
    Return type: Float
    """

    def get(self, instance):
        return make_object(
            instance.objectPlayer.inReturn[self.next_argument()])

class Expression19(Expression):
    """
    Object->Create->From MMF object

    Parameters:
    0: Fixed value (Int)
    Return type: Float
    """

    def get(self, instance):
        return make_object(None)

class PythonObject(long):
    value = None

def make_object(value):
    instance = PythonObject(id(value))
    instance.value = value
    return instance

def get_object(instance):
    try:
        return instance.value
    except AttributeError:
        print '(invalid pointer: %s)' % instance
        return None

import interface
import sys
sys.modules['interface'] = interface
import traceback

functions = {}

class DefaultObject(HiddenObject):
    def created(self):
        self.ids = {}
        self.variables = {}
        self.registered = {}
        interface.set_current(self)
        
        self.inReturn = []
        self.inKeywords = {}
        self.inArguments = []
        self.outReturn = []
        self.outKeywords = {}
        self.outArguments = []
        
        self.exception = (None, None, None)
        
    def get_function(self, name):
        def on_call(*arg, **kw):
            return self.on_call(name, *arg, **kw)
        return on_call
    
    def on_call(self, name, *arg, **kw):
        try:
            arg_dict = functions[name]
        except KeyError:
            raise NotImplementedError('function %s not found' % name)
        try:
            conditions = arg_dict[len(arg)]
        except KeyError:
            try:
                conditions = arg_dict[-1]
            except KeyError:
                raise NotImplementedError(
                    'function %s does not take %s parameters' % (name, len(arg)))
        oldReturn = self.outReturn
        oldArguments = self.inArguments
        oldKeywords = self.inKeywords
        
        self.outReturn = newReturn = []
        self.inArguments = arg
        self.inKeywords = kw
        for condition in conditions:
            condition.generate()
        self.outReturn = oldReturn
        self.inArguments = oldArguments
        self.inKeywords = oldKeywords
        if len(newReturn) == 0:
            return None
        if len(newReturn) == 1:
            return newReturn[0]
        else:
            return tuple(newReturn)
    
    def call_registered(self, name):
        try:
            func = self.registered[name]
        except KeyError:
            self.set_error((AttributeError, 'no such registered function', None))
            return
        self.call_function(func)
    
    def call_global(self, name):
        func = eval(name, self.variables)
        self.call_function(func)
            
    def call_function(self, func):
        outArguments = self.outArguments
        outKeywords = self.outKeywords
        self.outArguments = []
        self.outKeywords = {}
        ret = func(*outArguments, **outKeywords)
        if type(ret) != tuple:
            ret = (ret,)
        self.inReturn = ret
        
    def add_registered(self, name, func):
        self.registered[name] = func
    
    def set_error(self, value = None):
        if value is None:
            value = sys.exc_info()
        self.exception = value
        self.fire_handler('on_error')
    
    def execute_data(self, data, id, block):
        # blocking isn't implemented yet
        data = data.replace('\r\n', '\n')
        
        if not block:
            print '(non-blocking not supported)'
        try:
            exec data in self.variables
        except:
            self.set_error()
        else:
            self.fire_handler('script_finished', id)
    
    def execute_file(self, filename, id, block):
        # blocking isn't implemented yet
        if not block:
            print '(non-blocking not supported)'
        try:
            execfile(filename, self.variables)
        except:
            self.set_error()
        else:
            self.fire_handler('script_finished', id)

class Python(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
    }

extension = Python()

def get_extension():
    return extension
