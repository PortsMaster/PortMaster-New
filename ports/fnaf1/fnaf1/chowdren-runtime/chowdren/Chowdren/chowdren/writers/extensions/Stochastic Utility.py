from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table)

class Util(ObjectWriter):
    class_name = 'Utility'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    1 : 'SetRandomSeedToTimer'
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
    0 : 'IntGenerateRandom',
    1 : 'GenerateRandom',
    3 : 'Substr',
    4 : 'Nearest',
    6 : 'ModifyRange',
    2 : 'Limit',
    13 : 'IntNearest',
    15 : 'IntModifyRange',
    21 : 'ExpressionCompare',
    22 : 'IntExpressionCompare',
    23 : 'StrExpressionCompare',
    8 : 'EuclideanMod',
    12 : 'IntLimit',
    24 : 'Approach',
    18 : 'IntUberMod',
    7 : 'Wave',
    9 : 'UberMod',
    11 : 'Mirror',
    17 : 'IntEuclideanMod',
    19 : 'IntInterpolate',
    25 : 'IntApproach',
    16 : 'IntWave',
    10 : 'Interpolate'
})

def get_object():
    return Util