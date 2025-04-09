-- extending the object class
local bunny = require 'res.object.game.bunny'
local object = bunny:extend()

object.COLLISION_OFFSET = vector(-4, -4)
object.COLLISION_OFFSET_FLIPPED = vector(-2, -4)
object.COLLISION_SIZE = vector(6, 4)
object.COLLISION_PAUSED_SIZE = vector(8, 4)
object.COLLISION_PAUSED_OFFSET = vector(-1, 0)

object.GRAVITY = 380
object.SPEED = 45
object.JUMP_HEIGHT = 12
object.DOUBLE_JUMP = true
object.GLIDE = true
object.JUMP_BUFFER_TIME = 0.07 --in seconds
object.COYOTE_TIME = 0.07 --in seconds
object.FALL_THROUGH_BUFFER = 0.07 -- in seconds
object.MAX_JUMPS = 1
object.MAX_GLIDE_FALL_SPEED = 24
object.GLIDE_GRAVITY = 350

object.ORIGIN = vector(7, 10)
object.character = 'duckling'
object.isBunny = false
object.isDuckling = true

return object