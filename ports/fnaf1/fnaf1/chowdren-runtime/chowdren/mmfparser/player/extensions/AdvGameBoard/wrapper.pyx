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

cdef class DataContainer

cdef extern from "Main.cpp":
    ctypedef struct RUNDATA:
        int	BSizeX
        int BSizeY
        int MinConnected
        int OriginX
        int OriginY
        int CellWidth
        int CellHeight
        bint MoveFixed
        bint TriggerMoved
        bint TriggerDeleted
        int AddIncrement
        void * objectPlayer
        void (*generate)(RUNDATA *, int)
        void (*changePosition)(RUNDATA *, int, int, int)
    
    void initialize(RUNDATA * rdPtr)
    void detach(RUNDATA * rdPtr)
    RUNDATA * create()
    long conOnFoundConnected(RUNDATA * rdPtr, long param1, long param2)
    long conOnFoundBrick(RUNDATA * rdPtr, long param1, long param2)
    long conOnFoundLooped(RUNDATA * rdPtr, long param1, long param2)
    long conOnNoFoundConnected(RUNDATA * rdPtr, long param1, long param2)
    long conBrickCanFallUp(RUNDATA * rdPtr, long param1, long param2)
    long conBrickCanFallDown(RUNDATA * rdPtr, long param1, long param2)
    long conBrickCanFallLeft(RUNDATA * rdPtr, long param1, long param2)
    long conBrickCanFallRight(RUNDATA * rdPtr, long param1, long param2)
    long conOnBrickMoved(RUNDATA * rdPtr, long param1, long param2)
    long conOnBrickDeleted(RUNDATA * rdPtr, long param1, long param2)
    long conIsEmpty(RUNDATA * rdPtr, long param1, long param2)
    short actSetBrick(RUNDATA * rdPtr, long p1, long p2, long p3)
    short actClear(RUNDATA * rdPtr, long param1, long param2)
    short actSetBoadSize(RUNDATA * rdPtr, long param1, long param2)
    short actSetMinConnected(RUNDATA * rdPtr, long param1, long param2)
    short actSearchHorizontal(RUNDATA * rdPtr, long param1, long param2)
    short actSearchVertical(RUNDATA * rdPtr, long param1, long param2)
    short actSearchDiagonalsLR(RUNDATA * rdPtr, long param1, long param2)
    short actSearchDiagonalsRL(RUNDATA * rdPtr, long param1, long param2)
    short actSearchConnected(RUNDATA * rdPtr, long param1, long param2)
    short actDeleteHorizonal(RUNDATA * rdPtr, long param1, long param2)
    short actDeleteVertical(RUNDATA * rdPtr, long param1, long param2)
    short actSwap(RUNDATA * rdPtr, long p1, long p2, long p3, long p4)
    short actUndoSwap(RUNDATA * rdPtr, long param1, long param2)
    short actDropX(RUNDATA * rdPtr, long param1, long param2)
    short actDropOne(RUNDATA * rdPtr, long param1, long param2)
    short actMarkUsed(RUNDATA * rdPtr, long param1, long param2)
    short actDeleteMarked(RUNDATA * rdPtr, long param1, long param2)
    short actLoopFoundBricks(RUNDATA * rdPtr, long param1, long param2)
    short actSetFixedOfBrick(RUNDATA * rdPtr, long p1, long p2, long p3)
    short actImportActives(RUNDATA * rdPtr, long fixed)
    short actMarkCurrentSystem(RUNDATA * rdPtr, long param1, long param2)
    short actMarkCurrentBrick(RUNDATA * rdPtr, long param1, long param2)
    short actLoopEntireBoard(RUNDATA * rdPtr, long param1, long param2)
    short actLoopBoardOfType(RUNDATA * rdPtr, long param1, long param2)
    short actLoopSorrounding(RUNDATA * rdPtr, long param1, long param2)
    short actLoopHozLine(RUNDATA * rdPtr, long param1, long param2)
    short actLoopVerLine(RUNDATA * rdPtr, long param1, long param2)
    short actClearWithType(RUNDATA * rdPtr, long param1, long param2)
    short actInsertBrick(RUNDATA * rdPtr, long p1, long p2, long p3)
    short actSetOrigin(RUNDATA * rdPtr, long param1, long param2)
    short actSetCellDimensions(RUNDATA * rdPtr, long param1, long param2)
    short actMoveFixedON(RUNDATA * rdPtr, long param1, long param2)
    short actMoveFixedOFF(RUNDATA * rdPtr, long param1, long param2)
    short actMoveBrick(RUNDATA * rdPtr, long p1, long p2, long p3, long p4)
    short actDropOneUp(RUNDATA * rdPtr, long param1, long param2)
    short actDropOneLeft(RUNDATA * rdPtr, long param1, long param2)
    short actDropOneRight(RUNDATA * rdPtr, long param1, long param2)
    short actDropXUp(RUNDATA * rdPtr, long param1, long param2)
    short actDropXLeft(RUNDATA * rdPtr, long param1, long param2)
    short actDropXRight(RUNDATA * rdPtr, long param1, long param2)
    short actSetCellValue(RUNDATA * rdPtr, long p1, long p2, long p3)
    short actDeleteBrick(RUNDATA * rdPtr, long param1, long param2)
    short actShiftHosLine(RUNDATA * rdPtr, long param1, long param2)
    short actShiftVerLine(RUNDATA * rdPtr, long param1, long param2)
    short actPositionBricks(RUNDATA * rdPtr, long param1, long param2)
    long expGetBrickAt(RUNDATA * rdPtr, long p1, long p2)
    long expGetXSize(RUNDATA * rdPtr, long param1)
    long expGetYSize(RUNDATA * rdPtr, long param1)
    long expGetNumBricksInSystem(RUNDATA * rdPtr, long param1)
    long expGetXofBrick(RUNDATA * rdPtr, long p1)
    long expGetYofBrick(RUNDATA * rdPtr, long p1)
    long expGetFoundBrickType(RUNDATA * rdPtr, long param1)
    long expGetNumBricksInHozLine(RUNDATA * rdPtr, long p1)
    long expGetNumBricksInVerLine(RUNDATA * rdPtr, long p1)
    long expCountSorrounding(RUNDATA * rdPtr, long p1, long p2, long p3)
    long expCountTotal(RUNDATA * rdPtr, long param1)
    long expGetFoundBrickFixed(RUNDATA * rdPtr, long p1)
    long expGetFoundXofBrick(RUNDATA * rdPtr, long param1)
    long expGetFoundYofBrick(RUNDATA * rdPtr, long param1)
    long expGetTypeofBrick(RUNDATA * rdPtr, long param1)
    long expGetFixedOfBrick(RUNDATA * rdPtr, long param1)
    long expGetFixedAt(RUNDATA * rdPtr, long p1, long p2)
    long expLoopIndex(RUNDATA * rdPtr, long param1)
    long expFindXfromFixed(RUNDATA * rdPtr, long p1)
    long expFindYfromFixed(RUNDATA * rdPtr, long p1)
    long expFindBrickfromFixed(RUNDATA * rdPtr, long p1)
    long expGetLoopFoundXofBrick(RUNDATA * rdPtr, long param1)
    long expGetLoopFoundYofBrick(RUNDATA * rdPtr, long param1)
    long expGetLoopTypeofBrick(RUNDATA * rdPtr, long param1)
    long expGetLoopFoundBrickFixed(RUNDATA * rdPtr, long param1)
    long expLoopLoopIndex(RUNDATA * rdPtr, long param1)
    long expGetXBrickFromX(RUNDATA * rdPtr, long p1)
    long expGetYBrickFromY(RUNDATA * rdPtr, long p1)
    long expSnapXtoGrid(RUNDATA * rdPtr, long p1)
    long expSnapYtoGrid(RUNDATA * rdPtr, long p1)
    long expGetOriginX(RUNDATA * rdPtr, long param1)
    long expGetOriginY(RUNDATA * rdPtr, long param1)
    long expGetCellWidth(RUNDATA * rdPtr, long param1)
    long expGetCellHeight(RUNDATA * rdPtr, long param1)
    long expGetCellValue(RUNDATA * rdPtr, long p1, long p2)
    long expGetXofCell(RUNDATA * rdPtr, long p1)
    long expGetYofCell(RUNDATA * rdPtr, long p1)
    long expMovedFixed(RUNDATA * rdPtr, long param1)
    long expMovedNewX(RUNDATA * rdPtr, long param1)
    long expMovedNewY(RUNDATA * rdPtr, long param1)
    long expMovedOldX(RUNDATA * rdPtr, long param1)
    long expMovedOldY(RUNDATA * rdPtr, long param1)
    long expDeletedFixed(RUNDATA * rdPtr, long param1)
    long expDeletedX(RUNDATA * rdPtr, long param1)
    long expDeletedY(RUNDATA * rdPtr, long param1)
    void * actions[]
    void * expressions[]
    void * conditions[]

cdef void generate(RUNDATA * rdPtr, int type):
    objectPlayer = <object>rdPtr.objectPlayer
    objectPlayer.generate(type)

cdef void changePosition(RUNDATA * rdPtr, int fixed, int x, int y):
    objectPlayer = <object>rdPtr.objectPlayer
    instance = objectPlayer.player.frame.get_fixed_object(fixed)
    if instance is None:
        return
    instance.set_position(x, y)

cdef class DataContainer:
    cdef object parent
    cdef RUNDATA * rdPtr
    def __init__(self, parent, data):
        self.parent = parent
        cdef RUNDATA * rdPtr = create()
        self.rdPtr = rdPtr
        rdPtr.BSizeX = data.readInt()
        rdPtr.BSizeY = data.readInt()
        rdPtr.MinConnected = data.readInt()
        rdPtr.OriginX = data.readInt()
        rdPtr.OriginY = data.readInt()
        rdPtr.CellWidth = data.readInt()
        rdPtr.CellHeight = data.readInt()
        rdPtr.MoveFixed = data.readByte()
        rdPtr.TriggerMoved = data.readByte()
        rdPtr.TriggerDeleted = data.readByte()
        rdPtr.generate = generate
        rdPtr.changePosition = changePosition
        rdPtr.objectPlayer = <void *>parent
        initialize(rdPtr)
    
    def update(self):
        self.rdPtr.AddIncrement = 0
    
    def on_detach(self):
        detach(self.rdPtr)

cdef inline RUNDATA * getPointer(instance):
    return (<DataContainer>instance.objectPlayer.data).rdPtr

def call_wrapper_a(id, instance, *arg):
    cdef void * func = actions[id]
    cdef RUNDATA * rdPtr = getPointer(instance)
    arg = list(arg)
    while len(arg) < 2:
        arg.append(0)
    if len(arg) == 2:
        (<short(*) (RUNDATA *, long, long)> func)(rdPtr,
            arg[0], arg[1])
    elif len(arg) == 3:
        (<short(*) (RUNDATA *, long, long, long)> func)(rdPtr,
            arg[0], arg[1], arg[2])
    elif len(arg) == 4:
        (<short(*) (RUNDATA *, long, long, long, long)> func)(rdPtr,
            arg[0], arg[1], arg[2], arg[3])

def call_wrapper_c(id, instance, *arg):
    cdef void * func = conditions[id]
    cdef RUNDATA * rdPtr = getPointer(instance)
    arg = list(arg)
    while len(arg) < 2:
        arg.append(0)
    cdef long ret
    if len(arg) == 2:
        ret = (<long(*) (RUNDATA *, long, long)> func)(rdPtr,
            arg[0], arg[1])
    elif len(arg) == 3:
        ret = (<long(*) (RUNDATA *, long, long, long)> func)(rdPtr,
            arg[0], arg[1], arg[2])
    elif len(arg) == 4:
        ret = (<long(*) (RUNDATA *, long, long, long, long)> func)(rdPtr,
            arg[0], arg[1], arg[2], arg[3])
    return ret

def call_wrapper_e(id, instance, *arg):
    cdef void * func = expressions[id]
    cdef RUNDATA * rdPtr = getPointer(instance)
    arg = list(arg)
    while len(arg) < 1:
        arg.append(0)
    cdef long ret
    if len(arg) == 1:
        ret = (<long(*) (RUNDATA *, long)> func)(rdPtr,
            arg[0])
    elif len(arg) == 2:
        ret = (<long(*) (RUNDATA *, long, long)> func)(rdPtr,
            arg[0], arg[1])
    elif len(arg) == 3:
        ret = (<long(*) (RUNDATA *, long, long, long)> func)(rdPtr,
            arg[0], arg[1], arg[2])
    elif len(arg) == 4:
        ret = (<long(*) (RUNDATA *, long, long, long, long)> func)(rdPtr,
            arg[0], arg[1], arg[2], arg[3])
    return ret