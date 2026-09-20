from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)

def read_vec2(reader):
    return (reader.readFloat(), reader.readFloat())

class Box2D(ObjectWriter):
    class_name = 'Box2D'
    use_alterables = True
    filename = 'box2d/box2dext'
    update = True

    def write_init(self, writer):
        data = self.get_data()
        writer.putln('maxBodies = %s;' % data.readInt())
        writer.putln('maxJoints = %s;' % data.readInt())
        writer.putln('maxBodyDefs = %s;' % data.readInt())
        writer.putln('maxShapeDefs = %s;' % data.readInt())
        writer.putln('maxJointDefs = %s;' % data.readInt())
        writer.putln('gravity = b2Vec2%s;' % (read_vec2(data),))

        upper_bound = read_vec2(data)
        lower_bound = read_vec2(data)
        scale = data.readFloat()

        writer.putln('scale = %s;' % scale)
        writer.putln('bounds.upperBound = (1.0f / scale) * b2Vec2%s;' %
            (upper_bound,))
        writer.putln('bounds.lowerBound = (1.0f / scale) * b2Vec2%s;' %
            (lower_bound,))

        writer.putln('allowSleep = %s;' % data.readInt())
        writer.putln('posIterations = %s;' % data.readInt())
        writer.putln('velIterations = %s;' % data.readInt())
        writer.putln('timestep = %s;' % data.readFloat())
        writer.putln('WarmStart = %s;' % data.readByte())
        writer.putln('PosCorrection = %s;' % data.readByte())
        writer.putln('CCD = %s;' % data.readByte())
        writer.putln('floatAngles = %s;' % data.readByte())
        writer.putln('autoUpdate = %s;' % data.readInt())
        writer.putln('settings.b2_maxPolygonVertices = %s;' % data.readInt())
        writer.putln('settings.b2_maxProxies = %s;' % data.readInt())
        writer.putln('settings.b2_maxPairs = %s;' % data.readInt())
        writer.putln('settings.b2_linearSlop = %s;' % data.readFloat())
        writer.putln('settings.b2_angularSlop = %s;' % data.readFloat())
        writer.putln('settings.b2_toiSlop = %s;' % data.readFloat())
        writer.putln('settings.b2_maxTOIContactsPerIsland = %s;' %
                     data.readInt())
        writer.putln('settings.b2_maxTOIJointsPerIsland = %s;' % data.readInt())
        writer.putln('settings.b2_velocityThreshold = %s;' % data.readFloat())
        writer.putln('settings.b2_maxLinearCorrection = %s;' % data.readFloat())
        writer.putln('settings.b2_maxAngularCorrection = %s;' % data.readFloat())
        writer.putln('settings.b2_maxLinearVelocity = %s;' % data.readFloat())
        writer.putln('settings.b2_maxLinearVelocitySquared = %s;' %
                     data.readFloat())
        writer.putln('settings.b2_maxAngularVelocity = %s;' % data.readFloat())
        writer.putln('settings.b2_maxAngularVelocitySquared = %s;' %
                     data.readFloat())
        writer.putln('settings.b2_contactBaumgarte = %s;' % data.readFloat())
        writer.putln('settings.b2_timeToSleep = %s;' % data.readFloat())
        writer.putln('settings.b2_linearSleepTolerance = %s;' %
                     data.readFloat())
        writer.putln('settings.b2_angularSleepTolerance = %s;' %
                     data.readFloat())
        writer.putln('settings.b2_tableCapacity = %s;' % data.readInt())
        writer.putln('settings.b2_tableMask = %s;' % data.readInt())
        writer.putln('maxControllers = %s;' % data.readInt())
        writer.putln('initialize_box2d();')

class ObjectAction(ActionMethodWriter):
    custom = True

    def write(self, writer):
        box2d = self.converter.get_object(self.get_object())
        object_info = (self.parameters[0].loader.objectInfo,
                       self.parameters[0].loader.objectType)

        with self.converter.iterate_object(object_info, writer, 'selected',
                                           False):
            parameters = [self.converter.get_object(object_info)]
            for i in xrange(1, len(self.parameters)):
                parameters.append(self.convert_index(i))
            parameters = ', '.join(parameters)
            writer.putlnc('%s->%s(%s);', box2d, self.method, parameters)

class CreateBody(ObjectAction):
    method = 'create_body'

    def __init__(self, *arg, **kw):
        ObjectAction.__init__(self, *arg, **kw)
        self.parameters = self.parameters[:5]

class CreateShape(ObjectAction):
    method = 'create_shape'

class SetLinearDamping(ObjectAction):
    method = 'set_linear_damping'

class CreateMouseJoint(ObjectAction):
    method = 'create_mouse_joint'

class CreateBox(ObjectAction):
    method = 'create_box'

class RemoveBody(ObjectAction):
    method = 'remove_body'

class RemoveShape(ObjectAction):
    method = 'remove_shape'

actions = make_table(ActionMethodWriter, {
    1 : CreateBody,
    2 : CreateBox,
    3 : 'reset_world',
    11 : 'create_body',
    25 : RemoveBody,
    27 : CreateShape,
    32 : 'create_edge_chain',
    72 : RemoveShape,
    142 : CreateMouseJoint,
    144 : 'remove_joint',
    145 : 'set_joint_target',
    158 : 'create_distance_joint',
    205 : 'set_auto_update',
    328 : CreateShape,
    330 : SetLinearDamping,
    354 : 'remove_joint'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    2 : '.lastJoint'
})

def get_object():
    return Box2D