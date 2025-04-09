# Rotate the player and change its jersey color
# (used during batch rendering)

import bpy
import math
#import os
#basename = os.path.splitext(os.path.basename(bpy.data.filepath))[0]

rotadd = XX_DEGREE_XX * math.pi / 180

armature = bpy.data.objects["Armature"]
armature.rotation_euler[2] = rotadd

gloves = bpy.data.objects["Gloves"]
gloves.layers[0] = False
gloves.layers[XX_LAYER_XX] = True

material = bpy.data.materials["Jersey"]
material.diffuse_color = [ XX_COLOR_XX ]

sceneKey = bpy.data.scenes.keys()[0]
bpy.data.scenes[sceneKey].render.alpha_mode = 'TRANSPARENT'
bpy.data.scenes[sceneKey].render.image_settings.file_format = 'PNG'
bpy.data.scenes[sceneKey].render.image_settings.quality = 100
#bpy.data.scenes[sceneKey].render.filepath = basename
#bpy.ops.render.render(write_still = True)

bpy.ops.wm.save_as_mainfile(filepath = "playerXX_DEGREE_XX.blend")

bpy.ops.wm.quit_blender()
