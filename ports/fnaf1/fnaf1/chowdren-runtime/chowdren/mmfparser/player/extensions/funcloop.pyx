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
funcloop.mfx
V2Template32 object - ClickTeam (http://www.clickteam.com)
Copyright 2000 Clickteam

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension
from mmfparser.player.objects.common cimport ObjectPlayer
from mmfparser.player.event.actions.common cimport Action
from mmfparser.player.event.conditions.common cimport Condition
from mmfparser.player.event.expressions.common cimport Expression
from mmfparser.player.instance cimport Instance

# Actions

cdef class DefaultObject
cdef class OnLoop
cdef class OnFunction

cdef class FunctionAction(Action):
    cdef public:
        list conditions
        str name

    cdef void execute_instance(self, Instance instance):
        cdef DefaultObject objectPlayer = instance.objectPlayer
        
        # save <3
        oldIntA = objectPlayer.intA
        oldIntB = objectPlayer.intB
        oldStringA = objectPlayer.stringA
        oldStringB = objectPlayer.stringB
        oldArguments = objectPlayer.arguments
        
        # set arguments
        objectPlayer.arguments = objectPlayer.waitingArguments
        objectPlayer.waitingArguments = []
        
        self.set_arguments(objectPlayer)
        objectPlayer.returned = False
        cdef str name = self.evaluate_index(0)
        cdef list conditions
        if name == self.name:
            conditions = self.conditions
        else:
            conditions = self.conditions = [item for item in 
                self.get_conditions(OnFunction) 
                if (<OnFunction>item).get_name() == name]
            self.name = name
        cdef Condition condition
        for condition in conditions:
            condition.generate()
            if objectPlayer.returned:
                objectPlayer.returned = False
                break
        
        # restore <3
        objectPlayer.intA = oldIntA
        objectPlayer.intB = oldIntB
        objectPlayer.stringA = oldStringA
        objectPlayer.stringB = oldStringB
        objectPlayer.arguments = oldArguments
    
    cdef void set_arguments(self, DefaultObject objectPlayer):
        pass

cdef class Action0(FunctionAction):
    """
    Call function

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    """

cdef class Action1(FunctionAction):
    """
    Call function ( Int )

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    1: Int argument (EXPRESSION, ExpressionParameter)
    """

    cdef void set_arguments(self, DefaultObject objectPlayer):
        objectPlayer.intA = self.evaluate_index(1)

cdef class Action2(FunctionAction):
    """
    Call function ( Int, Int )

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    1: Int argument (EXPRESSION, ExpressionParameter)
    2: Int argument (EXPRESSION, ExpressionParameter)
    """

    cdef void set_arguments(self, DefaultObject objectPlayer):
        objectPlayer.intA = self.evaluate_index(1)
        objectPlayer.intB = self.evaluate_index(2)

cdef class Action3(FunctionAction):
    """
    Call function ( String )

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    1: String argument (EXPSTRING, ExpressionParameter)
    """

    cdef void set_arguments(self, DefaultObject objectPlayer):
        objectPlayer.stringA = self.evaluate_index(1)

cdef class Action4(FunctionAction):
    """
    Call function ( String, String )

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    1: String argument (EXPSTRING, ExpressionParameter)
    2: String argument (EXPSTRING, ExpressionParameter)
    """

    cdef void set_arguments(self, DefaultObject objectPlayer):
        objectPlayer.stringA = self.evaluate_index(1)
        objectPlayer.stringB = self.evaluate_index(2)

cdef class Action5(FunctionAction):
    """
    Call function ( Int, String )

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    1: Int argument (EXPRESSION, ExpressionParameter)
    2: String argument (EXPSTRING, ExpressionParameter)
    """

    cdef void set_arguments(self, DefaultObject objectPlayer):
        objectPlayer.intA = self.evaluate_index(1)
        objectPlayer.stringB = self.evaluate_index(2)

cdef class ArgumentAction(Action):
    cdef void execute_instance(self, Instance instance):
        <DefaultObject>(instance.objectPlayer).waitingArguments.append(
            self.evaluate_index(0))

cdef class Action6(ArgumentAction):
    """
    Function Arugments->Add int argument

    Parameters:
    0: Int argument (EXPRESSION, ExpressionParameter)
    """

cdef class Action7(ArgumentAction):
    """
    Function Arugments->Add float argument

    Parameters:
    0: Float argument (EXPRESSION, ExpressionParameter)
    """

cdef class Action8(ArgumentAction):
    """
    Function Arugments->Add string argument

    Parameters:
    0: String argument (EXPSTRING, ExpressionParameter)
    """

cdef class ReturnAction(Action):
    cdef void execute_instance(self, Instance instance):
        cdef DefaultObject objectPlayer = instance.objectPlayer
        objectPlayer.returned = True
        objectPlayer.returnValue = self.get_return(instance)
    
    cdef object get_return(self, Instance instance):
        return None

cdef class Action9(ReturnAction):
    """
    Return->Return
    """

cdef class ReturnVariableAction(ReturnAction):
    cdef object get_return(self, Instance instance):
        return self.evaluate_index(0)

cdef class Action10(ReturnVariableAction):
    """
    Return->Return an int

    Parameters:
    0: Int to return (EXPRESSION, ExpressionParameter)
    """

cdef class Action11(ReturnVariableAction):
    """
    Return->Return a float

    Parameters:
    0: Float to return (EXPRESSION, ExpressionParameter)
    """

cdef class Action12(ReturnVariableAction):
    """
    Return->Return a string

    Parameters:
    0: String to return (EXPSTRING, ExpressionParameter)
    """

cdef class Action13(Action):
    """
    Start a loop

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    1: Number of loops (EXPRESSION, ExpressionParameter)
    """
    cdef public:
        list conditions
        str name

    cdef void execute_instance(self, Instance instance):
        name = self.evaluate_index(0)
        cdef list conditions
        if name == self.name:
            conditions = self.conditions
        else:
            conditions = [item for item in self.get_conditions(OnLoop)
                if (<OnLoop>item).get_name() == name]
            self.conditions = conditions
            self.name = name
        cdef DefaultObject objectPlayer = instance.objectPlayer
        cdef int oldIndex = objectPlayer.loopIndex
        objectPlayer.loopStopped = False
        objectPlayer.loopIndex = 0
        cdef int loops = self.evaluate_index(1)
        cdef Condition condition
        while objectPlayer.loopIndex < loops:
            objectPlayer.loopIndexes[self.name] = objectPlayer.loopIndex
            for condition in conditions:
                condition.generate()
                if objectPlayer.loopStopped:
                    break
            if objectPlayer.loopStopped:
                objectPlayer.loopStopped = False
                break
            objectPlayer.loopIndex += 1
        del objectPlayer.loopIndexes[self.name]
        objectPlayer.loopIndex = oldIndex

cdef class Action14(Action):
    """
    Stop curent loop
    """

    cdef void execute_instance(self, Instance instance):
        (<DefaultObject>instance.objectPlayer).loopStopped = True

cdef class Action15(Action):
    """
    Set loop index

    Parameters:
    0: Index to set (EXPRESSION, ExpressionParameter)
    """

    cdef void execute_instance(self, Instance instance):
        (<DefaultObject>instance.objectPlayer).loopIndex = self.evaluate_expression(
            self.get_parameter(0))


# Conditions

cdef class OnFunction(Condition):
    """
    On Function

    Parameters:
    0: Function name (EXPSTRING, ExpressionParameter)
    """
    cdef public:
        str name

    cdef bint check_instance(self, Instance instance):
        return self.isTriggered
    
    cdef str get_name(self):
        if self.name is None:
            self.name = self.evaluate_index(0)
        return self.name

cdef class OnLoop(Condition):
    """
    On loop

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """
    cdef public:
        str name

    cdef bint check_instance(self, Instance instance):
        return self.isTriggered
    
    cdef str get_name(self):
        if self.name is None:
            self.name = self.evaluate_index(0)
        return self.name

# Expressions

cdef class Expression0(Expression):
    """
    Get loop index of a loop

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    cdef object evaluate_instance(self, Instance instance):
        return (<DefaultObject>instance.objectPlayer).loopIndexes.get(self.next_argument(), 0)

cdef class Expression1(Expression):
    """
    Get current loop index
    Return type: Int
    """

    cdef object evaluate_instance(self, Instance instance):
        return (<DefaultObject>instance.objectPlayer).loopIndex

cdef class Expression2(Expression):
    """
    Get int argument A
    Return type: Int
    """

    cdef object evaluate_instance(self, Instance instance):
        return (<DefaultObject>instance.objectPlayer).intA or 0

cdef class Expression3(Expression):
    """
    Get int argument B
    Return type: Int
    """

    cdef object evaluate_instance(self, Instance instance):
        return (<DefaultObject>instance.objectPlayer).intB or 0

cdef class Expression4(Expression):
    """
    Get string argument A
    Return type: String
    """

    cdef object evaluate_instance(self, Instance instance):
        return (<DefaultObject>instance.objectPlayer).stringA or ''

cdef class Expression5(Expression):
    """
    Get string argument B
    Return type: String
    """

    cdef object evaluate_instance(self, Instance instance):
        return (<DefaultObject>instance.objectPlayer).stringB or ''

cdef class Expression6(Expression):
    """
    Get value argument at

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    cdef object evaluate_instance(self, Instance instance):
        try:
            return (<DefaultObject>instance.objectPlayer).arguments[self.next_argument() - 1]
        except IndexError:
            return 0

cdef class Expression7(Expression):
    """
    Get string argument at

    Parameters:
    0: (not found) (Int)
    Return type: String
    """

    cdef object evaluate_instance(self, Instance instance):
        try:
            return (<DefaultObject>instance.objectPlayer).arguments[self.next_argument() - 1]
        except IndexError:
            return ''

cdef class Expression8(Expression):
    """
    Get return value
    Return type: Int
    """

    cdef object evaluate_instance(self, Instance instance):
        if isinstance((<DefaultObject>instance.objectPlayer).returnValue, int):
            return (<DefaultObject>instance.objectPlayer).returnValue
        return 0

cdef class Expression9(Expression):
    """
    Get return string
    Return type: String
    """

    cdef object evaluate_instance(self, Instance instance):
        if isinstance((<DefaultObject>instance.objectPlayer).returnValue, str):
            return (<DefaultObject>instance.objectPlayer).returnValue
        return ''

cdef class DefaultObject(ObjectPlayer):
    cdef public:
        int loopIndex
        dict loopIndexes
        object stringA, stringB, intA, intB
        list arguments
        list waitingArguments
        object returnValue
        bint returned
        bint loopStopped

    def created(self, data):
        self.loopIndexes = {}
        self.arguments = []
        self.waitingArguments = []

class funcloop(UserExtension):
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
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
        15 : Action15,
    }
    
    conditions = {
        0 : OnFunction,
        1 : OnLoop,
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
    }

extension = funcloop()

def get_extension():
    return extension
