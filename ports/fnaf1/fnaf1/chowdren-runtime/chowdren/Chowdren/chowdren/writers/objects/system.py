from chowdren.writers.objects import ObjectWriter
from mmfparser.data.chunkloaders.objectinfo import (QUICKBACKDROP, BACKDROP,
    ACTIVE, TEXT, QUESTION, SCORE, LIVES, COUNTER, RTF, SUBAPPLICATION)
from mmfparser.data.chunkloaders.objects import (COUNTER_FRAMES,
    ANIMATION_NAMES, NUMBERS, HIDDEN, VERTICAL_BAR, HORIZONTAL_BAR,
    VERTICAL_GRADIENT, HORIZONTAL_GRADIENT, RECTANGLE_SHAPE, SOLID_FILL,
    GRADIENT_FILL, FINE_COLLISION, NONE_OBSTACLE, FINE_COLLISION,
    LADDER_OBSTACLE, ANIMATION, APPEARING, DISAPPEARING)
from chowdren.common import (get_animation_name, to_c, make_color,
                             get_method_name)

def get_closest_directions(direction, dir_dict):
    try:
        return dir_dict[direction]
    except KeyError:
        pass

    # (directionObject, distance)
    forward = None
    backward = None

    # get closest in back
    position = direction
    distance = 0
    while 1:
        position -= 1
        distance += 1
        if position < 0:
            position = 31
        if position in dir_dict:
            backward = (dir_dict[position], distance)
            break

    # get closest ahead
    position = direction
    distance = 0
    while 1:
        position = (position + 1) % 32
        distance += 1
        if position in dir_dict:
            forward = (dir_dict[position], distance)
            break

    # backward has priority
    if backward[1] == forward[1]:
        return None
    elif backward[1] > forward[1]:
        return forward[0]
    else:
        return backward[0]

class Active(ObjectWriter):
    class_name = 'Active'
    use_alterables = True
    update = True
    default_instance = 'default_active_instance'
    filename = 'active'
    destruct = False

    def write_init(self, writer):
        common = self.common
        animations = common.animations.loadedAnimations
        max_anim = max(animations)+1
        writer.putlnc('this->animations = &%s;', self.animations_name)
        writer.putlnc('if (!%s) {', self.initialized_name)
        writer.indent()
        writer.putlnc('%s = true;', self.initialized_name)
        scale_method = self.converter.config.get_scale_method(self) 
        for name, images in self.images:
            for image_index, image in enumerate(images):
                writer.putlnc('%s[%s] = %s;', name, image_index, image)
                if scale_method is None:
                    continue
                writer.putlnc('%s[%s]->set_filter(%s);', name, image_index,
                              scale_method)
        writer.end_brace()
        flags = common.newFlags

        fade = common.fadeOut
        if fade and fade.name == 'FADE':
            writer.putlnc('fade_duration = %s;', fade.duration / 1000.0)

        if flags['AutomaticRotation']:
            writer.putlnc('active_flags |= AUTO_ROTATE;')
        if self.get_transparent():
            writer.putlnc('active_flags |= TRANSPARENT;')
        writer.putln('animation = %s;' % get_animation_name(min(animations)))
        if APPEARING in animations:
            writer.putln('forced_animation = current_animation = APPEARING;')
        else:
            writer.putln('current_animation = animation;')
        if len(animations) == 1 and DISAPPEARING in animations:
            writer.putln('flags |= FADEOUT;')
            self.destruct = True

        writer.putlnc('initialize_active(%s);', flags['CollisionBox'])

    def has_updates(self):
        if not self.converter.config.use_update_filtering():
            return True
        if self.converter.config.use_deferred_collisions():
            return True
        animations = self.common.animations.loadedAnimations
        if len(animations) > 1:
            return True
        animation = animations.values()[0]
        if animation.getName() != 'Stopped':
            return True
        directions = animation.loadedDirections
        if len(directions) > 1:
            return True
        if len(directions.values()[0].frames) > 1:
            return True
        return False

    def get_transparent(self):
        if self.data.transparent:
            return True
        has_back = not self.common.newFlags['DoNotSaveBackground']
        animations = self.common.animations.loadedAnimations
        for animation in animations.values():
            for direction in animation.loadedDirections.values():
                for image in direction.frames:
                    bank_image = self.converter.game.images.itemDict[image]
                    has_alpha = bank_image.flags['Alpha']
                    if has_back and has_alpha:
                        return True
        if has_back:
            return False
        return True

    def write_pre(self, writer):
        self.animations = {}
        self.images = []
        get_image = self.converter.get_image
        animations = self.common.animations.loadedAnimations
        prefix = self.new_class_name.lower()
        for animation_index in sorted(animations):
            animation = animations[animation_index]
            anim_name = animation.getName()
            if anim_name == 'Appearing' and direction.repeat == 0:
                print 'Problematic appearing?', self.data.name
            directions = animation.loadedDirections
            animation_name = get_animation_name(animation.index)
            direction_map = {}
            anim_prefix = '%s_%s' % (prefix, animation_index)
            for direction_index in sorted(directions):
                direction = directions[direction_index]
                dir_prefix = '%s_%s' % (anim_prefix, direction_index)
                image_count = len(direction.frames)
                images = [get_image(image) for image in direction.frames]
                images_name = 'images_%s' % dir_prefix
                writer.putlnc('static Image* %s[%s];', images_name,
                              image_count)
                self.images.append((images_name, images))
                loop_count = direction.repeat
                if loop_count == 0:
                    loop_count = -1

                direction_name = 'direction_%s' % dir_prefix
                writer.putlnc('static Direction %s = {%s, %s, %s, %s, %s, %s, '
                              '%s};', direction_name, direction_index,
                              direction.minSpeed, direction.maxSpeed,
                              direction.backTo, loop_count, images_name,
                              image_count)
                direction_map[direction_index] = '&%s' % direction_name

            directions = []
            for i in xrange(32):
                new_dir = get_closest_directions(i, direction_map)
                if new_dir is None:
                    new_dir = 'NULL'
                directions.append(new_dir)

            directions = ', '.join(directions)
            anim_name = 'anim_%s' % anim_prefix
            writer.putlnc('static Animation %s = {%s};',
                          anim_name, directions)
            self.animations[animation_index] = '&' + anim_name

        self.animations_name = 'anim_%s' % prefix
        animation_names = []

        anims_array = 'anim_array_%s' % prefix

        for i in xrange(max(animations)+1):
            animation_names.append(self.animations.get(i, 'NULL'))

        writer.putlnc('static Animation * %s[%s] = {%s};',
                      anims_array, len(animation_names),
                      ', '.join(animation_names))
        writer.putlnc('static Animations %s = {%s, &%s[0]};',
                      self.animations_name, len(animation_names),
                      anims_array)
        self.initialized_name = '%s_initialized' % self.animations_name
        writer.putlnc('static bool %s;', self.initialized_name)

    def get_images(self):
        images = set()
        common = self.common
        animations = common.animations.loadedAnimations
        for animation in animations.values():
            directions = animation.loadedDirections
            for direction in directions.values():
                images.update(direction.frames)
        return images

    def has_autodestruct(self):
        return self.destruct

class Backdrop(ObjectWriter):
    class_name = 'Backdrop'
    filename = 'backdrop'

    def initialize(self):
        obstacle = self.common.getObstacleType()
        if obstacle not in ('None', 'Solid', 'Ladder'):
            print 'obstacle type', obstacle, 'not supported'
            raise NotImplementedError

    def write_init(self, writer):
        name_id = 'BACK_ID_' + get_method_name(self.data.name).upper()
        writer.putraw('#ifdef %s' % name_id)
        writer.putlnc('manager.frame->back_instances[%s].push_back(this);',
                      name_id)
        writer.putraw('#endif')

        image = self.converter.get_image(self.common.image)
        writer.putln('image = %s;' % image)
        if self.data.name.endswith('(DRC)'):
            writer.putraw('#if defined(CHOWDREN_IS_WIIU) || '
                          'defined(CHOWDREN_EMULATE_WIIU)')
            writer.putln('remote = CHOWDREN_REMOTE_TARGET;')
            writer.putraw('#endif')
        writer.putln('width = image->width;')
        writer.putln('height = image->height;')
        obstacle_type = self.common.obstacleType
        if obstacle_type == NONE_OBSTACLE:
            return
        if self.common.collisionMode == FINE_COLLISION:
            writer.putln('collision = new BackdropCollision(this, image);')
        else:
            writer.putln('collision = new InstanceBox(this);')
        if obstacle_type == LADDER_OBSTACLE:
            writer.putln('collision->flags |= LADDER_OBSTACLE;')

    def get_images(self):
        return [self.common.image]

class QuickBackdrop(ObjectWriter):
    class_name = 'QuickBackdrop'
    border = 0
    filename = 'quickbackdrop'

    def initialize(self):
        self.image = None
        obstacle = self.common.getObstacleType()
        if obstacle not in ('Solid', 'None', 'Ladder'):
            print 'obstacle type', obstacle, 'not supported'
            raise NotImplementedError
        shape = self.common.shape
        if shape.getShape() != 'Rectangle':
            print 'shape', shape.getShape(), 'not supported'
            raise NotImplementedError
        fill = shape.getFill()
        if fill not in ('Solid', 'Gradient', 'Motif'):
            print 'fill', shape.getFill(), 'not supported'
            raise NotImplementedError
        border = shape.borderColor
        color1 = shape.color1
        color2 = shape.color2
        has_color2 = color2 is not None
        border_size = shape.borderSize
        if border_size != 0 and (fill == 'None' or border != color1
                                 or (has_color2 and border != color2)):
            self.border = border_size
            self.border_color = border

    def write_init(self, writer):
        shape = self.common.shape
        color1 = shape.color1
        color2 = shape.color2
        fill = shape.getFill()

        if fill == 'Motif':
            try:
                color1 = self.converter.get_solid_image(shape.image)
                fill = 'Solid'
            except KeyError:
                pass

        writer.putln('width = %s;' % self.common.width)
        writer.putln('height = %s;' % self.common.height)
        if fill != 'Motif':
            writer.putln('color = %s;' % make_color(color1))
        if fill == 'Gradient':
            gradient = shape.getGradientType()
            if gradient == 'Horizontal':
                writer.putln('gradient_type = HORIZONTAL_GRADIENT;')
            else:
                writer.putln('gradient_type = VERTICAL_GRADIENT;')
            writer.putln('color2 = %s;' % make_color(color2))
        elif fill == 'Motif':
            self.image = shape.image
            writer.putlnc('image = %s;',
                          self.converter.get_image(shape.image))
        elif color2 is not None:
            raise NotImplementedError
        else:
            writer.putln('gradient_type = NONE_GRADIENT;')

        writer.putlnc('outline = %s;', self.border)
        if self.border:
            writer.putlnc('outline_color = %s;',
                          make_color(self.border_color))

        obstacle_type = self.common.obstacleType
        if obstacle_type == NONE_OBSTACLE:
            return
        writer.putln('collision = new InstanceBox(this);')
        if obstacle_type == LADDER_OBSTACLE:
            writer.putln('collision->flags |= LADDER_OBSTACLE;')

    def get_images(self):
        if self.image is None:
            return ()
        return (self.image,)

class Text(ObjectWriter):
    class_name = 'Text'
    use_alterables = True
    has_color = True
    filename = 'text'

    def initialize(self):
        pass

    def write_init(self, writer):
        text = self.common.text
        lines = [paragraph.value for paragraph in text.items]
        writer.putln('width = %s;' % text.width)
        writer.putln('height = %s;' % text.height)
        writer.putln('blend_color = %s;' % make_color(text.items[0].color))

        font = text.items[0].font
        font_info = self.converter.fonts[font]

        writer.putlnc('bold = %s;', font_info.isBold())
        writer.putlnc('italic = %s;', bool(font_info.italic))
        writer.putlnc('font_name = %r;', font_info.faceName)

        flags = []
        if font_info.isBold():
            flags.append('FTTextureFont::BOLD')
        flags = ' | '.join(flags)
        if not flags:
            flags = '0'

        writer.putlnc('font = get_font(%s, %s);', font_info.getSize(),
                      flags)

        paragraph = text.items[0]
        if paragraph.flags['HorizontalCenter']:
            horizontal = 'ALIGN_HCENTER'
        elif paragraph.flags['RightAligned']:
            horizontal = 'ALIGN_RIGHT'
        else:
            horizontal = 'ALIGN_LEFT'
        if paragraph.flags['VerticalCenter']:
            vertical = 'ALIGN_VCENTER'
        elif paragraph.flags['BottomAligned']:
            vertical = 'ALIGN_BOTTOM'
        else:
            vertical = 'ALIGN_TOP'
        writer.putln('alignment = %s | %s;' % (horizontal, vertical))
        for paragraph in text.items:
            writer.putln(to_c('add_line(%r);', paragraph.value))

    def is_background(self):
        return False

class RTFText(ObjectWriter):
    class_name = 'Text'
    filename = 'text'

    def initialize(self):
        pass

    def write_init(self, writer):
        text = self.common.rtf
        writer.putln(to_c('add_line("");',))
        writer.putln('width = %s;' % text.width)
        writer.putln('height = %s;' % text.height)
        writer.putln('blend_color = Color(0, 0, 0);')
        writer.putln('bold = false;')
        writer.putln('italic = false;')

        writer.putln('alignment = ALIGN_HCENTER | ALIGN_VCENTER;')

    def is_background(self):
        return False

class Counter(ObjectWriter):
    class_name = 'Counter'
    filename = 'counter'

    def write_init(self, writer):
        common = self.common
        counters = common.counters
        counter = common.counter
        if counters:
            writer.putln('width = %s;' % counters.width)
            writer.putln('height = %s;' % counters.height)
            if counters.integerDigits > 0:
                writer.putlnc('zero_pad = %s;', counters.integerDigits)
            display_type = counters.displayType
            if display_type == NUMBERS:
                writer.putln('type = IMAGE_COUNTER;')
                writer.putln('static Image * counter_images[14];')
                writer.putln('static bool initialized = false;')
                writer.putln('if (!initialized) {')
                writer.indent()
                writer.putln('initialized = true;')
                for char_index, char in enumerate(COUNTER_FRAMES):
                    writer.putlnc('counter_images[%s] = %s;', char_index,
                        self.converter.get_image(counters.frames[char_index]))
                writer.end_brace()
                writer.putln('images = (Image**)&counter_images;')
                writer.putln('image_count = 14;')
            elif display_type == HORIZONTAL_BAR:
                shape_object = counters.shape
                shape = shape_object.shape
                if shape != RECTANGLE_SHAPE:
                    print 'horizontal rectangle shape not implemented'
                    return
                count_right = counters.inverse
                if count_right:
                    print 'horizontal count direction not implemented'
                    return
                writer.putln('type = HORIZONTAL_LEFT_COUNTER;')
            elif display_type == VERTICAL_BAR:
                shape_object = counters.shape
                shape = shape_object.shape
                if shape != RECTANGLE_SHAPE:
                    print 'vertical rectangle shape not implemented'
                    return
                count_up = counters.inverse
                if not count_up:
                    print 'vertical count direction not implemented'
                    return
                writer.putln('type = VERTICAL_UP_COUNTER;')
            elif display_type == ANIMATION:
                writer.putln('type = ANIMATION_COUNTER;')
                size = len(counters.frames)
                writer.putlnc('static Image * counter_images[%s];', size)
                writer.putlnc('static bool initialized = false;')
                writer.putln('if (!initialized) {')
                writer.indent()
                writer.putln('initialized = true;')
                for index, image in enumerate(counters.frames):
                    image = self.converter.get_image(image)
                    writer.putlnc('counter_images[%s] = %s;', index, image)
                writer.end_brace()
                writer.putln('images = (Image**)&counter_images;')
                writer.putlnc('image_count = %s;', size)
            else:
                print 'type', counters.getDisplayType(), 'not implemented'
                return
                raise NotImplementedError

            if display_type in (VERTICAL_BAR, HORIZONTAL_BAR):
                fill_type = shape_object.fillType
                if fill_type == GRADIENT_FILL:
                    if shape_object.getGradientType() == 'Horizontal':
                        writer.putlnc('gradient_type = HORIZONTAL_GRADIENT;')
                    else:
                        writer.putlnc('gradient_type = VERTICAL_GRADIENT;')
                    writer.putlnc('color1 = %s;',
                                  make_color(shape_object.color1))
                    writer.putlnc('color2 = %s;',
                                  make_color(shape_object.color2))
                elif fill_type == SOLID_FILL:
                    writer.putlnc('gradient_type = NONE_GRADIENT;')
                    writer.putlnc('color1 = %s;',
                                  make_color(shape_object.color1))
                else:
                    raise NotImplementedError
        else:
            writer.putln('type = HIDDEN_COUNTER;')
            writer.putln('width = height = 0;')
        writer.putlnc('minimum = %s;', counter.minimum)
        writer.putlnc('maximum = %s;', counter.maximum)

        if self.is_global():
            self.global_name = self.get_global('Counter::SavedCounter')
            writer.putlnc('if (%s.init)', self.global_name)
            writer.indent()
            writer.putlnc('set(%s.value);', self.global_name)
            writer.dedent()
            writer.putln('else')
            writer.indent()
            writer.putlnc('set(%s);', counter.initial)
            writer.dedent()
        else:
            writer.putlnc('set(%s);', counter.initial)

    def has_dtor(self):
        return self.is_global()

    def write_dtor(self, writer):
        if not self.is_global():
            return
        writer.putlnc('%s.init = true;', self.global_name)
        writer.putlnc('%s.value = value;', self.global_name)

    def is_static_background(self):
        return False

    def is_background(self):
        # background counters really only start in the background,
        # nothing else
        return False

    def get_images(self):
        common = self.common
        counters = common.counters
        counter = common.counter
        if counters:
            display_type = counters.displayType
            if display_type in (NUMBERS, ANIMATION):
                return counters.frames
        return []

class Lives(ObjectWriter):
    class_name = 'Lives'
    update = True
    filename = 'lives'

    def write_init(self, writer):
        common = self.common
        counters = common.counters
        counter = common.counter
        if not counters:
            raise NotImplementedError()
        writer.putln('width = %s;' % counters.width)
        writer.putln('height = %s;' % counters.height)
        display_type = counters.displayType
        if display_type != ANIMATION:
            raise NotImplementedError()
        image = counters.frames[0]
        writer.putln('image = %s;' % self.converter.get_image(image))

    def get_images(self):
        return [self.common.counters.frames[0]]

class SubApplication(ObjectWriter):
    class_name = 'SubApplication'
    update = True
    filename = 'subapp'
    defines = ['CHOWDREN_USE_SUBAPP']

    def has_sleep(self):
        return False

    def write_init(self, writer):
        data = self.common.subApplication

        writer.putlnc('width = %s;', data.width)
        writer.putlnc('height = %s;', data.height)

        flags = data.options
        if flags['ShareGlobals']:
            writer.putlnc('subapp_frame.global_values = '
                          'manager.values;')
            writer.putlnc('subapp_frame.global_strings = '
                          'manager.strings;')

        if not flags['ShareLives']:
            print 'Non-shared live not implemented'

        if not flags['ShareScores']:
            print 'Non-shared score not implemented'

        filename = data.name.split('\\')[-1]
        if flags['Internal']:
            writer.putlnc('frame_offset = %s;',
                          self.converter.game.frame_offset)
            start_frame = data.startFrame
        else:
            for game in self.converter.games:
                if game.filename.endswith(filename):
                    filename = game.filename
                    break
            else:
                raise NotImplementedError()

            frame_offset = self.converter.frame_map[(filename, 0)]
            writer.putlnc('frame_offset = %s;', frame_offset)
            start_frame = 0

        writer.putlnc('restart(%s);', start_frame)


system_objects = {
    TEXT : Text,
    ACTIVE : Active,
    BACKDROP : Backdrop,
    QUICKBACKDROP : QuickBackdrop,
    COUNTER : Counter,
    RTF : RTFText,
    LIVES : Lives,
    SUBAPPLICATION : SubApplication,
}