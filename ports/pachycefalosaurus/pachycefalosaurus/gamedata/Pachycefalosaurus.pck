GDPC                                                                            (   `   res://.import/170145__timgormly__8-bit-explosion1.wav-eb002f2a9995c8f090b469ddc489ef17.sample   @m      m~      7�s����2sД�g�d   res://.import/333785__projectsu012__8-bit-failure-sound.wav-433023f0283205c449c5c14c7de07af8.sample ��      a-     ���c�K ���9�\   res://.import/399095__plasterbrain__8bit-jump.wav-7951e9d348e798321dd2c48de59db76a.sample   p     �'      :���-�l�m2��T�h   res://.import/404743__owlstorm__retro-video-game-sfx-fail.wav-ae66269e972d5e46c4213aea1b2d91a0.sample    G     ��      ��[����O���q�@   res://.import/Cloud.png-33402ad80cb9ad5897a104ee31470266.stex   �      �       j$f㓦��0�T�㮿@@   res://.import/Floor.png-68aa3acdbf75692cf341d06366c0335f.stex   P            ��|��%Y�uwP��lJ@   res://.import/Obstacle.png-d8dffa3f046227a4226d36d65e8f82f0.stex      �       ��	W';� ��H~��{D   res://.import/Pachi-Sheet.png-62581ddcc7ce1c2db909e0072682da86.stex �      �       ��P��e�V��#��>D   res://.import/Ptero-Sheet.png-1f7e6dd2e4c232f8ea67137db9736a42.stex p#      H      o/`Y3!�jأR"z<   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex�$     �      &�y���ڞu;>��.p   res://Cloud.gd.remapp.             �n�	�!zd�:$L�)   res://Cloud.gdc �      3      Ϻ8��=�)�rk��3&�   res://Cloud.tscn�      0      3�w+f�,��O���u   res://Floor.gd.remap�.             �CFp�T�"�IΝ4�U   res://Floor.gdc        .      k�KN�����q�%   res://Floor.tscn0      �      �Ỽ���8��o-    res://Graphics/Cloud.png.import �      �      F�?������!    res://Graphics/Floor.png.import `      �      �F� 	�0! ,ZD	�$   res://Graphics/Obstacle.png.import  �      �      0U���G�U�H��x�(   res://Graphics/Pachi-Sheet.png.import   �       �      9R�ܨ�R��:�$(   res://Graphics/Ptero-Sheet.png.import   �$      �      ���evH�̓�ag.=�   res://Main.gd.remap �.            �(@Er�#��K�F�[   res://Main.gdc  �'            %�����}s��z �   res://Main.tscn �6            �j}�\��Oڍŉ��I$   res://Obstacles/Obstacle.gd.remap   �.     -       �c��y�l�)c�b�;   res://Obstacles/Obstacle.gdc�M      �      ��Ϯ���-j�G�\��s    res://Obstacles/Obstacle.tscn   `S      f      Ib��;����k![�   res://Player.gd.remap    /     !       ��0�F �qq��dX��   res://Player.gdc�^      #      ��"�8��<�Z�s��   res://Player.tscn    e      9      ��f�)�($����%�<   res://Sounds/170145__timgormly__8-bit-explosion1.wav.import ��            �Do��W\l�+գ4�D   res://Sounds/333785__projectsu012__8-bit-failure-sound.wav.import   @     '      ����_�kD�>�(���8   res://Sounds/399095__plasterbrain__8bit-jump.wav.import E     	      1B�n��L	��qD   res://Sounds/404743__owlstorm__retro-video-game-sfx-fail.wav.import ��     -      SR��-cܟ���H��c   res://default_env.tres  ��     �       um�`�N��<*ỳ�84   res://font/codeman38_press-start-2p/PressStart2P.ttf��     0B     tIm���z���0��vh   res://icon.png  0/     �      G1?��z�c��vN��   res://icon.png.import   �*     �      ��fe��6�B��^ U�   res://press_start_theme.tres`-     
      *PR� *,㲤#��   res://project.binary <     �      ���$#o������hGDSC         
   &      �����Ӷ�   ����������ζ   �������Ŷ���   ����׶��   �������ض���   ζ��   ���������Ӷ�                                            	                            	   $   
   3YY;�  YY0�  P�  QV�  �  T�  �  �  �  �  �  &�  �  V�  �  PQY`             [gd_scene load_steps=3 format=2]

[ext_resource path="res://Cloud.gd" type="Script" id=1]
[ext_resource path="res://Graphics/Cloud.png" type="Texture" id=2]

[node name="Cloud" type="Sprite"]
scale = Vector2( 4, 4 )
z_index = -2
z_as_relative = false
texture = ExtResource( 2 )
script = ExtResource( 1 )
GDSC            '      ���������τ򶶶�   ����������������Ķ��   �����϶�(   ���������������������Ą��������������Ҷ�   ���������Ӷ�                                                           	   !   
   %      3YY8P�  Q;�  YY0�  PQV�  -YY0�  PQV�  &�  V�  �  PQY`  [gd_scene load_steps=4 format=2]

[ext_resource path="res://Floor.gd" type="Script" id=1]
[ext_resource path="res://Graphics/Floor.png" type="Texture" id=2]

[sub_resource type="RectangleShape2D" id=1]
extents = Vector2( 1024, 10 )

[node name="Floor" type="StaticBody2D"]
position = Vector2( 1024, 42 )
collision_mask = 0
script = ExtResource( 1 )

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource( 1 )

[node name="Polygon2D" type="Polygon2D" parent="."]
visible = false
color = Color( 0.32549, 0.32549, 0.32549, 1 )
polygon = PoolVector2Array( 1024, -10, 1024, 10, -1024, 10, -1024, -10 )

[node name="VisibilityNotifier2D" type="VisibilityNotifier2D" parent="."]
position = Vector2( 1010, 0 )

[node name="Sprite" type="Sprite" parent="."]
scale = Vector2( 4, 4 )
texture = ExtResource( 2 )

[connection signal="screen_exited" from="VisibilityNotifier2D" to="." method="_on_VisibilityNotifier2D_screen_exited"]
        GDST$   $             �   WEBPRIFF�   WEBPVP8Lt   /#�0ڣ=��pW��(R�$�����!��~��csD�d/T`U؉ȡF���w��(�|�`���Oͱ�N�̂-7�Ҩ�rƽV̿�J����oډT��        [remap]

importer="texture"
type="StreamTexture"
path="res://.import/Cloud.png-33402ad80cb9ad5897a104ee31470266.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://Graphics/Cloud.png"
dest_files=[ "res://.import/Cloud.png-33402ad80cb9ad5897a104ee31470266.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
 GDST                �  WEBPRIFF�  WEBPVP8L�  /��0S35S�pɭm5���B��v�Hž�00/M>T�	 ����%��&�j��#e�KJ=�4�*�&M�h�5)7k�
]NU�M�*(3*JtA�2�,�*�gF��D����L������I�P%)�R�M�� �RhJ�%�J��Z����]�Ee=U�t�BK��X�Rb=y4I�o:W�Ԧi�6+,��ƴ������!9�����șo�w�g|c|k�$/5��:��2-{yؼ=L���؞޶���aZ91��oo�1u�C�`��NsXɳ�b��rh��N}g�_�Y\23�b759�wX�!� ���R'����g��li���� W�i�k3.�"��Մo�i��<rl6R6{b�̜�.�B���_�M"�� ��a3�`f��,�,L#�vo|��a�`�̟=�f��.,l>3�,	f�![?����ʅ�Ņ�Ήk���N\9	 [remap]

importer="texture"
type="StreamTexture"
path="res://.import/Floor.png-68aa3acdbf75692cf341d06366c0335f.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://Graphics/Floor.png"
dest_files=[ "res://.import/Floor.png-68aa3acdbf75692cf341d06366c0335f.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
 GDST$   $             �   WEBPRIFF�   WEBPVP8L�   /#� H�_a�`2��zł�@�W���V�*�m�9)Hx~���}%���4j�8t�$"�����J2:/[��(xv�=LY����u
�.��wt�˰lѳK�aʃ/>���_���i+���5 �vR��� h��QG��e���   [remap]

importer="texture"
type="StreamTexture"
path="res://.import/Obstacle.png-d8dffa3f046227a4226d36d65e8f82f0.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://Graphics/Obstacle.png"
dest_files=[ "res://.import/Obstacle.png-d8dffa3f046227a4226d36d65e8f82f0.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
        GDST�                �   WEBPRIFF�   WEBPVP8L�   /�@ H�_a�`2��zł�@�W���Vຶ�D	E������'t����~��$D�_@Pp�0�G-�� !O� �*�>kԫVY�i ,��W��<E���� �&du�.�i 2 �u�� �\�8�*��= i0Ts��D^~!�H�1 �0�t��Ċ��F 3 Ƒ W�JiH� �C���'�r       [remap]

importer="texture"
type="StreamTexture"
path="res://.import/Pachi-Sheet.png-62581ddcc7ce1c2db909e0072682da86.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://Graphics/Pachi-Sheet.png"
dest_files=[ "res://.import/Pachi-Sheet.png-62581ddcc7ce1c2db909e0072682da86.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
               GDSTl   $             ,  WEBPRIFF   WEBPVP8L  /k� H�_a�`2��zł�@�W���V ����DJ���`�h^MJpgD5�m��� ���ܶ��������	Xp�� #' T���8@����<�P �/�&��%
�_�
 �%�^v�OC��s�U _��K� ˿ ���]8�S�*�V���`=���z��>cc�`��e?�`�,2˄;�3�_F`Oz� ��3���k�F
  @�b?:��R���& H��!�Jt���P���P�-��<         [remap]

importer="texture"
type="StreamTexture"
path="res://.import/Ptero-Sheet.png-1f7e6dd2e4c232f8ea67137db9736a42.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://Graphics/Ptero-Sheet.png"
dest_files=[ "res://.import/Ptero-Sheet.png-1f7e6dd2e4c232f8ea67137db9736a42.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
               GDSC   >      q   �     ���ӄ�   ���������Ѷ�   �ڶ�   �Զ�   �ڶ�   ��Ѷ   ��������������������Ķ��   ����   �������������������ض���   ���������Ӷ�   ����Ӷ��   ����������������Ķ��   �����϶�   �������������Ӷ�   �������Ӷ���   �����Ҷ�   �������Ŷ���   ����׶��   �����ׄ򶶶�   �������ض���   ζ��   �����Ķ�   ��������������Ķ   ���   �����Ŷ�   ��������Ӷ��   ���¶���   ����Ӷ��   ��������Ķ��   �������Ӷ���   ��������Ҷ��   �����¶�   ����������Ӷ   �����������Ӷ���   ϶��   ������¶   ��������������ٶ   ����������Ҷ   ��������Ҷ��   ��������������Ķ    �����������������������������¶�   �������������Ӷ�   �����������������Ķ�   ��������Ӷ��   ����¶��   �����������������������¶���   ���ƶ���   ��������Ҷ��   ����������   �����������Ķ���   ���������������������¶�   ������¶   ������¶   ������Ӷ   ����������ڶ   �������������Ҷ�   ����������Ҷ   ���϶���   ����������������������Ҷ   ���ö���   ���������Ķ�   ������������������������Ҷ��      res://Floor.tscn      res://Obstacles/Obstacle.tscn         res://Cloud.tscn                                     HIGH SCORE:       SCORE:     �           T            
   restarting        on_Main_restarting           $      �                 
     �������?                                                            	   )   
   *      /      4      9      :      ;      @      A      G      M      Q      Y      Z      a      o      p      }      �      �      �      �      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (   �   )   �   *   �   +   �   ,     -     .     /     0   &  1   ,  2   2  3   3  4   9  5   E  6   M  7   V  8   ^  9   i  :   j  ;   p  <   �  =   �  >   �  ?   �  @   �  A   �  B   �  C   �  D   �  E   �  F   �  G   �  H   �  I   �  J   �  K   �  L   �  M   �  N   �  O   �  P   �  Q   �  R     S     T   
  U     V     W     X   (  Y   ,  Z   8  [   <  \   C  ]   J  ^   Q  _   R  `   S  a   T  b   Z  c   c  d   j  e   q  f   x  g   y  h     i   �  j   �  k   �  l   �  m   �  n   �  o   �  p   �  q   3YYB�  YY;�  ?PQY;�  ?P�  QY;�  ?P�  QYY;�  �  T�  PQYY;�  �  Y;�	  �  Y;�
  �  YYY;�  �  YY0�  PQV�  �  T�%  PQ�  �  PQ�  �  PQT�  �  YY0�  P�  QV�  W�  T�  T�  W�  T�  T�  �  �  &W�  T�  T�  �  �  V�  �  PQ�  �  �  �  �
  W�  T�  T�  �  �  �
  �  P�
  Q�  &�
  �	  V�  �	  �
  �  W�  �  �  T�  �  �>  P�	  Q�  W�  �  �  T�  �	  �>  P�
  QYY0�  PQV�  ;�  �  T�  PQ�  �  P�  Q�  �  T�  T�  �  �
  YY0�  PQV�  ;�  �  T�   P�  R�  Q�  �  �  �  ;�!  �  T�  PQ�  �  P�!  Q�  �!  T�  T�  W�  T�  T�  �  �  �!  T�  T�"  �  �  �#  P�  R�!  R�  Q�  &�  	�  V�  �!  T�$  PQYY0�%  PQV�  ;�  �  T�   P�  R�  Q�  �  �  �  �  �  ;�&  �  T�  PQ�  W�'  T�  P�&  Q�  �&  T�  �  P�  R�  QYY0�(  PQV�  ;�)  �  T�   P�  �  R�  �  Q�  �)  �  P�)  Q�  �)  �)  �  �  W�*  T�+  �)  �  W�*  T�,  PQ�  �  PQYY0�-  PQV�  W�*  T�.  PQ�  W�  T�/  W�  T�0  �  �  �  &W�  T�/  W�  T�0  �  V�  �  �  �  �  &W�  T�/  W�  T�0  	�  V�  W�1  T�,  PQ�  W�*  T�+  �  �  W�*  T�,  PQYY0�2  PQV�  �%  PQYY0�3  PQV�  �
  �  �  �  �  �  W�  �4  T�5  �  �  �6  P�  Q�  �  T�%  PQ�  W�  T�/  W�  T�0  �  �  �  �  W�  T�  �  P�  R�  Q�  �  PQ�  W�*  T�+  �  �  W�*  T�,  PQ�  W�1  T�,  PQ�  �  YY0�7  PQV�  W�  �4  T�5  �  �  W�8  T�9  PQ�  W�*  T�.  PQ�  W�1  T�.  PQYY0�:  PQV�  �  PQT�  �  �  W�  �;  T�5  �  �  W�  �  T�5  �  �  �%  PQ�  W�'  �<  T�,  PQYY0�=  PQV�  �3  PQY` [gd_scene load_steps=13 format=2]

[ext_resource path="res://Floor.tscn" type="PackedScene" id=1]
[ext_resource path="res://Player.tscn" type="PackedScene" id=2]
[ext_resource path="res://Main.gd" type="Script" id=3]
[ext_resource path="res://press_start_theme.tres" type="Theme" id=4]
[ext_resource path="res://font/codeman38_press-start-2p/PressStart2P.ttf" type="DynamicFontData" id=5]
[ext_resource path="res://Sounds/333785__projectsu012__8-bit-failure-sound.wav" type="AudioStream" id=6]

[sub_resource type="DynamicFont" id=5]
size = 42
extra_spacing_bottom = 20
font_data = ExtResource( 5 )

[sub_resource type="DynamicFont" id=6]
size = 35
extra_spacing_bottom = 20
font_data = ExtResource( 5 )

[sub_resource type="InputEventAction" id=1]
action = "ui_accept"
pressed = true

[sub_resource type="ShortCut" id=2]
shortcut = SubResource( 1 )

[sub_resource type="InputEventAction" id=3]
action = "ui_accept"
pressed = true

[sub_resource type="ShortCut" id=4]
shortcut = SubResource( 3 )

[node name="Main" type="Node2D"]
script = ExtResource( 3 )

[node name="HUD" type="CanvasLayer" parent="."]
pause_mode = 2

[node name="Scores" type="Control" parent="HUD"]
margin_right = 1024.0
margin_bottom = 40.0

[node name="HighScore" type="Label" parent="HUD/Scores"]
anchor_left = 1.0
anchor_right = 1.0
margin_left = -270.0
margin_top = 10.0
margin_bottom = 14.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
text = "HIGH SCORE: "

[node name="Score" type="Label" parent="HUD/Scores"]
anchor_left = 1.0
anchor_right = 1.0
margin_left = -190.0
margin_top = 30.0
margin_bottom = 14.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
text = "SCORE: "

[node name="Menu" type="Control" parent="HUD"]
margin_right = 1024.0
margin_bottom = 600.0

[node name="CenterContainer" type="CenterContainer" parent="HUD/Menu"]
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
margin_left = -575.0
margin_top = -150.0
margin_right = 575.0
margin_bottom = 150.0

[node name="VBoxContainer" type="VBoxContainer" parent="HUD/Menu/CenterContainer"]
margin_left = 92.0
margin_top = 76.0
margin_right = 1058.0
margin_bottom = 223.0

[node name="Title" type="Label" parent="HUD/Menu/CenterContainer/VBoxContainer"]
margin_right = 966.0
margin_bottom = 62.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
custom_fonts/font = SubResource( 5 )
text = "PACHYCEPHALOSAURUS GAME"
align = 1

[node name="Instructions" type="Label" parent="HUD/Menu/CenterContainer/VBoxContainer"]
margin_top = 66.0
margin_right = 966.0
margin_bottom = 121.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
custom_fonts/font = SubResource( 6 )
text = "HIT. EVERYTHING."
align = 1

[node name="StartButton" type="Button" parent="HUD/Menu/CenterContainer/VBoxContainer"]
margin_top = 125.0
margin_right = 966.0
margin_bottom = 147.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
custom_colors/font_color_hover = Color( 0.854902, 0.854902, 0.854902, 1 )
custom_colors/font_color_pressed = Color( 0.854902, 0.854902, 0.854902, 1 )
shortcut = SubResource( 2 )
text = "PLAY"
flat = true

[node name="Credits" type="Label" parent="HUD/Menu"]
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
margin_left = -256.0
margin_top = -26.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
text = "Game by LudosGD!"

[node name="Restart" type="Control" parent="HUD"]
visible = false
margin_right = 1024.0
margin_bottom = 600.0

[node name="RestartButton" type="Button" parent="HUD/Restart"]
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
margin_left = -78.0
margin_top = -11.0
margin_right = 78.0
margin_bottom = 11.0
theme = ExtResource( 4 )
custom_colors/font_color = Color( 0.32549, 0.32549, 0.32549, 1 )
custom_colors/font_color_hover = Color( 0.854902, 0.854902, 0.854902, 1 )
custom_colors/font_color_pressed = Color( 0.854902, 0.854902, 0.854902, 1 )
shortcut = SubResource( 4 )
text = "Try Again"
flat = true

[node name="BackgroundLayer" type="CanvasLayer" parent="."]
layer = -1

[node name="CloudTimer" type="Timer" parent="BackgroundLayer"]
wait_time = 7.0

[node name="Floor" parent="." instance=ExtResource( 1 )]
is_starting_floor = true

[node name="VisibilityNotifier2D" parent="Floor" index="2"]
visible = false

[node name="FloorBehind" parent="." instance=ExtResource( 1 )]
position = Vector2( -1024, 42 )
is_starting_floor = true

[node name="VisibilityNotifier2D" parent="FloorBehind" index="2"]
visible = false

[node name="Player" parent="." instance=ExtResource( 2 )]
z_index = 2

[node name="Camera2D" type="Camera2D" parent="."]
offset = Vector2( 400, -200 )
current = true

[node name="ObstacleSpawnTimer" type="Timer" parent="."]
one_shot = true
autostart = true

[node name="SpeedUpTimer" type="Timer" parent="."]
wait_time = 5.0
one_shot = true
autostart = true

[node name="DefeatSound" type="AudioStreamPlayer" parent="."]
pause_mode = 2
stream = ExtResource( 6 )

[connection signal="restarting" from="." to="Player" method="restart"]
[connection signal="pressed" from="HUD/Menu/CenterContainer/VBoxContainer/StartButton" to="." method="_on_StartButton_pressed"]
[connection signal="pressed" from="HUD/Restart/RestartButton" to="." method="_on_RestartButton_pressed"]
[connection signal="timeout" from="BackgroundLayer/CloudTimer" to="." method="_on_CloudTimer_timeout"]
[connection signal="player_dead" from="Player" to="." method="on_player_dead"]
[connection signal="timeout" from="ObstacleSpawnTimer" to="." method="_on_ObstacleSpawnTimer_timeout"]
[connection signal="timeout" from="SpeedUpTimer" to="." method="_on_SpeedUpTimer_timeout"]

[editable path="Floor"]
[editable path="FloorBehind"]
GDSC             �      ���ׄ�   ��Ѷ   ��������������������Ķ��   ����   �����϶�   ��������������ٶ   �������������Ӷ�   ���϶���   ��������������ض   �������Ҷ���   �������������ض�   ������������������������Ҷ��   ���϶���   �����������Ҷ���   ��������ض��   ���������Ҷ�   ����������Ҷ   ��������������Ķ   ���������Ķ�   ����������Ӷ   ����ض��   �������������������϶���   �������ض���   ζ��   �����������䶶��   �������ⶶ��   ����¶��   ������������������������Ҷ��   �����¶�   ��϶   ���������Ӷ�   �����������������Ѷ�      ptero                      disabled      ptero_defeat      rotate                     position   d     �        ?     �>                                                     	   (   
   /      6      7      >      H      R      [      c      j      m      t      ~      �      �      �      �      �      �      �      �      �      3YY;�  �  T�  PQYY0�  PQV�  �  T�%  PQYY0�  PQV�  W�  T�  PQ�  W�  T�	  �  �  W�
  T�	  �  YY0�  P�  QV�  W�  T�  P�  R�  Q�  W�
  T�  P�  R�  Q�  &W�  T�  V�  W�  T�  P�  Q�  W�  T�  PQ�  (V�  W�  T�  PQ�  W�  �  T�  P�  Q�  ;�  �  T�  P�  R�  Q�  W�  T�  PR�  R�  R�  P�  T�  �	  �  R�
  QR�  �  �  R�  T�  R�  T�  Q�  W�  T�  PQYY0�  P�  R�  QV�  �  PQYY0�  PQV�  �  PQY`         [gd_scene load_steps=14 format=2]

[ext_resource path="res://Obstacles/Obstacle.gd" type="Script" id=1]
[ext_resource path="res://Graphics/Obstacle.png" type="Texture" id=2]
[ext_resource path="res://Graphics/Ptero-Sheet.png" type="Texture" id=3]
[ext_resource path="res://Sounds/404743__owlstorm__retro-video-game-sfx-fail.wav" type="AudioStream" id=4]
[ext_resource path="res://Sounds/170145__timgormly__8-bit-explosion1.wav" type="AudioStream" id=5]

[sub_resource type="RectangleShape2D" id=1]
extents = Vector2( 18, 72 )

[sub_resource type="RectangleShape2D" id=7]
extents = Vector2( 36, 36 )

[sub_resource type="AtlasTexture" id=2]
atlas = ExtResource( 2 )
region = Rect2( 0, 0, 36, 36 )

[sub_resource type="AtlasTexture" id=4]
atlas = ExtResource( 3 )
region = Rect2( 0, 0, 36, 36 )

[sub_resource type="AtlasTexture" id=5]
atlas = ExtResource( 3 )
region = Rect2( 36, 0, 36, 36 )

[sub_resource type="AtlasTexture" id=6]
atlas = ExtResource( 3 )
region = Rect2( 72, 0, 36, 36 )

[sub_resource type="SpriteFrames" id=3]
animations = [ {
"frames": [ SubResource( 2 ) ],
"loop": true,
"name": "cactus",
"speed": 5.0
}, {
"frames": [ SubResource( 4 ), SubResource( 5 ) ],
"loop": true,
"name": "ptero",
"speed": 2.0
}, {
"frames": [ SubResource( 6 ) ],
"loop": true,
"name": "ptero_defeat",
"speed": 5.0
} ]

[sub_resource type="Animation" id=8]
resource_name = "rotate"
length = 0.8
loop = true
tracks/0/type = "value"
tracks/0/path = NodePath(".:rotation_degrees")
tracks/0/interp = 1
tracks/0/loop_wrap = true
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/keys = {
"times": PoolRealArray( 0, 0.2, 0.4, 0.6, 0.8 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ 0.0, 90.0, 180.0, 270.0, 360.0 ]
}

[node name="Obstacle" type="Area2D"]
position = Vector2( 0, -36 )
collision_layer = 2
collision_mask = 6
script = ExtResource( 1 )

[node name="CactusCollision" type="CollisionShape2D" parent="."]
shape = SubResource( 1 )

[node name="PteroCollision" type="CollisionShape2D" parent="."]
shape = SubResource( 7 )
disabled = true

[node name="Polygon2D" type="Polygon2D" parent="."]
visible = false
color = Color( 0.32549, 0.32549, 0.32549, 1 )
polygon = PoolVector2Array( 16, -32, 16, 32, -16, 32, -16, -32 )

[node name="AnimatedSprite" type="AnimatedSprite" parent="."]
scale = Vector2( 4, 4 )
frames = SubResource( 3 )
animation = "cactus"
playing = true

[node name="AnimationPlayer" type="AnimationPlayer" parent="AnimatedSprite"]
anims/rotate = SubResource( 8 )

[node name="Tween" type="Tween" parent="."]

[node name="CactusSound" type="AudioStreamPlayer2D" parent="."]
stream = ExtResource( 5 )

[node name="PteroSound" type="AudioStreamPlayer2D" parent="."]
stream = ExtResource( 4 )

[connection signal="body_entered" from="." to="." method="_on_Obstacle_body_entered"]
[connection signal="tween_completed" from="Tween" to="." method="_on_Tween_tween_completed"]
          GDSC         5   �      ������������τ�   ����������   ����������Ҷ   ��������Ҷ��   ���������Ҷ�   ������϶   �����������������Ķ�   ������Ҷ   �������϶���   �����϶�   ���������������Ŷ���   ����׶��   �������¶���   ζ��   ����������Ķ   �������������Ӷ�   ���϶���   ����¶��   ����������������Ҷ��   ϶��   ��������Ҷ��   �������������Ӷ�(   �����������������������������������Ҷ���   ���׶���   ����������ڶ   ������¶   ,           �                     run       jump      go_down                          defeat        player_dead                          	                           	      
   "      #      (      )      0      1      2      8      :      ;      B      G      L      M      T      Z      `      h      u      {      �      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (   �   )   �   *   �   +   �   ,   �   -   �   .   �   /   �   0   �   1   �   2   �   3   �   4   �   5   3YY:�  YYB�  YY;�  �  Y;�  �  Y;�  �  Y;�  �  YY;�  �  YY;�  �  PQYYY0�	  PQV�  -YY0�
  P�  QV�  &�  V�  �  P�  QYY0�  P�  QV�  �  T�  �  �  &�  PQV�  W�  T�  P�  Q�  &�  T�  P�  Q�  PQV�  �  T�  �  �  W�  T�  P�  Q�  W�  T�  PQ�  '�  PQV�  &�  T�  P�  QV�  �  T�  �  �  �  �  (V�  �  T�  �  �  YY�  �  �  P�  R�  P�  R�	  QQYY0�  P�  QV�  �  �
  �  W�  T�  P�  Q�  �  T�  �  �  �  P�  Q�  �  YY0�  PQV�  W�  T�  P�  Q�  �  �  Y`             [gd_scene load_steps=11 format=2]

[ext_resource path="res://Player.gd" type="Script" id=1]
[ext_resource path="res://Graphics/Pachi-Sheet.png" type="Texture" id=2]
[ext_resource path="res://Sounds/399095__plasterbrain__8bit-jump.wav" type="AudioStream" id=3]

[sub_resource type="RectangleShape2D" id=1]
extents = Vector2( 58, 30 )

[sub_resource type="RectangleShape2D" id=2]
extents = Vector2( 10, 600 )

[sub_resource type="AtlasTexture" id=3]
atlas = ExtResource( 2 )
region = Rect2( 108, 0, 36, 18 )

[sub_resource type="AtlasTexture" id=4]
atlas = ExtResource( 2 )
region = Rect2( 72, 0, 36, 18 )

[sub_resource type="AtlasTexture" id=5]
atlas = ExtResource( 2 )
region = Rect2( 0, 0, 36, 18 )

[sub_resource type="AtlasTexture" id=6]
atlas = ExtResource( 2 )
region = Rect2( 36, 0, 36, 18 )

[sub_resource type="SpriteFrames" id=7]
animations = [ {
"frames": [ SubResource( 3 ) ],
"loop": true,
"name": "defeat",
"speed": 5.0
}, {
"frames": [ SubResource( 4 ) ],
"loop": true,
"name": "jump",
"speed": 5.0
}, {
"frames": [ SubResource( 5 ), SubResource( 6 ) ],
"loop": true,
"name": "run",
"speed": 5.0
} ]

[node name="Player" type="KinematicBody2D"]
collision_layer = 3
script = ExtResource( 1 )

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2( 0, 2 )
shape = SubResource( 1 )

[node name="Polygon2D" type="Polygon2D" parent="."]
visible = false
color = Color( 0.32549, 0.32549, 0.32549, 1 )
polygon = PoolVector2Array( 16, -16, 16, 16, -16, 16, -16, -16 )

[node name="AvoidedObstacleArea" type="Area2D" parent="."]
position = Vector2( -140, 0 )
collision_layer = 4
collision_mask = 0

[node name="CollisionShape2D" type="CollisionShape2D" parent="AvoidedObstacleArea"]
shape = SubResource( 2 )

[node name="AnimatedSprite" type="AnimatedSprite" parent="."]
scale = Vector2( 4, 4 )
frames = SubResource( 7 )
animation = "run"
frame = 1
playing = true

[node name="JumpSound" type="AudioStreamPlayer2D" parent="."]
stream = ExtResource( 3 )

[connection signal="area_entered" from="AvoidedObstacleArea" to="." method="_on_AvoidedObstacleArea_area_entered"]
       RSRC                    AudioStreamSample                                                                 
      resource_local_to_scene    resource_name    data    format 
   loop_mode    loop_begin 	   loop_end 	   mix_rate    stereo    script        
   local://1          AudioStreamSample           }  ����ݪݪ
�
�����ӯӯ��P�P�����ѮѮ��^�^�������2�2�����������r@r@�j�j�\�\,c,ce`e`�`�`�a�a�_�_'b'b3`3`DaDa�a�a__�d�d�Z�Z�k�k�D�D�������<�<��������Y�Y������������������������]�]�����b�b�/�/�0�0�=�=�j�j�����������������	�	�b�b�A�A�:�:�@�@�����F�F�P�P�������`�`�u�u�y�y�l�lέͭ���P�P�+�+�z�z�������������/�/�(�(�|�|�����T�T�������R�R�ŦŦz�z�ȧȧ}�}���������H�H�����ѨѨD�D�����)�)�B�B��������<�<�:�:���8�8�H�H�������������6�6�#�#�����K�K�'�'�,�,�M�M���;�;�*�*�S�S�������i�i�q�q�����;�;�����ѺѺ`�`�}�}�ְְS�S�����Y�Y�ȲȲ����=�=�����_�_�����������������8�8�̧̧##ALALR=R=hHhHDADAEE�C�CCC]E]E5B5BpEpE�B�BDD/E/E@@EMEM��y�y�d�d�6�6���������=�=�����l�l�_�_���֗֗����V�V�����������_�_�����h�h�S�S���������ޭޭ+�+�ӭӭ+�+���������M�M�����خخ����.�.���������0�0�b�b���N�N�M�M�����~�~�h�h���\�\��������������������������|�|�������]�]�{�{�Y�Y���<�<����{�{������V�V'_'_�T�T�^�^VV�\�\ZXZX;Z;Z�Z�ZXXY\Y\!W!WQ\Q\pXpX�X�X�a�aR�R�A�A���������������������`�`�!�!�����|�|�>�>�_�_�!�!��������������۰۰�0�0ܠڠ�"�"����ٛݛݾپن݆����݀ڀ�}�}ŠƠƿſŴƴ�����i�i�f�fƭŭ�H�H�������M�M�.�.����ĝƝ�����o�o�������y�y�\�\�������������}�}�2�2���͡͡{�{�������xx�{�{�_�_�i�ihh]e]e�j�jdd�j�j�d�d�i�i�e�eJhJhLgLg�f�fihih�e�e�g�g�d�d�g�gee�f�f�e�e�e�e�f�f:e:egg�d�d9g9g�d�d�f�f�f�f�J�J!!����UU��--&&��������VV44//tYtY�d�d,c,c6d6dJcJcdd�c�c�c�c	d	d�b�b�d�d�a�a3f3f``�h�h�X�XPP��ZZGG��tt��55��������4	4	�Ȝ����ù��� � É����¤���)�)¡���C�C�����W�W�V�V�0�0�����RSRSfdfd�b�b�b�b�b�bcc�b�b$c$c�b�b�b�b�b�b�b�bPcPc�a�a2d2dZ_Z_UU�V�VMVMVWVWV�V�VVV�V�V�U�U�V�V�U�U�V�V�U�U�V�V2V2V�U�U�,�,i�i�����^�^�������$�$�V�V���������t�t�������'�'���|�|����� � �����9�9�R�R�g�g�������������������1�1�~�~�{�{�@@�-�-�K�KEEHHTFTFZGZG�F�F�F�F�G�G�E�E�H�HvDvD^J^JBB�M�M�9�9j�j�I�I�����8�8�������o�o�����N�N�2�2�������s�s�����!�!�ӝ�ƸƸ%�%���S�S�o�o�ѶѶ�𺕵��ĻĻl�l�$�$� � �����6�6�223T3Ti>i>cHcH�D�DDD�G�G�B�B H HCC�F�FpEpEhChCEIEI�>�>�M�M��ööK�K�����D�D�S�S�(�(���������r�r�����ɽɽ������h�h���pp����E E ��UU��QQ������bbuua	a	jBjB``ZTZTR[R[�V�V�Y�Y4X4X`X`XYY�W�W�Y�YhWhW�Y�Y�W�WYYKXKXZZ\\<[<[U\U\�Z�Zf\f\
[
[!\!\j[j[�[�[\\�Z�Z�\�\+Z+Zc]c])Y)Y(9(9�#�#U$U$G#G#6$6$�#�#�#�#�#�#r#r#@$@$8#8#V$V$=#=#($($�#�#l#l#�'�'S+S+�+�+9+9+�+�+++�+�+++�+�+4+4+z+z+�+�+ + +�+�+�*�*I,I,�)�)�'�'�'�'�'�'�'�'�'�'((~'~'<(<(M'M'T(T(J'J'0(0(�'�'�'�'w)w)EE�j�j�i�inini�i�iiiUjUj�h�h�j�j�g�grkrkhghg�k�k�g�g�i�i�m�m������I�I�ȷȷ��ǶǶ����o�o�@�@�����طط��J�J�-�-�O�O�RR  e
e
��xx�	�	XX%
%
``�	�	00��jj""99II�$�$�!�!�#�#B"B"W#W###�"�"�#�#�!�!<$<$�!�!=$=$�!�!�#�#�"�"**((

����������  ��vvIIRR� � 1P1Pcc�[�[aa\\�`�`A\A\@`@`B]B]�^�^�_�_h[h[�c�c�T�T}o}o`.`.�Ϊ������ܯݯ�~�~�۵�f�f�ۤ�����ܮ܄߄�2�2�������������a�aͭ�������J�J���8�8���]�]�ѻѻP�P�)�)�����V�V�׾׾/�/�\�\�		��WW����00��++  YYDD�������חח�����2�2�r�rյֵ�����P�P�G�G��֍֍��������֏ԏ�����""dd�Z�Z�]�]�]�]�[�[*_*_>Z>Zj`j`YYpapa"X"Xbb�W�Whaha�=�=7�7�����a�a�������������E�E�����o�o�;�;���������s�s�݌݌WZWZ�I�IWW�L�L,T,TVOVO#R#RQQ�P�PRR�O�O�R�R�O�O�R�R�N�N�N�N�L�L�M�MJMJM�L�L�M�M�L�L�M�M^L^LNN)L)LyNyN=K=K	Q	Q??A�A锲��ŵŵ����8�8�����A�A� � �\�\�����i�i��������������������������B�B�E�E���������*�*���s�s�߼�%�%���9�9�����l�l���$�$�R�R���r�r�����q�q�&�&���g�g�w�w�����ΞΞ̚̚����̛̛����ɜɜ�����睍���:�:�����������A�A����U�U�_�_�����7�7�f�f����;�;�����I�I�r�r����������M�M�}�}�"�"����ޢޢ�y�y�5�5�����������/�/�r�r�������A�A�D�D�ƝƝ��3�3�����������������E�E�����������s�s���d�d�������������J�J��İŰ���Q�Q�����?�?�F�Fơ¡�����z�zŭ��S�S-H-H�J�J�K�K?I?I:L:L!I!I�K�K�I�IKK�J�J�I�I�L�L�D�D��K�K�����8�8����� � �(�(�����z�zьЌ�������G�G�1�1�P�P�44EEmFmFHHFF�G�G�F�F�F�FdGdG3F3F�G�G�E�E�G�G.F.FRGRG�D�D�6�6�.�.�0�0�0�0L/L/�1�1�.�.{1{1�/�/m0m011Z.Z.�3�3n*n*�:�:���˥�n�n��̞̞����͗˗�y�y�@�@˷η������έʭʵϵ�E�EɵӵӔ�lDlDRDRD�D�DDD�D�DZDZD4D4D�D�D�C�ClElE3C3CwEwE�C�C�D�D#/#/5�5�'�'�V�Vƾ����À�������������(�(�������������G�Gá����������o�o�`�`���V�V�����m�m�����S�S�"�"������������6�6������𺚻��j�j�`�`�����-�-�#�#�"�"�7�7���=�=�-�-�&�&�q�q��±�w�w�'�'�s�s�Q�Q�<�<ŠŠ��������ŜĜ�=�=ƊĊ���k�kż¼�0�0�W'W'�*�*T+T+'*'*4+4+q*q*�*�*�*�*�*�*++,*,*�+�+))�.�.������˪˪.�.�V�V�������������������������îîB�B�R�R�������/�/�Q�Q�0�0�E�E�O�O�-�-�w�w�����������_�_�����m�m�]�]�����.�.�����J�J�����g�g޷޷�}�}ޣޣޔޔޕޕުު�Z�Z���D�D�����R�R�G�G�0�0�f�f���q�q�!�!�\�\�Y�Y���������������f�fғғ҄҄ҴҴ�c�c�����a�aҾҾҝҝ�U�U�V�V������ժƪƋ���f�f�������������Z�Z�.�.���������ġġ������8	8	uu��66VV� � 55w!w!ll""�!�!��R R ��z�z�������ŦŦ�����맟�����������"�"�H�H�ҫҫ��.�.�p�p����(�(���!�!GGaaAA��pp������������ff$ $   }}� � <<� � zzl l A A XX�!�!dd%%PP����`�`�}�}�%�%�U�U�k�k���������e�eŋƋ�������n�nāǁ����Ö���(�(���������������������������v�v�X�X�-�-�U�U����ϱ�G$G$���!�!!!� �   ��� � ��n n 7 7 ��R%R%
�
�����{�{�߲߲����������%�%���������C�C���������v�v�j�jΔ����������9�9�	�	�~�~���B�B���S�S�����������H
H
JJ��������������--OO����h�h�����Z�Z�ߩ�������������������{�{�����������K:K:�?�?�=�==?=?\=\=�?�?�<�<'@'@�<�<�?�?Q=Q=�>�>�?�?�9�9XX�h�hhbhb�d�d�d�d�c�cmemeccLeLe�c�c�c�cff�_�_`o`oU0U0˼˼��ףף����(�(�(�(������򢮤����������������E�E�����2�2�(�(�����7�7�1�1����ǭƭ�R�R�F�Fƶȶ����� � �P�P���������!�!���a�a�����z�z���������������������o�o�����������	�	�����[�[�-�-�׿׿����������������s�s�1�1��ʦ�*�*�##�����
�
����������GGttvvbb::��""��AA����@@dd����11�����S�S'a'a�c�c�`�`cc�a�a�a�aLcLc�_�_�e�e]]\h\h�Y�Y�l�l�P�P����T�T���b�b�������[�[���������]�]���ؿؿݼݼP�P�0�0�J�J�M�M�ݠݠ��\�\�{�{���֞֞՜՜����m�m�������ѝѝ�������������Ҫͪ�w�wҥͥ�	�	Ұΰ�L�L�a�a�K�K�����V�V�bmbm�`�`�i�i�e�e�e�e=h=hbdbdiidd�h�h�d�d�g�g�e�e>f>f�\�\HMHM�Q�Q/N/N�Q�Q�N�N�P�P�O�O&O&O�Q�QlMlM>S>S�K�K7U7UHH��I�I�����y�y�������������&�&�+�+�>�>�u�u�t�t���������򍳍�ͤͤs�s�����d�d�f�f�$�$�V�V���������ԩԩ��v�v�I�I����Җ	�	������HH��88��������[[SSuu�Ԛԇ���5�5�A�A�����������}�}�����*�*��⦽�����k�k����@�@�R�R�R�RUU�P�P=V=VuPuPVVQQ�T�T\R\R~S~STT8P8PP/P/6�6���**��%%� � AA����77��������PP���ϯ����ćĔ���j�jó���p�p��������¢����ø���0�0�һһ9�9�p�p����������������󲤴������ѳѳ���������򵿹��6�6��%�%rr��::``1100YY88����\(\(S:S:7777n7n7]8]8�6�6G8G8t7t7h7h7�8�8�5�5�:�:�2�2h?h?=%=%F�F�%�%������ňǈ�����`�`�^�^Żƻ�0�0�����G�G�e�e�J�J���4:4:�:�:":":�:�:":":�:�:::�:�:#:#:�:�:G:G:n:n:u:u:�5�5�-�-�+�+--/,/,�,�,�,�,o,o,�,�,!,!,--,,�,�,o,o,�,�,)6)6R:R:�8�8/9/9�9�9�8�8�9�9s8s8�9�9�8�8�8�8-:-:�6�6??��ddqq�	�	2200QQ���
�
��		����������.�.�����������l�l���������������0�0���T�T��``��MMkk��''������zz&)&)I,I,I+I+�,�, + +�,�,X+X+G,G,�+�+�+�+J,J,I+I+�,�,-+-+�&�&"$"$�%�%�$�$�$�$E%E%+$+$�%�%�#�#`&`&s#s#�%�%�$�$}"}"GG�X�X*T*ToWoW�U�U/V/V�V�VlUlU�V�VOUOU�V�V5V5V�T�T�Z�Z�6�6���!�!EET T ddbb99��..OO� � ww�&�&  ����y�y�����e�e�����������H�H�i�i�+�+�M�M�������������S�S���������������������������(�(�8�8���.�.�����!�!���������U�U�4�4�N�N���������i�i�II�0�0�/�/�0�0�/�/�0�0�/�/�0�0�/�/5050c0c0�/�/�0�0C/C/=0=0<'<'�'�'�'�'�&�&W(W(�%�%E)E)%%%%�)�)�$�$q)q)7&7&�&�&�-�-h�h�T�T�������m�m�1�1ťťœƓ�����������H�HƐƐ�@�@�g�gޚ�>>,,������__``����vv������2�2�[�[�	�	ܓۓ�~�~�_�_�|�|ܣۣ� � �]�]���F�Fݏۏ�m�m�ww##��FF��FF((BB""33SS������������N�N���������������(�(�����:�:�����������������������mmDDDD������''���.�.�=�=666:6:�8�8�7�7#;#;�5�5�;�;66�:�:�8�8�5�5�C�C � �����T�T�f�f������ܙؙ�%�%ݞ؞�������R�R�����C�C��
�
sMsMW9W9zBzB�>�>W?W?�@�@>>FAFA�=�=�A�A==�B�B
;
;�I�I�^�^�[�[�[�[�\�\�[�[�\�\n\n\/[/[y^y^wXwX�a�a�S�SzhzhPDPD����K�K��������ܸӸ�E�E����ԣڣ����֯دظظ������ڿܿ������ܝ�x�x�M�Mݓߓ�S�Sޔޔ�?�?��������ߑݑ�����c�c�y�y�������$�$�4�4�f�f� � �J�J�n�n���������6�6���߼���C�C�����������������$�$�����h�h�������ާާ��'�'�2�2�2�2�0�0E3E3�0�0.3.311�2�222<1<144d-d-DD�_�_�b�bbbwcwc�a�aycyc�a�a�b�bcc0a0aee>^>^$j$jOMOM�!�!o+o+�'�'�(�(])])�'�'�)�)s's'�)�)v'v'�)�)�'�'�(�(QQQQ��&&KK

LLhh��I	I	�������B�BȐȐ�#�#ȷȷ������ɞǞ�f�f�@�@�������������N�N�����U�U�D�D�H�H�3�3�n�n�����������������6�6�@�@�:�:S?S?�;�;�>�>'<'<�=�=�<�<\=\=I=I=�<�<=>=>�4�4A-A-g+g+J,J,�+�+�+�+,,�+�+G,G,y+y+Q,Q,�+�+�+�+�,�,$$IIf f ����BB������������  >�>Ϸ������������񰹲��B�B�G�G�����P�P���4�4�iis�s�FF��������P P ����� � ~�~�� � {�{�� � ��h�h�[�[ڡݡ�(�(���������)�)܌݌�T�Tۑޑ���D�D�O�O����==11}}������II11������((�����Μ������зͷ��������ͪϪ�X�X�R�RϮή�����������k�k�%�%�a�a�,�,�b�b�*�*�t�t��ҖҖ�������������b�b�:�:��(�(�-�-S+S+--�+�+�,�,�+�+�,�,�+�+�,�,
,
,),),s$s$��G�G�����������C�C���������F�F�����
�
�����������������y�y���������������3�3�o�o�����V�V�^�^�����X�X�]�]�������������μμy�y�?�?�ммD�D�\�\�����n�n�����������������f�f���F�F�;�;�	�	�� � N�N���*�*�&$&$$g$g�[�[�^�^3_3_.].]&`&`�\�\<`<`�\�\�_�_�\�\:`:`�Y�Y�4�4%%������LL������������������������������d�d�F�F���������~�~���>�>�A�A�D�D�������������1�1�����u�u�S�S�����A�A�����O�O�����u�u�P�P�����p�p�:�:�U�U�\�\�0�0�������������w�w�d�d�����44ww����ccqq��MM��UU��\\--{�{����ӧ�������S�SĝƝ����ƒŒŃŃ�i�i�H�Hēȓȗ�������JJ������������D�D�����i�i�\�\���t�t�2�2�H�H�e�e�&�&����������������������g�g������������������������������z�z�պպ޾޾V�V�����������d�d�-�-���ɹɹ0�0���l�l�����u�u�������W�W�8�8��⮼���>�>�2�2�	�	��D�DXFXF�>�>{G{G>?>?gFgF�@�@�D�DNBNB7C7C�C�C2B2B<D<D�B�BdEdE`C`C�D�D�C�C.D.D�D�D�C�CEEdCdC�D�D�C�C|D|D���ڹй�����S�S���������|�|�C�C�0�0զӦөԩԅԅ�$�$�1�1�������������������o�o�e�e�����U�U�������������ww��������������GG��TTe e <�<�a�a�����D�D�'�'�ϣϣ����e�e�4�4�q�q�����������������8�8��́ʁ�����B�B�����v�v�|�|��������ǝҝҰ���				�_�_�C�C�Q�Q�J�J(M(M%N%NsJsJkPkP3H3H	S	S&D&D�[�[�����ǼҼ�N�N�2�2���������	�	�����U�U�3�3�,�,�������,K,K�V�V�X�X�W�W�W�W�X�X�V�V8Y8YVV5Z5ZfTfT�]�]�F�F���������h�h�����!�!�������
�
���������Y�Y�������:�:�����"�"�����%�%�����C�C�������ߋ߉ω�N�N�"�"�'�'�>�>���a�a����χЇ����ϲвЙϙϚ̚�J�J����ƪƪ�j�j������řǙǈň�����M�M�������B�B�zz��<<��[[����OO&&������\\		����nnOOAAhh00kkPP66U�U�����������_�_���������`�`���������&�&�������YGYGTT�M�M�R�RNNzRzRNNPRPRiNiNdQdQPP�M�MwXwX����??��������P�P�������V�V���|�|����������
�
ccJ J ��[[j j � � f f RR��D D ����������I�I�D�D���j�j���2�2�����7�7�����o�o�ZZ�>�>�1�1�8�8�4�4�6�6)6)6[5[5�7�7�3�3::�/�/�A�A>>P�P���8�8�Y�Y�ШШ,�,���������Z�Z�ץץ������˷˷����		]	]	TT'	'	����9	9	55�	�	V	V	P
P
�$�$>>�<�<�<�<�<�<�<�<}<}<�<�<S<S<==^<^<�<�<�<�<�A�ABMBM�K�K�L�L�K�KnLnLKLKL�K�K�L�LOKOKdMdM�J�J�M�M�I�I�G�G�E�EGG�F�F�E�EYHYH�C�C%J%JBB�K�K�@�@ZLZL�A�A��s�s���������O�Oʝ�������m�mŢǢ����ƌŌ���������A�A�����i�i�������������~�~�c�c�/�/�$�$L;L;�3�3I;I;�3�3�:�:l4l4::^5^5�8�87766�=�=a�a�S�Séĩ�i�i�e�e�������7�7¸øÍ�f�f����� � �-�-�7�7�����ĿĿ���������º�������x�x�z�z��¾��������JJ������OO��ppJJ��XX�(�(DD�<�<�B�B>>�A�A=?=?Q@Q@�@�@�>�>�B�B�:�:VKVK����"�"�A�A���>�>���������U�U�|�|�:�:ٚ���$�$�U�U�yy��������**������uu������������������^�^���_�_���R�R�����11ufufwZwZ�_�_S]S]�]�]b^b^]]�^�^�\�\�^�^�]�]KRKR+�+�Z�Z�����������������V�V�ԺԺN�N������˖
�
������//

����  ��I"I"��\�\��������V�V�����e�e�����U�U���D�D�e�e�� � �)�)�$�$'&'&�%�%�%�%
&
&]%]%P&P&%%y&y&�%�%�!�!����ؠؠ"�"�\�\���������^�^�ԤԤe�e�������������m�m�V�V�פפ��������5�5�:�:�����:�:�L�L���>�>���33//�)�)�1�1�(�(�1�1�)�)�0�0++�.�.--�*�*�����㷾�������������������e�e�#�#�����8�8�����E�E��
�
B4B444[5[57373�5�5�2�2�5�533�5�5z3z3"5"5�3�3D#D#�#�#�#�#�#�#�#�#t#t#$$!#!#\$\$�"�"p$p$�"�"�%�%�%�%C&C&o&o&{%{%@'@'�$�$((�#�#�(�(\#\#�(�(�#�#^�^�U�U�q�q�
�
ߔ�����ޤ�����ޠ����>�>�$�$�����4�4�@�@�6�6\?\?�7�7U>U>�8�8A=A=�9�9$<$<�:�:�:�:b8b8����[[��cc��XX����77))���H�HOTOT�M�MGRGRDODO?Q?QPP�P�P�P�PPP�P�P�O�OHOHO3J3J
J
J�I�I�I�IJJ�I�IAJAJrIrI\J\JbIbIMJMJzIzI[J[J�J�J�J�JKK(J(JmKmK�I�I�K�K�I�IdKdKJJJJ+J+J^M^M-3-3OO��������00�����"�"����j�j�J�J�x�x�#�#�:�:۸۸�b�b�������n�n�V�Vݜڜ�n�n���b�b�L�L�Q�Q�g�g�Q�Q�D�D�������=�=�9�9�\�\�����ߋ�����E�E�ݲ�%�%�2�2�F�Fߋߋ�E�E����������B�B0D0DrGrGEE~F~F�E�E�E�E.F.F�E�EwFwF9E9E�F�FyCyCQBQB�A�A�B�B�A�A�B�B�A�AYBYB5B5B�A�ABB�B�B�3�3���竻��+�+�������������e�e���������������K�K�����tt����u	u	�
�
f
f
�	�	ss��{{���ŴŴC�C�����!�!���������������'�'���������J�J���������QQ������a#a#?D?DJ=J=1?1?�?�?�=�=@@�=�=�?�?)>)>k?k?�>�>�?�?�G�G@M@MMMrLrLSMSMhLhL5M5M�L�L	M	M�L�LMM L L-O-O/W/W!V!V�V�V�V�VyVyV�V�V%V%V+W+WVV�V�VWWuPuPQ Q ����y�y���������������������~�~�������������*�*�� �?�?�������\�\�����K�K�����q�q���~�~�i�i���������������ܧܧ����˧˧ӦӦ����<�<���u�u�i�i�7�7���������m�m���5�5�E�E�����S�S�3�3���������rr11����������v	v	ddSS��� � ��șǙ�������:�:��ǧǧ���$�$�v�v�����}�}�P�P�����O�O���1�1�$�$� � �;�;���������O�O��������������������� � �����������ߪߪc�c����������:�:,4,4�2�2�6�6j2j2�5�544l3l3B7B7//�=�=���ԩ�-�-�����J�J����߉ى�������
�
���^�^�����5�5�u�ūɄ�|�|��������˘ʘ���u�u�b�b�����~�~�-�-����ϳѳ�c�c���.�.�E�E���������!�!����Ϲѹф̈́�R�R������ɋˋ˙əɵ˵�����:�:ˤʤ�����$�$�ɱɱ=�=�l�l���޴޴C�C�C�C�S�S��������� � �z�z���P�P��ʧƧ�$�$�5�5������̎����Ҭ�ηηB�B�\\�M�MDODO}R}RbMbM�R�R�M�M�Q�QOOPPRR�F�Fbb|�|��ݬܬ�����j�j�h�h�i�i�����T�T�����q�q�y�y��7�7�0�0�/�/44�-�-�4�4....�3�3�/�/&2&2/1/1�0�0�8�8�6�6j;j;u6u6�:�:�7�7�8�8x:x:�5�5�=�=�1�1AAII��������f�f�������������˻˻��O�O�����'�'�>>�X�XIVIVVZVZ{U{UpZpZ�U�U�Y�Y�V�V�X�X�W�W�S�S������������������������w�w���}�}���b�b�������
�
�	�	``+	+	��$	$	�	�	�	�	��mm������������>>__�����"�"H"H"u"u"y"y"Y"Y"y"y"q"q";";"�"�"�!�!M#M#����``��[[����gg��kk������yy��$$VV������������r�r���������������������������������+�+�m�m�V�V�0�0�T�T�j�j������� � �������������M�M��������՝ם�����B�B֝؝���X�X���
�
��������������OO��qq��������DD����������__�����0�0=9=9�7�7�8�8 8 8�8�8Z8Z8k8k8�8�8-8-8�8�8�7�7�7�7"7"7�7�7B7B7u7u7j7j7H7H7�7�7*7*7�7�707070707w4w4|3|3P3P3k3k3s3s34343�3�3�2�2442266�(�(x�x�������O�O�����-�-�����3�3�����������~�~�����F�F���������"�"�������������������!�!�����Y�Y�����1�1�����Q�Q�����������������60602O2O�K�K,K,K�L�L�J�J�L�LKK%L%L�K�K�L�L�=�=`�`�����P�P�
�
�Q�Q�_�_���<�<�x�x�����"�"��������#�#����II����99V&V&sAsArMrM�J�JLL�K�K�K�K�K�KKK�L�L�I�I�O�O�6�62	2	II����&&������� � � � AA��``���������3�3�T�T�����b�b�������(�(����������#�#!!�!�!������QQ� � ���?�?NWNW4P4PRRSS7P7PTTPP�R�R�R�RPMPM�`�`>�>���������ӯӯy�y�ڳڳa�a�,�,��ﲺ������������ʻ�����5�5�:�:�������U�U�/�/�g�g�S�S�R�R�������������������������������������.�.׼Լ�X�Xԩթ������������Ӭլ�O�O�A�A�����6�6�%�%�9�9�2�2�5�5�4�4�4�4Q5Q5a4a4s5s5_4_4�5�5B&B&����S�S���������n�n���������(�(���������V�V�;�;�22^E^EM<M< B B>>>>�@�@W?W?�?�?@@??W@W@e@e@�H�H�I�I�I�I�I�I�I�I�I�IpIpI�I�IiIiI�I�IaIaI5F5F�6�6�1�1�4�4�2�2Z4Z4�2�2�3�3>3>3�3�3�3�3*3*3�0�0;";"QQ� � ��� � ��� � ��� � ��� � �
�
"�"������܃ك�����Q�Q�_�_�����#�#�������"�"�**�3�3h.h.7272X/X/z1z1�/�/�0�0P0P0�0�0�0�0�%�%99ZZ��������}}��gg��>>�"�"�(�(�)�)�(�(�)�)�(�(�)�)H(H(.*.*�'�'�*�*e'e'������������	�	���������/�/�`�`�����������z�z�-�-�����<�<�m�m���������������������]�]���W�W�������������������R�R�4�4����;�;�9�9�8�8�:�:~8~8�:�:s8s8�:�:�8�8�:�:a6a6��j�j�.�.�j�j�����x�x�����Y�Y������������������D�D�O�O�Q�Q�P�P�P�POQOQ'P'PRRgOgO�R�R�N�N�S�S�R�RaUaU�R�R�T�TTT�R�RVVhPhP�X�X�L�L[\[\e�e�.�.�P�P�^�^���������������^�^ɷ���5�5�  4I4IAAEE�B�B�C�C�D�D=A=A�G�G><><�Q�Q�����Ô̔�c�cƲȲ�����%�%ǽɽ���-�-�]�]����ǭۭ���r�r�)�)�������z�z�L�L����o�o�G�G�"�"������]�]�����%�%�����#�#�����%�%� � �9�9�������������k�k�S�S���������c�c�-�-�H�H� � ��������Ք���������g�g������سٳ�������\�\�*�*�����W�W��������� � ���B�B�!�!�o�o�]�]���-�-�"�"5*5*�$�$w(w(<&<&Z'Z'''�&�&�'�'DD�	�	%%��AA��**��``!(!(,,�(�(�+�+S)S)++++�)�)�*�*<*<*A*A*{*{*w%w%..))FF������LL%%����

$
$
�	�	5
5
�	�	=
=
�	�	X
X
�	�	�
�
��j�j�)�)��� � �6�6�����6�6� � ���)�)��������������J�J�����<�<�����D�D�����[�[�����s�s�����p�p�/�/�d�d�:�:�V�V�O�O�>�>�c�c�H�H�����h�h����?�?�<�<�<�<�=�=<</>/>�;�;�>�>�:�:�@�@�2�2}}���� � �[�[���C�C�$�$���T�T�����������p�p�K�K�����*�*�����@�@�����u�u�f�f�����G�G�������������������������$�$�d�d�g�g�x�x�^�^�NN������kk}}�������#�#�
�
�����������������������������������`�`���11�A�A'<'<�?�?�<�<6?6?�=�=>>R?R?�;�;�D�Ddd����**e e ��oo��������00h	h	�7�7�M�MCC�J�JTDTD!J!JEE(I(I�F�F6F6F\N\Nj�j�����N�N�"�"���������8�8�A�A�U�U��¶��������3�3�N�N-?-?JJ_B_BNGNG�D�D+E+E�F�F�C�CnGnG�@�@�B�B�?�?�A�A;A;A@@�B�B�>�>�C�C�=�=�C�C\6\6����3�3�����������������A�A�H�H�����k�k��������������Q�Q�i�i��߷޷ޣߣ�X�Xް߰�:�:���)�)�2�2���������7�7�����E�E���������g�g�����\�\�%�%�����������������������u�u�����`�`�����m�m����Ӂց�V�V�y�y�3�3؆І���
�
�  O^O^�I�I�P�PPPMMNRNRpKpK�S�S�I�I W W77�
�
vv��__��NN������55�&�&_ _ �%�%%!%!�$�$�"�"�"�"d%d%**]/]/�����ήΚ����������������ʇ������:�:t9t9==m:m:�;�;u;u; ; ;<<�:�:y<y<
0
0��]]\\FF����((������R�RЧ����˨���������r�rŔȔȸƸƁǁǤǤǼƼ���������S�S�����n�n����ѬѬѰѰъъ�o�o���������u�u�������������������������w�w�dd��33������33ww����K$K$2#2#�$�$##�$�$_#_#6$6$V$V$�"�"d'd':�:�v�v�Z�Z���J�J�5�5�������N�N��ǖ�k�k���w(w(����kk00����PP		��<$<$E:E:CFCFAAFF�@�@�E�EBB�C�CEE??yHyHK�K�|�|��ˈ�[�[��ƴŴ�������������*�*�+�+���Z�Z�R�R�����߿߿d�d���~�~�ƿƿ�������ÇŇ�4�4���e�e���W�W�=�=�F�F�$�$�&�&�{�{�����)�)���ŵŵ����Q�Q�����g�g�������Y�Y�P�P�������ڵڵѵѵ&�&�����X�X�����+�+���~�~�-�-�"�"���������&�&�B�B�����ϪϪT�T������� � �5�5���#�#�D�D�����h�h��������ӧ˧˔ǔ�S�S�����0�0�����������A�Aǃǃ��������� � ��������i�i�_�_�����G�G�����C�C��������
�
���	�	88��B	B	wwAA]]FF����������k�k�l�l���h�h�����#�#�ӽӽ������?�?����ɀʀ�^�^�����L�Lɸʸʖɖ�t�t������ۀ��6�6x.x.c2c2�0�051516161�0�0�1�1�0�0�-�-KK��UU		����  %%``JJ���)�)�2�2\-\-�1�1�-�-�1�1�-�-�1�1�-�-�0�0*0*0""���	�	����FFUU|	|	33�
�
44���҉�������������X�X���������������5�5�?�?�����������������ѷѷ۽۽߳߳���˺%�%�I�I�H�HII'H'H�I�I�G�G�I�IxGxG�J�J�B�B�*�*����<<ZZxxVV>>��F#F#/5/5�=�=�;�;==�;�;�<�<�;�;�<�<.<.<�<�<�1�1��%�%�������k�k�m�m�������
�
�3�3�����������1�1�����>�>�����N�N�o�o�^�^�y�y�����������.�.�-�-�5�5���I�I���P�P���2�2�		((�	�	�
�
%
%
�
�
8
8
�
�
�	�	qqP#P#�9�9�:�:::R:R:U:U:::�:�:�9�9U;U;+7+7		BB������������cc\�\����[�[�����r�r�������������-�-�������U�U����������t�t��������������7�7�)�)�(�(�Y�Y�8�8ĖŖ�.�.���[�[�M�MŴĴ�@�@�J�J�����ȲȲ������������ͰͰկկ��1�1�����LL����HHt
t
pp9
9
xx��M M ������q�q�o�o�������  ������((��QQ��{{rr��33��""1*1*�*�*�*�*�*�*�*�*�*�*�*�*�)�)$,$,g&g&t�t�u�u�P�P�����z�z����ĒĒ����ĔĔ�����������y�yҌҌ��ңң���}�}�T�T�\�\����ִ����__��UUjj}}jj\\���
�
CC������.�.�����R�R�����~�~�����8�8�II���(�(,%,%�&�&�%�%.&.&?&?& & &H&H&&&����������������`�`�'�'����������������__��uu��~~44VVIIyy��B�B�
�
���{�{���������������������������ݼݼt�t�#�#�#�#�����ּּ������������m�m�

����bb??���
�
zzaa����`�`�D�D�������������������������Y�Y�PPUU::����zz������

���ӽӽ*�*̲ò�$�$�����I�I���������L�L˯įČ � �S�SI=I=�K�KcAcA�H�H�C�ClFlFFFDD�4�4����k�k�S�S�������C�C�5�5����ĸŸ����� � ��%�%�+�+3)3)**:*:*>)>)�*�*�(�(�*�*g)g)M9M9D?D?�?�?�@�@>> C Cg;g;%F%F�7�7�K�K�(�(��������������`�`����ʗėęʙ���������t�t�1�1�r�r�e�e�>�>ٕڕ�I�I٘٘�T�T���XCXCt;t;�>�>K=K=�=�=�=�=�=�===�?�?C-C-!!''��OO--]]��jjj�j�>>9 9 ��� � [[� �   %%������������$�$�������$�$�������'�'������W"W"�!�!�#�#A A V%V%ss|'|'��!,!,<<��������������g�g�������]�]�������������R�R�*�*�9�9�����F�F����������f6f6�,�,�0�0M/M///I0I0�.�.t0t0�.�.�1�1D=D=HH�C�C9F9F�D�DWEWE�E�E�D�D�E�E�E�EK(K(z�z�ͩͩ������}�}�����I�I�����ͱͱT�T�)�)�U'U'�0�0�/�/�.�.�0�0�-�-
1
1�-�-�0�0�/�/������c�c�����ʵʵV�V�����v�v�<�<�h�h��'�'�7�7�3�3�8�8�3�3h8h8_4_4j7j7l5l5\6\6b9b9=C=C_B_B�A�A C C<A<A�C�C�@�@DD^@^@�A�A��j�j�������{�{�+�+�����d�d�m�m�������O�O�ջջ&�&�����9�9�������������ûûw�w�����L�L�ûû]�]�����ɺɺ��ٻٻ����I�I�������o�o�ߣ��������߮��H�H�q�q�s�sы�������ررE�E���������d�d�����.�.�w�w����߼��m�m����H�H�>�>�����:�:�h�h���������.�.w+w+�)�)6-6-�(�()-)-\)\)m,m,0*0*�+�+J-J-�.�.J/J/�-�-�/�/�-�-T/T/B.B.�.�.&/&/,,�'�'�&�&w'w'�&�&�'�'�&�&i'i'�&�&#'#'''�$�$'#'#�#�#f#f#�#�#k#k#�#�#z#z#8#8#*%*%XX���֥ͥ�����
�
�u�u�H�H�Y�Y�g�g�'�'�#�#Ѝ�����9�9���0�0�����_�_�v�v��������6 6 '!'!&!&!KK� � ��w w ��3 3 N N 2 2 b b 2 2 L L O O ! ! z z ��] ] ""����!!��yy11��ii�,�,�H�H"G"GKKDGDG�J�J�G�G�I�ISISI;G;G'I'IA
A
]�]������������0�0�����w�w�+�+�+�+�ee44�/�/�4�4e0e0�3�3b1b1�2�2]2]2{1{1!)!)������������>>~
~
uu��I�Iǀ���H�H��񷉺����"�"�����i�i�ݹݹ��A�A�Y�Y�0�0�����۾۾!�!�
�
�a�a�ջջO�Oȉԉ�E�E��������ӧӧ��ԆӆӆԆ�2�2�?�?�6.6.!<!<�8�8�9�9b9b9�9�9P9P9�9�9$9$9�:�:�?�?3B3B'@'@�A�A�@�@$A$ABABAy@y@�A�A@@mFmF�J�JVMVM�K�K]L]L�L�L�J�J�N�N�H�H�Q�Q�A�A�	�	T�T�������]�]�������������@�@�"�"�>�>�V�V�����9�9�$�$�����ŰŰ-�-�����m�m���p�p�{�{�!�!����������I�I���������D�D,6,6[>[>�9�9<<*;*;;;{;{;�<�<��C�C�C�C�������q�q�������K�K�|�|�o�o�m%m%�C�C&:&:`C`C0;0;BB�<�<�@�@D>D>>>�%�%��::++GG������������  ��mmpp����bb����ދ�
�
�R�R�w�w�����K�K�����߾�M�M��دͯ͸ϸ�M�M������ΚΚ�)�)Ϯή�
�
����߻�����//--OO;;==??\\���
�
��uu����������  j*j*6:6:::�:�:�9�9�:�:�9�9�:�:�9�9�:�:�8�8�4�4�5�5�4�4�5�5�4�4x5x5�5�5444488�+�+����mm  ����}}��00BB����++SS��++����77�R�REE�M�M�H�H�J�J�J�J?I?I�K�K�H�Hw<w<�-�-�/�/..�.�.�.�.�-�-�/�/J-J-�/�/��88� � ��~~yy==mm��f�f������@�@�k�k�5�5�����������4�4�U�U�>�>�����y�y���������T�TՕӕ�|�|���������������N�N�������^�^�����E�E���]�]�W�W����������N�N�������88�J�JkEkE�I�IGG�G�GNINI�D�D�L�L�;�;�������I�I���h�h�+�+�K�K�_�_���1�1����ȡ̡̨̨�������������F�F̓̓����̹ѹ�o�o��������՚ٚ�J�J�[�[װڰ�����,!,!�J�J�6�6fCfC&;&;A@A@�=�=b>b>�>�>A=A=mCmCCCDEDEVCVC�D�D�C�C�D�D�C�C�D�D�B�B�2�2�*�*�*�*o*o*�*�*4*4*++�)�)�,�,!!s�s���2�2�P�P�$�$ɒɒɘʘ�X�X�+�+ΐ�����V	V	����tt��DD��������{�{�V�V�r�rߺ޺�������������C�C���OO��jj1111RR;;��II�ֵ���;�;�����>�>��϶Ӷ�������\�\��ϗї���������.�.���N�N��������Ԟ�e'e'�&�&h#h#�'�'�#�#�%�%�&�&w!w!�.�.���؏���~�~�!�!���B�B�b�b�����ݹݐ���YY��99����00��������m�m�����������8�8�����P�P�����h�h���xx������QQ��@@aa��33��IIXX��# # ww%%dd����qq����##�?�?EE^D^D�D�DbDbD�D�DjDjDDD�F�FGG�Ϭ�z�z����ƺĺ�����C�CŇŇ�y�y�s�s�����q�q���}�}�#�#�~�~�)�)ˀʀ�2�2˄ʄ�]�]͇ՇճԳ������կԯ�R�R�O�O�����e�e�����f�f�9�9�B�Bߴߴ��ߴߴ�F�F�X�X�����������n�n�@�@���s�s� � ���8�8�����}�}�hh��77[[����WW��--SS88GG11OO//55����r�r������������������������P�P�'�'���FFVVRRrr��::���'�'�.�.--�-�-s-s-~-~-�-�-4-4-u.u.�!�!��		�
�
�	�	%
%


�	�	2
2
�	�	0
0






+
+
�	�	[
[
�	�	�
�
		U'U'G<G<�;�;�;�;<<d;d;4<4<�:�:9=9=�5�5����&&\\������DD++�2�2Q1Q1�1�1�1�1�1�1�1�1�1�1Q1Q1[9[9,F,F�H�H�G�GHHHH�G�G>H>H�G�G>H>H�G�G�D�DAA�@�@AA�@�@
A
A�@�@AA�@�@y@y@-;-;�9�99999M9M9�9�9�8�8j:j:T7T7==== , ,��		��VV��������		3333����[[++�����������!�!�(�(A%A%9'9'&&{&{&�&�&�%�%J'J'#.#.�=�=�=�=�=�=�=�=�=�=C>C>==�>�>o<o<�3�3��- - ��� � qqW#W#``.&.&�������/�/�g�g�������������w�w�����''��~~����88��hh��""����ss]]����>>22n�n�V�V���������q�q���������������������-�-�ǵǵ��������G�G���K�K�b�b�%�%������#�#bbLL����KK��RR""��
�
�S�S�����������;�;�+�+���J�J�II�/�/�*�*k!k!)()(�#�#0&0&f%f%�$�$99�7�7s9s9Y7Y7�9�977
:
:q6q6�:�:�&�&"�"�������������������������������::������� � � � ����������HH�%�%�"�"X$X$_#_#7$7$P#P#O$O$2#2#�!�!����������ww����HHI I ����c�c�������2�2�J�J���������]�]���v	v	;;*	*	������nn�B�B$E$E�E�EFF�D�DjFjF�D�D�E�E�F�F�7�7k+k+�.�.�,�,Y-Y-�-�-w,w,;.;.%,%,�-�-	4	4775566;6;6�4�4�7�7J3J3�8�8''0�0�M�M�������������3�3�����������A�A�C�C�����u�u������������� � ������22<<^^����OO��]�]�;�;�R�R�;�;Ľ�������|�|�j�j�	�	�����F�F�-�-�����x�x�������(�(�ZZ; ; ZZ] ] ��''��o�o�$�$�Y�Y�������2�2�������A�A�����UUY1Y1W2W2#2#2�3�3�0�0�4�4w0w044])])L�L�����%�%�ܯ���������������{�{���� � !!��m!m!��n!n!���!�!%%tt<<++����kk����NN����``����pp99?�?៻��S�S�������������������������������G�G���ڳڳ����M�M�����ȨȨ&�&��G�G::};};�>�>5959�?�?�8�8q?q?::�B�B�B�BDD�C�C1C1CLDLD�B�B�D�D�C�C
0
0H�H�������E�Eڇ݇�=�=���������L�L�i�i�m�m���L�L����خخ�U�Uؗٗ���>�>������ � ����==����K�K�5 5 � � K�K���S�S�����������������w�w�h�h������*�*%%�&�&''�%�%�'�'"%"%J(J(����,,MM�
�
WW

���	�	�������������@�@���������z�z�h�h�J9J9�1�1�2�2b4b4[1[1�4�4E1E1�4�4�1�1�3�3�1�1�2�2#2#28282�2�2�1�10303�0�0M9M9V?V?�A�AV@V@�A�A�@�@SASA�@�@�@�@�A�A�(�(J#J#~$~$�"�"�$�$�"�"%%T"T"�$�$��]]bb��LL���
�
��. . !�!����؆܆�Y�Y�6�6�+�+ڢڢ���/�/�D�D���NNaaUUTT����������ѹѹo�o�������a�a�!�!�t�t�T�T������ �   z z � � ����~~����OO��VV		��ZZ::nn������������l�l�h�h���������c�c�9�9��+�+fCfC�<�<�B�B�=�=�A�Aw>w>_A_A�=�=g g n�n����`�`�0�0�����\�\�|�|�~�~����B�B�A�A�B�BjCjC@B@B@C@CCCBB&:&:1�1隲���Ř�M�M�(�(�R�R�۾۾o�o���ٷ�L�L�-�-�b�b���������p�p�����h�h����� � E�E�� � g�g�� � H�H�������������������Y�Y�_�_���(�(�����|�|�c�c���������������`�`µ���R�R������Ŵ�������F�F�Q�Q����ͼʼʄ΄�/�/��ϫ���		�	�	���	�	���	�	�����"�"� � P!P!� � O!O!� � �!�!���'�'^;^;DD5B5B�B�B�B�B�B�B&C&C�A�A�E�Ed*d*[[}}����OO��OOG�G�S�S���[�[�������8�8�������|�|�I�I�V�V���������x�x�������������T�T����	�	��##jj����������	�	�����C�Cȑ�����j�j�8�8������»�O7O7 K K�;�;�H�H�=�=xFxFy?y?	E	ET>T>�����w�w���}�}�0�0�����D�D���::r0r0�+�+D0D0�,�,h/h/�-�-�.�.�.�.q q �������������8�8�����'�'���""�?�?>>�?�???�>�>@@�=�=�?�?Q+Q+))��,,W
W
OO8�8��������������x�x��������������



BB����������������@�@�#�#�&�&דԓ��������Կ׿�v�v����(�(�����h�h���������M�M�W�W�����������&�&�X�X�
�
�������&&�2�2�-�-�1�1�-�-�1�1�-�-�0�0d)d)����d�d�8�8�%�%�����������������S�S�.�.�{�{ۮݮ�m�mۨݨ���&�&ݲܲ�N�N�����������������H�H�*�*�X�X�J�J�I�I�ll//%%X+X+�&�&�)�)�'�'�(�(A(A(9
9
A�A�����R�R�=�=�
�
���������G�G�S�S���������t�t�-�-�����_�_�������q�q�~�~�������L�L������������#�#]%]%�%�%n%n%�$�$�%�%M$M$�%�%�����d�d�����x�x���m�m���������''������dd��w	w	��|�|�����������������������%�%�G�G��������������ݓ��ݎ���>�>�;�;�WW��55��QQ88�������ҵ�G�G�w�w�6�6،ٌ�*�*�"�"�#�#�e e �.�.['['�,�,�)�)�*�*�*�*�)�)++))�*�*))g*g*j)j)�)�)�)�)�(�(,*,*6(6(�(�(�&�&)()(k'k'�&�&�(�(�$�$,,((>�>�,�,�����#�#���������I�I��ցځ�?
?
W'W'��;";"  � � � � ��!!j j e"e"� � �!�!� � ~!~!� � Y!Y!��MM� � ����� �   � � H H u u � � ����~�~�8�8�����#�#���������������������������66P�P����ڧק���������S�Sڦצ�
�
�{�{��������W�W�C�C�e�e�����Z�Z����������%�%""w$w$~#~###0$0$""%%��������??""������PP������__**  22����ii������dd��]�]�{�{�a�a�<�<�����?�?�������*�*�4�4�������y�y�������������QQ��EEkk����//MM������@@����NN�!�!+ + ����������g�g�����g�g�����z�z�L L � � Q Q   ^^������~~UU��������||������=�=���������������������[�[���������B�B�;�;�����������f�f�����W�W�����O�O�^�^�3�3�������{�{���J�J�������������2�2�����l�l���1�1�����8�8�����2�2������������8�8�������$�$�)�)�����������������R�R�����C�C�����U�U�����������II==��^^������������OO��������1�1�����M�M�w�w�j�j�����K�K�s�s�PP����������������������������U�U�]�]�B�B���������""YY~~��__uuuu����E�E�w�w�V�V�����V�V�R�R��������		��		����		

�	�	����������������������'�'�$�$�<�<�����$�$�����y�y���������������������� � II##��**��''��������������������R�R�<�<�����5�5�/�/�L�L�p�p�,�,�CCOO__������UU����������xx��{{>>GGVV��66��CCQQbb����66����,,@@gg��  ��7�7���D�D�\�\�����������'�'�����������������,�,���������h�h�� � ��������������������� � � � ����gg������                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ��           RSRC   [remap]

importer="wav"
type="AudioStreamSample"
path="res://.import/170145__timgormly__8-bit-explosion1.wav-eb002f2a9995c8f090b469ddc489ef17.sample"

[deps]

source_file="res://Sounds/170145__timgormly__8-bit-explosion1.wav"
dest_files=[ "res://.import/170145__timgormly__8-bit-explosion1.wav-eb002f2a9995c8f090b469ddc489ef17.sample" ]

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0
           RSRC                    AudioStreamSample                                                                 
      resource_local_to_scene    resource_name    data    format 
   loop_mode    loop_begin 	   loop_end 	   mix_rate    stereo    script        
   local://1          AudioStreamSample           , o�q�s�u�w�y�{�}�����������������������WUSQOMKIHFDB@><:86421/-+)'%#!������������������������������������	���������& �����������������������������T�V�X�Z�\�^�_�a�c�e�g�i�k�m�o�q�s�u�v�x�z�|�~��������rqomkigeca_][ZXVTRPNLJHFDCA?=��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������7�������������������������	�
�f����������������������������#������ �!�!�"�#�#�$�%�%�&�&�'�(�(�)�*�*�+�,�,�-�-�w���������������������������@�A�A�B�C�C�D�D�E�F�F�G�H�H�I�J�J�K�L�L�M�M�N�O�O�P�Q�Q�����������������������������d�d�e�f�f�g�h�h�i�j�j�k�l�l�m�m�n�o�o�p�q�q�r�s�s�t�t�u�����������������~}}||{zzy�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuu��������������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuub����������������������������k�uuuuuuuuuuuuuuuuuuuuuuuuuuu������������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuu�	������������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuQ����������������������������|uuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������uuuuuuuuuuuuuuuuuuuuuuuuuuuu�����������������������������kjjihhgffeddccbaa`__^]]\[[ZZ��������������������������������������������������������GFFEDDCCBAA@??>==<<;::98876��������������������������������������������������������##"!! ���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������6�����������������������������
��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������H�������������������������������������������������������j����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������|������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������h ��������������������������������������������������������������������������������������&�'�(�(�)�*�*�+�,�,�-�-�.�/�/�0�1�1�2�3�3�4�5�5�6�6�7�8�5�����������������������������K�L�L�M�M�N�O�O�P�Q�Q�R�S�S�T�U�U�V�V�W�X�X�Y�Z�Z�[�\�\�]�����������������������������p�q�q�r�s�s�t�t�u�v�v�w�x�x�y�z�z�{�|�|�}�}�~�������}}||{zzyxxwvvuttssrqqpoonmml������������������������������ggggggggggggggggggggggggggggg������������������������������ggggggggggggggggggggggggggggY�������������������������������gggggggggggggggggggggggggggg������������������������������ggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg���������������������������������ggggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg��������������������������������ggggggggggggggggggggggggggggggT
�������������������������������gggggggggggggggggggggggggggggg�������������������������������A�gggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg���������������������������������ggggggggggggggggggggggggggggggg���������������������������������gggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg��������������������������������gggggggggggggggggggggggggggggg��������������������������������ggggggggggggggggggggggggggggggs�������������������������������{
gggggggggggggggggggggggggggggg�������������������������������"�gggggggggggggggggggggggggggggg��������������������������������TSSRQQPOONMMLKKJJIHHGFFEDDCCBA��������������������������������������������������������������-,++**)(('&&%$$##"!! ������������������������������������������������������������� ������������������������������������������������� � ��������������������������������� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � ������������������������������� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �������������������������������~� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �������������������������������$�%�%�&�&�'�(�(�)�*�*�+�,�,�-�-�.�/�/�0�1�1�2�3�3�4�4�5�6�6�������������������������������K�L�L�M�M�N�O�O�P�Q�Q�R�S�S�T�T�U�V�V�W�X�X�Y�Z�Z�[�\�\�]�]�������������������������������r�s�s�t�t�u�v�v�w�x�x�y�z�z�{�|�|�}�}�~������������zzyxxwvvuttssrqqpoonmmllkjjihh���������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�
�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY��������������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY4	�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYB�����������������������������������^YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�������������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�������������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY�����������������������������������YYYYYYYYYYYYYYYYYYYYYYYYYYYYYXXWV5�����������������������������������??>==<<;::988766544332110//.--,,+f�������������������������������������������������������������������J

	 �������������	�
�
������������������������������������������������������-�-�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�M����������������������������������3�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.��������������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�2����������������������������������M�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�����������������������������������.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.�.���������������������������������������������F�G�H�H�I�J�J�K�L�L�M�M�N�O�O�P�Q�Q�R�S�S�T�T�U�V�V�W�X�X�Y�Z�Z�[�\�\�]�]�^�_�_�`�a�a�b�c�c�d�d�������������������������������������������~}w������������������������������������������������������������������^]]\\[ZZYXXWVVUTTSSRQQPOONMMLLKJJJJJJJJJJJJJJJJ��������������������������������������������������JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJu�������������������������������������������������JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ_�������������������������������������������������JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJI�������������������������������������������������hJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ2������������������������������������������������~
JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ������������������������������������������������JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ������������������������������������������������JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ�
������������������������������������������������JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ���������������������������������������������������JJJJJJJJJJJJJJJJJJJJJIHHGFFEDDCCBAA@??>==<<;::9������������������������������������������������������������������������������������������������

	 �������������	�
�
���������������������������������� �!�!�"�3������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�o������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<������������������������������������������������<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<�<������������������������������������������������V�V�W�X�X�Y�Z�Z�[�\�\�]�]�^�_�_�`�a�a�b�c�c�d�d�e�f�f�g�h�h�i�j�j�k�l�l�m�m�n�o�o�p�q�q�r�s�s�t�������������������~}}||{zzyxxwvvuttssrqqpoon�������������������������������������������������ONMMLLKJJIHHGFFEEDCCBAA@??>====================������������������������������������������������������������������������������������������������===============================================]�����������������������������������������������������������������������������������������������===============================================�����������������������������������������������������������������������������������������������===============================================������������������������������������������������������������������������������������������������==============================================�����������������������������������������������������������������������������������������������P
==============================================7����������������������������������������������������������������������������������������������==============================================������������������������������������������������������������������������������������������������==============================================�	����������������������������������������������������������������������������������������������+==============================================\����������������������������������������������������������������������������������������������v�=================<<;::988766544332110//.--,,+**������������������������������������������������������������������������������������������������

	 ������������������������������������������������� �!�!�"�#�#�$�$�%�&�&�'�(�(�)�*�*�+�+�,�-�-�.�/�/�0�1�1�6������������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�������������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�������������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�i�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�������������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������y�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J������������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�������������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������P�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J������������������������������������������������ J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�t
�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J������������������������������������������������'J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�9�����������������������������������������������J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�����������������������������������������������aJ�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�J�  �����������������������������������������������t�v�w�x�y�{�|�}����������������������������������������w�NMLJIHGEDCB@?><;:97653210.-,*)('%$#" ���������������������������� �������	�
����������������� �!�"�$�%�&�'�)�������������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X��������������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�Z������������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�������������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�����������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�����������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�����������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�����������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�����������������������������������������������P�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�������������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�����������������������������������������������#�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X������������������������������������������������� X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�>��������������������������������������������������������������������������������������������������������'	X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X��������������������������������������������������������������������������������������������������������������X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�X�	��������������������������������������������������������������������������������������������������������R]�^�_�_�`�a�a�b�c�c�d�d�e�f�f�g�h�h�i�j�j�k�l�l�m�m�n�o�o�p�q�q�r�s�s�t�t�u�v�v�w�x�x�y�z�z�{�|�|�}�}�~������������������������������������������������������� ^]]\\[ZZYXXWVVUTTSSRQQPOONMMLLKJJIHHGFFEDDCCBAA@??>==<<;::988766544332110//.--,,+**)(('&&%%$##"!!!!!!!!!!c�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������k�!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ���������������������������������������������������������������������������������� ��������������	�
�
���������������������������������� �!�!�"�#�#�$�$�%�&�&�'�(�(�)�*���������������������������������������������������������������������������������������������������������Tf�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�,���������������������������������������������������������������������������������������������������������� �f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�c�`	���������������������������������������������������������������������������������������������������������f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�����������������������������������������������������������������������������������������������������������
��f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f������������������������������������������������������������������������������������������������������������|�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f���������������������������������������������������������������������������������������������������������Df�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�<�����������������������������������������������������������������������������������������������������������f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�s�p
���������������������������������������������������������������������������������������������������������f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�f�����������������������������������������������������������������������������������������������������������	��v�v�w�x�x�y�z�z�{�|�|�}�}�~�������������������������������������������������������������������������������������������������������������������������������������������������������������FFEDDCCBAA@??>==<<;::988766544332110//.--,,+**)(('&&%%$##"!! ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������T�

	\��� ��������������	�
�
���������������������������������� �!�!�"�#�#�$�$�%�&�&�'�(�(�)�*�*�+�+�,�-�-�.�/�/�0�1�1�2�3�3�4�4�5�6�6�7�8�8�9�:�:�;�;�<�=�=�>�?�?�@�A�A�B�$��
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
� t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�`�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
���t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�M��
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
��t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�f�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�R �
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
��t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�t�?��
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�


~
}
}
|
|
{
z
z
y
x
x
w
v
v
����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������20
/
/
.
-
-
,
,
+
*
*
)
(
(
'
&
&
%
%
$
#
#
"
!
!
 





































	










































{��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������h�








































































































�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������







































































































���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������8







































































































b	���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������








































































































����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������








































































































���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������R�


































































 
�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	������������ �!�!�"�#�#�$�$�%�&�&�'�(�(�)�*�*�+�,�,�-�-�.�/�/�0�1�1�2�3�3�4�4�5�6�6�7�8�8�9�:�:�;�<�<�=�=�>�?�?�@�A�A�B�C�C�D�D�E�F�F�G�H�H�I�J�J�K�L�L�M�M�N�O�O�P�Q�Q�R�S�S�T�T�U�V�V�W�X�X�Y�Z�Z�[�[�����	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�			~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	
����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	g��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������G�~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	~	}	}	|	|	{	z	z	y	x	x	w	v	v	u	t	t	s	s	r	q	q	p	o	o	n	m	m	l	l	k	j	j	i	h	h	g	f	f	e	d	d	c	c	b	a	a	`	_	_	^	]	]	�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������4��																				
	
																 	�������������������������������������������������������������������� 	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�����������������������������������������������������������������������������������������������������������P�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	������������������������������������������������������������������������������������������������������������T�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�&��������������������������������������������������������������������������������������������������������V	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�" �����������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	� ������������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�����������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	��������������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�������������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�� ����������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�������������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�_��������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�]������������������������������������������������������������������������������������������������������������	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�Y�����������������������������������������������������������������������������������������������������������8�8�9�:�:�;�<�<�=�=�>�?�?�@�A�A�B�C�C�D�E�E�F�F�G�H�H�I�J�J�K�L�L�M�M�N�O�O�P�Q�Q�R�S�S�T�U�U�V�V�W�X�X�Y�Z�Z�[�\�\�]�]�^�_�_�`�a�a�b�c�c�d�e�e�f�f�g�h�h�i�j�j�k�l�l�m�m�n�o�o�p�q�q�r�s�s�t�u�u�v�v�w�x�x�y�z�z�{���������~}}|{{zzyxxwvvuttssrqqpppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppB���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppb����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������;�ppppppppppppppppppppppppppppoonmmlkkjjihhgffeddccbaa`__^]]\[[ZZYXXWVVUTTSSRQQPOONMMLKKJJIHHGFFEDDCCBAA@??G������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������� ��������������������������������������������������������������������������������������������������������������������� ����������������������������������������������������������������������������������������������������������J��������������������������������������������������������������������������������������������������������t����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������R8 �����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������6�P�i��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������[A)�������������������������������������������������������������������������������������������������������������������������������������������������������������� �!�!�"�#�#�$�%�%�&�'�'�(�(�)�*�*�+�,�,�-�.�.�/�/�0�1�1�2�3�3�4�5�5�6�7�7�8�8�9�:�:�;�<�<�=�>�>�?�?�@�A�A�B�C�C�D�E�E�F�F�G�H�H�I�J�J�K�L�L�M�N�N�O�O�P�Q�Q�R�S�S�T�U�U�V�V�W�X�X�Y�Z�Z�[�\�\�]�^�^�_�_�`�a�a�b�c�c�d�e�e�f�f�g�h�h�i�j�j�k�l�l�m�n�n�o�o�p�q�q�r�s�s�t�u�u�v�v�w�x�x�y�z�z�{�|�|�}�~�~����������������������������������������������������������������������������������������������T�'�bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb�� �������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������22110//.--,++**)(('&&%$$#""!! 

	 �����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������@ ��%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%���5 �������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������c��I�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%����� .�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������k���%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%���~�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������� �r�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�[���v�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������~}}|{{zyyxxwvvuttsrrqqpoonmmlkkjiihhgffeddcbbaa`__^]]\[[ZYYXXWVVUTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT@���i�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������-�u��TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT��N������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������7
		 �������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�I�K�LN������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������� ����3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������fd c�a�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3���  ������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������	 �3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�W�Y�Z \�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3������ ������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������XVU�S�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�3�8�<�A�E�J�N�S�W�\�`�e�i�n�r�w�{�������������������������������������������������������������
�����!�%�*�.�3�7�<�@�E�I�N�R�W�[�_�d�h�m�q�v�z������������������������������������������������������������
����� �%�)�.�2�6�;�?�D�H�M�Q�V�Z�_�c�h�l�q�u�z�~��������������������������������������������������������� ��	������$�(�-�1�6�:�?�C�H�L�Q�U�Z�^�c�g�l�p�t�y�}�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������               ��  RSRC               [remap]

importer="wav"
type="AudioStreamSample"
path="res://.import/333785__projectsu012__8-bit-failure-sound.wav-433023f0283205c449c5c14c7de07af8.sample"

[deps]

source_file="res://Sounds/333785__projectsu012__8-bit-failure-sound.wav"
dest_files=[ "res://.import/333785__projectsu012__8-bit-failure-sound.wav-433023f0283205c449c5c14c7de07af8.sample" ]

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0
         RSRC                    AudioStreamSample                                                                 
      resource_local_to_scene    resource_name    data    format 
   loop_mode    loop_begin 	   loop_end 	   mix_rate    stereo    script        
   local://1          AudioStreamSample          H&      �G�G�G�G�G~GeGOG6GGG�F�F�F�F�FnFWF:F&F
F�E�E�E�E�EvE`EGE+EE�D�D�D�D�D}DfDND3D!D�C�C�C�C�C�CtCPC?C"CC�B�B�B�B�BwB]BJB'BB�A�A�A�A�A}AeANA4AA�@�@�@�@�@�@l@S@<@#@@�?�?�?�?�?v?_?A?*??�>�>�>�>�>>b>P>1>>�=�=�=�=�=�=i=U=9=%=	=�<�<�<�<�<v<^<B<(<<�;�;�;�;�;z;g;I;6;;�:�:�:�:�:�:�ŭ��������(�E�Y�rƋƥ���������<�S�mǄǜǴ����� ��/�K�d�ȕȮ��������'�G�V�wɌɪɾ������$�<�U�lʅʜʳ����� ��-�M�d�˕˰��������.�@�\�t̪̎̾������'�:�X�j͇͛ͺ�������0�Q�e΀Δΰ��������+�D�[�yϏϩ��������$�?�S�oЄУй�������4�R�eрїѭ��������*�F�Z�yҒҦ���&--�,�,�,�,�,z,],F,-,,�+�+�+�+�+�+h+Q+4+++�*�*�*�*�*p*W*?*'*
*�)�)�)�)�)r)_)D).))�(�(�(�(�(�(h(K(5(((�'�'�'�'�'p'T'B'#''�&�&�&�&�&w&\&D&/&&�%�%�%�%�%�%c%O%2%%%�$�$�$�$�$q$T$?$"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$���������������������������������������������������������� ��� ������������������������������������������������������������������������������������������������������������� ���������������������������������� ���������������������������������������������$$$$$$$$$$	$ $$$$$$$$$	$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$����������������������������������������� ��������������������������������������������������� ��� ������������������������������������������������������������������������������������������������������������������������������� ������� $$$$$$$$$$$$$$$$$	$ $$$$$$$$$$$$$$$$$$$$$$$$$	$$$$$$$$$$ $	$$$$$$$ $
$�#	$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������ $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ $
$�#	$$$  �������������������������������������������������������������� ���������������������������������������������������������������������������������������������������������������������������������������������������$$$$$$$$$ $
$ $$$$$$$$$$$$$$$$
$�#	$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������� $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	$$$$$$$$$$$	$ $$�# $�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�#�# b�m�f�s�o�x�t�|�y܅܀܈܆܋܌ܐܕܕܛܘܢܚܨܥܪܭܭܱܼܻܳܶ��ܾ������������������������������������������������
��������"� �#�)�%�4�*�7�1�:�8�=�A�D�D�J�I�M�P�U�V�Y�[�]�f�a�l�e� �"�"�"�"�"�"�""{"w"t"r"s"i"p"d"e"c"\"a"V"\"R"R"L"P"F"I"E"A"="<"7"9"1"4"."("," ")""$"""""""
"
""" "�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!�!o�v�u�z��ބރމވގޑޔޕޘޛޜޢޣާީޫޮް޳޸޺޻޿�����������������������������������������������������������"�#�&�-�+�0�2�4�<�8�@�@�A�H�D�Q�L�R�S�V�X�\�`�a�d�g�i�mߍ � � � � � � } x { q x l q k c i _ b \ [ X S S L P E N ? D < ; < 4 8 . . , ' ( ! $          	 � ��������������������������������������k�k�q�n�v�t��z�������������������������������������������������������������������������������������
����������&�"�*�)�,�0�1�8�6�?�9�D�=�I�I�K�O�N�W�Q�\����������������|{xwrrnglae__ZWSSOMKGCA?<:76-0+)'$!
����������������������������Q�P�T�W�W�]�[�b�e�g�i�l�n�q�t�w�|�{��������������������������������������������������������������������� �����	��������"�!�$�)�'�/�,�6�5���������������������������~�|{{swplkggbc\YYRVLQIFDB>>:813,/&&!!�������������(�&�+�.�.�4�1�9�;�=�C�?�I�B�N�M�S�R�V�X�Y�`�a�d�g�h�l�m�p�x�t�}�y�����������������������������������������������������������������������������������������������������������������������{v{pqmkifcb[[WVRNLHIBF;=767,5')&!#  ������������������������������#�%�'�*�-�.�1�5�8�<�;�B�@�E�G�M�N�O�T�T�X�Z�b�]�h�a�l�h�p�q�v�u�z�{�}��������������������������;;704*0$,!
 ����������������������������������������������}}uwrpojk` ��������������������������������������������������������������
����������%�#�(�(�-�-�1�9�3�>�9�B�A�B�M�G�P�O�R�U�W�]�^�a�a�h�j�m�o�p� ����~{ywtmpglbg^\ZWUSPMIEFA?>:37-2),&!"���������������������������N�M�Q�T�U�X�Z�a�`�f�d�k�i�o�t�r�z�x�|������������������������������������������������������������������������ �����������������������������������������������y}sspnkiefZcT]RUPJKFEC>A3:220+,"& �������������������	�	��������"�&�&�,�*�/�1�9�4�?�9�B�A�D�K�J�N�P�S�T�Y�]�]�c�a�h�f�m�o�r�u�u�{�y���������������������LHBB?<;85/0),&%" ������������������������������������������������������������������������������������������������������������������ �����������!� �'�#�.�'�2�1�8�5�;�<�?�A� ���������������������{ywtrlkhgaeZ]UVTMRHGEB>?9923,/'+!"	
�����������!��&�(�)�/�,�3�4�4�@�9�D�>�G�F�I�S�K�W�S�Y�Z�\�d�b�g�i�i�o�p�u�w�z�z��}������������������������������� ./+)'##	�����������������������������������������������}~wz������������������������������������������������������������������������������%�"�)�)�+�1�.�5�8�<�:�B�@�D�H����������������������zzuuqondj^fZ[VURQMKDEAA;<540/,)($! �  ������ ��#��$�&�)�.�-�5�0�;�6�;�D�@�F�H�G�N�P�S�V�X�Z�^�`�_�m�c�o�m�n�v�r�~�z�~������������������������?:<5602(*&$ "
��������������������������������������������z�|������������������������������������������������������������������������������������$�$�,�,��������������������������������w|suqolgdd`^\XSTNNKFJ;D9<581,/%*#! �������������������������	������ � �#�)�%�.�,�4�3�9�7�>�<�B�F�G�K�L�N�W�T�Z�Z�^�^�e�g�i�l�n�p�t�t��v��{�����������jef\`XZUTPLJGEBB=7825-/(&$  
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
H�J�P�M�V�P�[�\�]�c�`�h�f�l�o�r�s�w�x�{�~���������������������������������������������������������������������������������������
 

 
�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�		~	y	t	t	q	n	m	i	e	d	_	 �������������������������������������������������������������������������������#�$�&�)�+�-�7�1�:�7�>�>�A�H�E�N�J������������������}�z{vurknej`f[ZYUSQNKGDC?><6501+,%)!
������
���������$��%�)�(�-�.�1�4�6�<�<�@�A�E�F�J�O�O�S�U�W�[�[�c�c�e�j�i�m�q�t�w�y�{�~���������������������������^WXPQMJJDF;?98621*))"$� ������������������������� M�M�U�S�[�Y�]�a�`�g�i�k�o�n�w�q�{�|�~��������������������������������������������������������������������������������� 
�����������������������������������������������y}sxns������������������������������������������������������������������������������������������ ��%�$�)�.�-�4�1�9���������������������������}{xqrojmdg]`ZZUQPMKGGB=?5>.8-). ������������������������������
���������!�%�%�*�*�.�0�7�5�;�;�@�?�E�G�L�L�O�R�S�X�[�^�^�f�b�h�j�p�o�u�s�z���|yxtonkjdg_\\WUUOPFJBE?>:561..)* "	
����������� �"�&�*�-�-�2�2�8�5�B�:�G�?�L�B�R�L�V�T�U�]�Y�a�e�b�l�f�r�k�u�v�x�}�|�������������������������������������������J;E7@390/,)(#%	��������������������������������Z�Y�^�_�b�i�h�k�n�p�s�v�z�|�������������������������������������������������������������������������������������� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � } | y x q ������������������������������������������������������������������������������������  �� �� �� �� �� �� ��   �� ��   �� ���� �� ���� �� �� �� �� ��   ��   ��   �� �� �� �� ��                                RSRC   [remap]

importer="wav"
type="AudioStreamSample"
path="res://.import/399095__plasterbrain__8bit-jump.wav-7951e9d348e798321dd2c48de59db76a.sample"

[deps]

source_file="res://Sounds/399095__plasterbrain__8bit-jump.wav"
dest_files=[ "res://.import/399095__plasterbrain__8bit-jump.wav-7951e9d348e798321dd2c48de59db76a.sample" ]

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0
       RSRC                    AudioStreamSample                                                                 
      resource_local_to_scene    resource_name    data    format 
   loop_mode    loop_begin 	   loop_end 	   mix_rate    stereo    script        
   local://1          AudioStreamSample          H�  ��#��T������>
�c����=�e�� �H�o	
�
)�O�m� v�t�s�p�n�kN�K�I�H�F��'w�j ���c����`��
�`���i���������j�U�A�+�� �������D�p���<$�(u� h�l�6ޠ��p���<����j�/
��P��l���2�N�h��	�	+
�
E�^�D��9��,~� q�c�V��B�K�T�^�g��	z�W��6��������l���Q���9������d�F�'�	�������n�N�.����������{`E(%�$y��������A�x������M����
Fv�js����*�9�G�V	�	c
�
q�y�m�V��?��'u�\���/�B�W�j�s� 	�4�J���b���|�	��&��D���d�+�Z�2�
�����i�A�������s�����c��
X��D!M&�������������"�( .158:;;�������"�%	�	'
�
*�&v�`��J��4�� n�[��Q�q � �?�Py	�7�^��������4���R���n����)�	�����R�%������s�G����_�{�4����f	$��g +&� �
����~ݛ�������7�Y�|����
;d�`k�z��%�6�H�Z	�	n
�
�� R��G��=��3��)|�!s��8�M�a�t����9	�%������f���J��+��	�x���m�V�3��������b�A�����������!$	).6=!G'�%�z�y����K����?����:���>
��K� ]�y�$�A�`�~	�	,
�
M�l���4��4��4��6��6��9������!�)3�	]�e����g����e���^�����޶ߝ���j�Q�9� ����������u����>�	�Y�"�(c(����[���W���W���Z���`�� k�	w �� ����>�h��&�P	�	z
�<�h�k�t�%~�0��;��G��R��8�8�7�6�3��9w��/ j������U�����9�q������q�b�Q�B�2�"�������������r���r��w
���$+�)Ba����U��ߧ�O����G���� ;�	�,�v!����K�z�?�l	
�
1�]��!��Q� W�^�d�j�p��/�)�"��M�
R���N������N�����P����������޵ߦ����z�j�\�L�=�.�����#����J�k�$*+�'�q���ܠ�0���O���m���� �	3�L�e c�n�*�R�z�5	�	\
�
��>�Y�	_�a�a�b�c�d��%�#�#�"�!�R��:� ��"�q����\����I����7�ݣݏ�{�h�T�@�-������������Z����^��Y%�+<$[}�)�}���p���_���N���<�� )�	��s���\�~�2�S�u	�	'
�
H�i��s�p�l�h�d�_�[����#�'��o�	&��7�����K����`���w���2�߱�c�K�2����������m�T�<�F����*�Jk����&�+��%�Pۊ���M���p���0���� N�	i�%���N�j���0�L�g	�	�
�,�G�7��/��&x�o�f�\�L���#�-�5}�
N� � ��[���.����m���A������:�� �������n�Q�3�������D����������� �&z+���ڇ����i����G�����"k�	�C��K�?�U�l���#�8	�	N
�
c�x��J��<��.~�p�a�Q���{���.�=`�s	�b�Q���@���0���!������������ߺ���v�T�2��������d�A�v�-������	�c?!�&]*�)���uۨ����=�o������0_�	��Hv��*�:�J�Y�i�y 	�	
�
�-�<�R��>��*y�f�Q��=��f�z��+�?��
�)� 4���@���M���Z���h���x�����޽ߗ�q�J�#�������`�9����������g�%���
^��!P'�(*=�Q��j܅�������
�$�>�Wp�	��������%�/�9�B�M�V	�	_
�
h�r�q�]��D��+y�_��F��,wI�a�z��8��~	�5�\��������>���f����%��O��߷ߌ�a�6�
�����[�0����������:�� x�R��")(�$�i����ٹݾ������������������	��������� �%�(�,�0	�	4
�
8�;�7��!m�O��1}�^��@��" �>�\�y�&�$&�	f�G ����)���j���O����6���{��ߔ�e�4�����t�E������S�"��a���b��b�a�]�#))KK	L���V�E�4�#�� �����������z
fQ<'[�������	�	
�
��V��5�\��9��`��<�����7�Y�|�/�R
 �Z��b����m����y�(����6�����u�@�
����j�5������`�+��������M���|
�F� t%�'�z��������c�>���������fB����R�*�%� ����	�	

�
�~�F��#l��H��%n� I��&p����D�j��"�H5�
�S�i������3����K����b����z�O�����n�7� ����]�&�����L�����P���e�z�1"�'�#L��T��'�������U�+����� �W-���XG�A�:�4�.�(�!�	�	
�
�	��L��'p�K��&n� I��$m���:�a���C�k��H	��j  ����C�����e�����?����b�`��u�<�����]�&����}�F�������F�����@�	�K�`$)�P���޼ۑ�h�=������j�@���	�kA�s�m�g�`�Z�T�N�G	�	A
�
;�4�g��B��f��A��d��?����'�N�u	�0�XV��:���^������:����_�����;���5�����O�����o�7������V���������.����!
s�e�$)/����ޥ�t�A�����x�F�����}I	��~L�\�T�K�D�;�2�*�"	�	
�
���N��'o� H��!j��A��c���v
�3�]���D��
]��Q������F����~�<����t�2���*��o�5������K�����a�'����w�5�u����6v��4t�"�'�#�����cڅ�F�����H�	�����I���
G��Dw�k�_�R�F�9�-�!	�	
�
�s�C��_��3z�N��#i��=��	�a��(�X�� �P��
�V ���|�F������j�3������U������߸�x�9����y�9����{�;����~�?����9�d����@m�!�&{(q���'�6��ޝ�R���p�&�����J  �o'��R���w�k�^�Q�E�9�,	�	 
�
�	��l��F��e��=��^��7�X�D�q	�6�c��'�}? 	��C ����E�����B�����=����w��ޜ�_�#����o�2�����C�����U��Q���� _�
�/v�%J*W#0����ع��D�����_�&�����H	��n9���/�&������y	�	r
�
j�c�\�`��<��a��=��b��?���r�1�Z���Ak<�	�b� ��;�����\����{�0����L���|�[�"��߱�x�?�����^�&����}�E�����2����D��Z�"t'(,�
���׎�d�:�������p�I�"����	�b=�� ��F�A�=�9�5�1�.	�	*
�
'�#�!�g��F��%p�O��/y�Y��:��!�G�m �&�K�k�u"	�})����/�����3����6����7����6�Jݵ��J�����t�?�
����k�6����������j�M�3�#�(P-�$O�z��j�P�6������������oX@	)���� �:�9�8�8�8�8�8	�	8
�
8�8�9�9��5��b��E��(t�V��9�����;�]���4��z	�i��V�����C����.���t���\���ރ��܏�\�*�������`�-������e�2� ��������� ��'�!2'�,�)" �����q�d�W�J�>�2�&�������
������"8�n�q�t�w�x�z�z	�	{
�
{�{�{�y�'q�O��,v�	R��/y�T��/4�V�v�&�F�g��}(
�+� ��0�����9����D����T���f�ޡ�W�#��޽ߊ�V�"�����R������K���d���w�)��/!�&�+�(�c ��=�D���߾��b�2������p�>�	�o:�� ��-�#�����u�i	�	^
�
R�F�:�'t�G��a��4z�L��c��5zY���B�m�-�X��	i0�� ��O������u�?�	����k�7��������B������N�����Y�����b�$���E����#�?�Yt	�����" (|+�	���؋�0���{����e����I����)�
f�=�t ��/��y�c�L�6�	�	
|
�
e�M�5��/q��;~�G��R��\��#f��I�}�K���O�8=
 �����n�R�5����������|�b�I�1���K���z�4����`�����F����q�)����n�L�*� ��	�qJ"�!�&�)�������[���K���8��#�������f�	I�*�wZ��c�C�!� o�M�+�		x	�	U
�
2�}�A��B��A���>}��<|��9x���x�U��2�q�O���	���������������������������z�!����4����F����V���g����v�k�J����)��f�8�l#�'9#�  ���Mܘ���-�v���M���� �e ��/
q��5u�t�H���W�*��e�7�	q	�	A
�
z�K��#_��P��@|��0l��[��> �H��5�$�l��-	E^y����������5�Q�n���������>�]��� ���o���c�
��W����J����;����,�m���'����<��Q�	e"�&�4����޶������/�M�l�������� #B`	����4H�y�D�u�@�q�<�	m	�	9
�
i�5���2n��!\��J���7s��&a���h�`	�X�P���1U	x��� *�M�q���������"�E�h��������?����$���h���Q����8���~� ���e������2���� 1�	�0��/�#^'#��z�H�������7�P�j����������4	Mf����9�h�2��`�+��Z�$��R	�	
�
�
K�s��(b��O�� ;v��(b��O��  �|$�u�p�i�_�	��� G n��������.�U�|�������=�d������U����:���|����a���F����*�F�"�p����Z��
B��,z �$'�a	��|�*��!�5�I�]�q�����������'	;Pcx���/��[�$��Q�~�G�t�<	�	
j
�
3��_��Z��
E��0k��U��@z��*5��4��/��*�}&�-r�	��Bl �������<�e�������6�`������n��N����0���p���Q����3���t���U����;�����T��'m��!@&A%�a����l�|�������������� ,;	JXgv���(��S�~�E�p�8��b�)	�	�	T
�
�G��R��;v��$^��H���1k��TF��C��@��=��;�E��	�Bo� ����$�Q�}������0�]������<�i��G����%���c���B���� ��_����=�����d���� �`��	[��W#�'U"���q�۶޿��������������
�� &/8	AKT\eox��G�p�6��_�$��M�	u	�	;
�
d�)��I���0j��Q���7r��X��@xX�X�W�V �T�q��	*\��� !�T��������M������J�}�����I��}���X����1���m�
��E������Y���H�8�g������ N
{��/[#�'#,�;�D�A�=�:�5�2�.�)�%� �����
�������J�m�.��Q�s�5��V�	x	�	9
�
�
\�}��6n��O���1h��I���*b��
B^�l�q�u!�y%�P�	�@}� ��2�o�����%�b������W�����M����J��,���`����0���d����2���g���5���p�8�P�g�~�������.D Y$(��^���H�������������p�[�F�2�����
���nXA6��R�n�-��H�e�!��=	�	�	Y
�
u�2���4k��I��$[�� 8n��K���&?��P��X�b�l�2��	a��2w����I������a����3�z����N����!�s���:���h����-���\����!��O���}����)�,�/�1�3 478:;<=> ?$�'A���X��%������y�V�3����������_;�	���b>�m�'��?��V�m�&��<��S	�	
i
�
#��8���,b��:p��H~�� V���.c��"��:��H��V�e�[�>
��'t� _�����J�����5����!�p����\����J�����y���6���_������D���m� ��)��Q�Y���������� �{jWE2 �#�'��� �����޹��X�'������c�1� ���� k9	��p>��^B��U�
e�x�-��?��P�	a	�	
r
�
(��9��T���(\���1e��9n��Bv���{,��>��Q�d�ws�
	u�!x� %�|���*�����.�����3�����9����?������C���f������>���`������6���X���{��"�������� hC����_7#'� V����+�u�7����{�<�����?������@ ��
?��~=��f�r�%�1��?��L� Z�	g	�	
u
�
*��8|��P���$Z���-c��7m��Av����[�s%��=��T�?�
w�)��3 ����;�����C�����K����Q����V���Z�i������/��O���o������@���a�������8���������oO/����"s&&0`	������x�=�����S�����m�4������ Q��q:��].��>��N�_�p�&��8��I	�	 
[
�
l�#�7l��Cy��O���']���4k��Bx�V�j�~0��C��Wc�
m�f� _����V�����M�����C����8����,�}���� ��$��G���k����"��F���k����!��G��������������{g	S@-� �$�(7#763�1���+������f�6�����u�D����� �V(	���m>��2��F��Z�n�&��:��O�	d	�	
y
�
2��H��<r��L���%\���5l��E|��V����/��A��R�c�s�e�
	O��9� ��"�o����W�����>����%�q��
�V����;���p���+��R���z���5���]������B���n������������	������!�%�)w%K����ۿږ�l�C�������x�P�)� ������c<���{T.�l�&��<��T�k�&��=��T	�	
l
�
'��?��U��7o��J���&]��9q��M���(`�j�y(��7��E��T��e
��B�� g�����B������e����>�����^����6�~�ߛ�0���[������F���p���1���\������A�+�,�,�.�/ 13469<>A E$G(;+= ��C���uطڕ�s�R�0��������h�H�'� ����fF'��� t�/��I�c�}�9��S�	m	�	)
�
�
C� _�z�9p��N���+b��	@x��V���4k����>��K��W�c�px�[	��,q� ��A������V�����%�i����7�z���G����B�p�ߞ�4���b����%��S������E���r�
��7����������� 
&/9AJ T$](L,}$�:���
� ����ީ��n�Q�5������������gI,
����{^@"!���U�o�*��D� _�x�4	�	�	N
�

g�#��=��*`��<s��N���*`��<s��N���)F �]�i�u$��0��<��c	��<�� �]�����7�����Y����3�|����U����0�x�ޘ�-���Y�������G���s�	��5���a����"��O������������ �������� �$�(�,D$���J�N٢�|�W�1�������v�P�*������� nG!	����c=��m�'��>��T�k�$��;��R	�	
h
�
!�8��O��8n��G~�� V���/e��>t��M���&Z<��K��Z	�i�x'��6-{�
	c��L� ��5������k����U����>����(�v����`����Q���y���6���^������D���l����(��P�����|�m�_�Q�B�3$
�����!�%�)�,C"4%��ؙ�k�=������U�&�������l�=� ���S$���h9
�!��^�r�)��<��O�c�	v	�	-
�
�
@��R�
e�J�� V���,a��7m��Cx��O���$Zn%��6��H��[�l�~�k
�d�
^ ���W�����P�����J����D����>����9���ޣ�ޠ�3���X���|���3���X���|���3���W���|�������������rV:����"w&[*�,� ���9�=�|�D������f�.�����O������o�6���
V��u<� ���5��E��U�
d�s�(��8	�	�	G
�
�
V�f�u� V���)_���2g��:n��Bv��J��R�c�y+��?��U�j���E
��O�Y ���d����o��� �z���+����7����B����N߼ݸ�H���i��ߊ���;���[���|���-��N���n����.������{�R�)  ���[2��"�&b*�,�!&{��(�M��כ�Z�����U�����N������H���@	��{8��r0�!���S�_�j�v�(��4��@	�	�	L
�
�
X�
c�n�U���&[���+_���/c���3h��8l��<p�i��4��K��d�|0��4�8�
�T�q� /�����N����n���/����R����u���9����_��ދ����ߜ�,��I���f������.��K���g������1��t�6�����y�8��
w6��p.!�$�(d,�'C�
��b�� �u�#���}�+����1����5�����6����6��	3��-�}&�u!���@��C��F��I��K��M��N	�	�	Q
�
�
R��R��T��%W���O���Gx��>p��5g���,]���!�r'��F��f��<��\k�S�	3���g ��J���.��������g���M��2������s���[���xޱ�:���L���]���n��������)��9���I���Y���h�X��-���]���� "�N�y�8� `$�'�+�%0�
��)�~�/�7���X���w���$��B���^���y���  �8�
Q�h�~	�9N��F��>��6��.��%w�n�	d	�		
Z
�
�
Q��F��<���Jz��7g���$T���Ap���-\���Gv��8��a��C��m&��P	�R�z�	~�������������� ���(��0��8��A���K���U���_�?ߚ����!��'��,��2��6��:��?���C���G���K���]���K��*����v�R	�-�s�K!�$"(�*� �������$٘��~���d���I��-������c���C �#�
r�O�,�u�Wo�\��I��6��#q�]��I��5	�	�	 
o
�
Z��D��,]���An���#Q~��3`���Bo���$P}��%��h$��W��F�z5��i�m 
�%�K�r ��-���T���}����:���d����#��O���z���<����������y���s���l���f���_���X���Q���I���A��:��h�����B�����_��
3y�G��!%Y(�'�T�Y���ݢ���Pߧ���U���W����W����V�����S��N	��F��>��3?��"m�P��2}�_��@��"l�	M	�	�	.
y
�
Z��:���+V���/Z���2]���
6a���8c���:e��m,��h'��c"��^��Z���'
�n�Y�� F�����3���|�!���k���\���M����?����2������Z���G��6��$���� �w���e���S���?��-��������������<�]}����;Yx�!�$�'y%������Rޑ����D�����0�j������R�������8�p��Q
���0g��
@�H��!h��A��_��7~�V��-t�	K	�	�	 
h
�
�
>��[���=f���5^���-V���%Nx���Fo���4��M��U��\��e&��H�
�	2��L��e �����4�����O����l� �����>����\����z�0�������K��/������g���K��.������e���H��*���~�Y�!�!�!�!�!�!�!  #
&)'u�+���R���V�zߞ�����	�,�O�s�������!�C�e������0
Pq����5Ut.t��D��X��(l��<��P��d��2	w	�	
E
�
�
X��&a���)Qy���Ah���/W���Fm���4\�����{?��P��a&��s7���BO�	�L��K����K������M������O�����S�����X�����_� ��I��$����l���G��!����j���D������e���@������a�D�'���������wY<�����dD"$%'���������=�L�[�k�z�����������������'�4 AO\iv
���������0$g��.q��9{��B��	L��U��_��%	f	�	�	,
o
�
�
5v��1X~���>d����#Jp���
/V|���:`���� Ek��j0���K��e,���G��b(�g3
���e1��� d�2�������g�4������j�8�����o�>�����w�E�������l���>���x���J������U��'����`���2���k���<��]�#�����r�7����H
��V��b %#�%1$�L�2����	�+�%���������������������������������	�yqh^VMC90�/o��.o��.n��-m��,l��,k��)i��(	h	�	�	&
f
�
�
$d��6[���8^����;`����=b����>c����@d]&���I��m5���Y"��}F��w
O	'����\5 ������n�E����������Y�1�
�����n�F��������^�7���F���u���?��
�o���9���h���2����a���+����Y��#��C����I�����O���S�	�W�Y�Y"�$�%���f�5���ߝ݇�p�X�A�)�����������k�S�;�#�
�������v	\D*�����x-W��O��F���={��4r��+i��!_��	U	�	�	
K
�
�
C���5X|���1Uy���	-Qt���(Mq��� #Gl����:��p:��c.���V!���J�iP/
	����hG' ��������f�E�&���������h�J�*��������r�T�5����&�o���4����Y������D���i���,����P���t���6����Y���F���g��������1�K�d�y��)�9"�$�$��C����<���z�J������Y�)������f�5������q�@� ��yG	�
�M���P��(c��M���8r��"]��G���1k��U��	A	{	�	�	+
g
�
�
R���+Np����@c����1Ux���%Gj����:\���
-���S!���W$���Y'���\*����
�	��{gT?, ������������x�d�P�;�'�������������n�Z�E�0������� �}���8����Q���k���'����?����Y���r���.����G���a�<��$��*���0���6�=�	C�J�Q�X�` �"h%)%2� 	f���1���܎�Y�$�����S������N������}�J����� zF��	xD��vC��v�-h��S��>x��(c��M���8s��#^��	I	�	�	�	4
o
�
�
 Z��-Pr���� Be����4Wy���'Jl����;^����/Qt��k9��o;	��q>��sA��wC��
�	����{gT?+ ��������������u�a�M�8�#������������~�h�S�>�)����0�r���-����H���a���z���7����P���k���'����A����\�����h���q���z� �� 
��
 �,�7�D�P!�#\&5&B��	V ���f�9�Y�'������_�,������e�3������m�<������wF���
R!���_.���nA|��-h��U��A|��-i��V��C��0	l	�	�	
Y
�
�
G���5g����9\~���	,Oq����Bd����3Vx���$Fh�������`.���f4��l:��r?��w���
�	��rbRB1" �����������������p�_�O�?�/���������������z�j�Z�J�x���p���(����>����R���g��� �|���4����J���_���u���.����������v���g�X�I�;�,���!$y&g(�!h�����9���'��ܯ�s�6�����E�	����T�����c�(�����t�7 ���H	�
�Y��i-��z?�,e��L���1k��R���8q��X��>x��$	^	�	�	
E

�
�
+e��L����:\~���'Jk����7Yz���$Gi����4Wx���#Dg{R ���Y'���`/���g5��n<	�vueV
G	8)
���� ����������p�`�Q�A�1�!����������������q�`�P�@�0� ��������>����T���i���"�~���8����M���c���x���2����H���^���,���������� v�m�
d�\�S�L�D!�#>&�(�&��
�������ܛ�a�(�����F�����d�,������[�+������ k;��	|L���^/ ��r&J���6r��#^��J���8s��$`��M���:	u	�	�	'
b
�
�
P��=x��2Tw���$Fi����9[}���*Lo����=`����,Op�����{J���U$���b2��q@���Q"����
�	��������� �������������������|�x�u�p�l�h�d�`�]�Y�T�P�M�H�D�@�<�7�3�/�+�6�8�����@����I����R���[���d���n����w���'����1����;����D��_����V���p���-���H�d�!��?��[ �"%z'�)�'���wg�W�F�5�o��ږ�H��߭�^����u�(����?����W�
���o�"�����: ��T�m
!��:��V	�q$�� #Z�� 8o��M���*b��?w��S���0g��	D	{	�	�	 
X
�
�
�
4j��F~��Aa����!Ba����!Aa����  Aa���� ?_����>^~������tE���V'���h9
��|L���_0����
�	��������� �������������������������������������������������������1�����7����=����C����J����P����U���[��
�`���f���l����q���F����7����(�y���i�		Y��I��8��& v"�$'c)�( Dn������C�m�t����l���b�
��Z���O����F�����;�����1��� '�t�i
�]�R��E��9�6F|��S���*`��7m��Cy��Q���']���4	i	�	�	

@
u
�
�
L���"X���:Yx����4Sr����-Ll����	(Gf����"Ba�����=\{������c5��{M���h:���W*���uH����
	
	$2@N\jx�� ����������������&�4�C�S�a�p��������������	��)�8�H�X�h�w���S����K����B����9����0����&�y����o����e��	�[����Q����F����=���������$�O�{�������* T�� *U���'Qz� �"�$'I)�'�S���M�����ڔ�ݫ�6���N���c���z�����/��D���Y���m�����
�� �1�D�	V�g�y��#�4�D:0b���*\���#U���M��Fx��>p��7h���/	a	�	�	�	'
Y
�
�
�
 Q���I{���4Rn�����9Vs���� >Zx����	%B_|����*Gc�����.Jg����vJ���rF���mB���h=���d9�DZp�
�	����
 6Lbx �������������)�@�U�k���������������3�I�`�v�����������)�?�U�l�����h���X����I����;����+�|����l���]����M����>����5����,����$�F�v�����6�e������ #S��	�?n���(W��!�#&>(�(Z!�V  ��U� ��S���l��ތ���:���X���w���%��B���^���y�������5�K�_�r
����)�6�A�K�Gx��<n�� 0`��� P��<k���%T���9g���	H	u	�	�	�	*
W
�
�
�
9f���Gu����0Je����7Ql�����
$?Yt�����+E`z�����2Lf�����8Sn�~V/���jB���~V/���iB���|U.��?k�
�	�Ep���Jv� ����%�P�|����� �+�W��������3�^������:�e�������A�n�������I�v������&���@�����c����<�����_����9�����[����5�~����W����0�x���	�Q����*�r���K��������t�_�I�3�� �����	�kT=&������ j"R$:&"([(�!w/��V�����:��ڥ��`޽��v���/����D����Y����l���#����6�����I�����Z �j� {�	0��A��Q�a�q�&|8d���Am���Jv���&S��0\���:g���Cp���"	N	z	�	�	 
,
Y
�
�
�

7d���Bn����	#=Wq�����(B]v�����.Hb|�����3Ni����� :Un�����&A[v�iC����\6���tN(���gA����Y2��Iw�
�		1_���Es�� ��+�Y��������=�l�������"�O�}������1�_�������>�k�������H�u������$�P�|�����e����=�����\����2�z����O����"�g����9�~���	�N�����a����/�s����A������D�������n�D������� mB��	�k@���h=���!e#9%'�(�(M"QTX]a�d�i�l�q�u�@ڏ���+�y����c����M����7����!�n��
�X�����A�����*�x��� a��K��3	�
�i�Q��9��!o�
W+$Oy���#Mx��� Kv���It���Gr���Fo���Cm���	@	k	�	�	�	
?
i
�
�
�
=g���:d��� 1Jc{�����)B[t�����	!:Sk�����2Ld}�����,D^w�����%>Vp��������oJ&���oJ&���oK&���oJ&���nJ%�?x��
"
[	��=v��X��  9�r������R�������2�k������J�����*�b����	�@�x�����W������4�l�����I����(�m����9�}����J�����Z����'�k����8�|����I�����Z����'�l����=�����V����)�o���i�J�+����������p�Q�2����
wX9����~_@ !#�$�&�(�*4' ���
Y.������ߛ��o����r����t����s����o����j���a���W�����J�����:�� �(w�a�	�
F��$k��?��	L��L� H;d���*Ry���=d���'Ou���9`����#Kq���4\����	F	l	�	�	�	
0
V
}
�
�
�
@g���*Pw���-DZq������%<Ri������5Kby����� -DZp������%;Qh�����2H_u����������nL*���^;����oM+
����_>����rP.i��G�
�	%	o�N��.x�Y� ��9������e�����H�����*�u����W�����;�����k���O����4�����f�� �M����3�����g���Q�3�p����*�h���� �^�����T�����J�����?�|����5�r����*�g�����\�����Q�����E�����9�w�����S����-���j����C���� �X��0�	k�C�}�T��*�d  "�#:%�&r(*'� ��c8������g�>�������4�\ބ߬�����#�K�s�������8�_�������$�K�r��������5�\�������� Ek���	,
Ry���7^����Ag����0V|���6[����<a����@e���� Fk��� %Ko���)Ot���	.	S	x	�	�	�	
1
V
|
�
�
�
5Y���8]�����!7Mbx������$9Oey������!6K_t������-AVj~������!5I^r������)=Qfz�tU6����z[<�����bB#����iJ*����qQ3���q�(��
7
�	�F��W�g�x�.� ��?�����Q����c����v���-�����A�����U����i���!�~���6����K����a���w���1����G���^���v���:�?�w����"�Z�����<�u�����V���� �8�p�����R������3�k�����M�����-�f�����F�����'�_����	�A�y���;��3��+���"���������	�|�t�	j�a�X�O�E�<�3�) �!#�$&�'{($a�X��P�����I����]���������.�>�P�a�r���������������,�<�N�^�o����������������� &6FWgw���	�
����
+;K[l{��������Ac����3Ux���%Gj����:\���
-Pt���&Jm����Ae����	9	]	�	�	�	�	
0
T
w
�
�
�
(Kn����@Wk������"7L`t������*>Rgz������-BVi}������-@Sfz�������"5GYl������|`C(����cF+�����fJ.�����jM2�����nQ6�%��
d
�	8	�x�L�!��a�6�u ��J��� �����a���6����v���L���!�����b���8����y���O��%����g���=�������U���,���m���E������]���x�����D�y�����G�|�����K�~�����N������P������R�����!�U�����#�W�����%�X������'�Z������'�[������W���f����t���)�����5 ��A��L�	�
V�_�h�o�v�${ �!)#�$�%�&#���{Z	:���������a��܁�x�n�d�Z�P�G�<�2�'����������������������z�n�c�X�M�B�6�+� ��	���� ���������	|
qeYNA5)����������� @_}����8Wv����0Oo����	(Ge����  >^|����6Ut����.Lk����	$	C	a	�	�	�	�	�	
:
X
w
�
�
�
�
0Nn������+=O`r������� %6HYk}�������/ASdv�������(9K\n�������� 1CTgy�����������fK/�����oS8����{aF,�����sY>%
�����]�S�
;
�	$	���k�T�>�'��� p ��Z���E���0�������{���f���Q���<���(�������w���b���O���<��)�����z���g���U���B��1��������s�����.�^������L�|����
�;�j������)�Y������F�u�����3�b������ �P������<�k������(�W������C�r������0�_��� �=�{����1�n�����"�]����� K���7r��	 Z��	B|��)b��H���,!d"�#�$>"��&t�
^����L����<���ޣ߅�h�J�,��������x�Z�;�����������g�H�)�
���������o�P�1����������t�U�5 ����vV5��	�
�tT3����nN,����eD���	&B_{����	%A^z����#@\y����">Zv����;Wt���� 8Tp�����4Ql�����	5	R	n	�	�	�	�	�	
6
S
p
�
�
�
�
�
'8HXiz��������->N^o�������!1ARbr��������"1AQap���������,<KZiy������~fN6�����{dM6�����}gO9!������jS<%������)�
7
�	E	�S�`�o�}��"�1�?� O ��^���m���}�������$���4���E���U���f���v�������� ���1��C���S���e���v� ����$���5��G���Y���l��������9�B�m�������?�j������;�f������7�a�����	�3�]������.�X�������(�R�|������"�L�v��������E�n�������>�g�����S�c�w�������������*�>�Q�d�w �������
	
.@Qbt��������	)9HWfv �!@ ,������������w�i�\�O��J�����X�����e�(����p�3����{�>� �����G�
����P������X������_� �����e�'���� k,��o0��s3��	v
7��x8��y9��z:��x9��n����2Jc{�����&>Vn����� 1Ibz�����#;Sl������-F^v�����7Of�����'>Wo������	/	F	^	v	�	�	�	�	�	


*
8
E
S
`
n
|
�
�
�
�
�
�
�
�
�
 .<IWer����������$1?M[iv����������'4AO]iw����������-9FST?+ ������p[F2������ydO:&�������nYE0�
�
�
�
�
�
f
�	�	'	�P�y�7�a�� �I�t	�4� ^ �������J���u����7���b�����%���Q���~����A���n����2���_����%��S������G���v���<���k���2���a����*���Z����{�������5�Y�~�������6�[��������8�\��������7�\��������7�[���������6�[��������5�Y�}�������3�W�|�������2�U�������������v�h�[�L�>�1�#�� � ��������w	h
YK;-���������tdUE5$�z�B�q	�<���n���;��	�q�H����Q����[�	��c���l����t�!���{�)����/����7�����=�����C�����H�����M�����R���� V�Z�^
�`�d	
�
f�h�r!��/��=��J�������$;Qg~�����0E\r������"9Nez������*@Vl������/DZo������/EZo������+?Ti|������			%	1	<	G	S	]	h	t		�	�	�	�	�	�	�	�	�	�	�	


&
2
<
H
S
^
i
t

�
�
�
�
�
�
�
�
�
�
�
%0<FQ\gs}�����������"-8CNXdoy������������	�������|jYG6# �������sbP?-
�
�
�
�
�
�
�
}
l
Z
H
6
%


�	�	�	�	�	�	|	'	�m�Y��C��/�w�c�O��<� � * ��s����`����N�����>�����,���w����f����W�����G�����7�����(���t����f���X����K����>����1���~�%���r����f���[���������#�C�b��������!�A�`���������=�\�|���������8�W�w��������4�S�s��������.�N�m��������	�(�G�f��������"�A�a�����r�C��������T�#�������c�3������p @��}L���X	(
�
��d2��m<��vD��~M�}dL3�������s�\�E�-�� ����E���o���-���X������?���h����&��O���x����5���^��������D���l� ���(���Q���y� � 4�\���?�f��"�J	�	q
�,�T�|�7�`���C�L_r�������,?Qcv�������)<N_q������� #5GXk}�������
.@Qct�������%6HZl}�������	,>Pas��������!3ET_is}�������������
			'	2	;	E	O	Y	c	m	w	�	�	�	�	�	�	�	�	�	�	�	�	�	



)
3
=
G
Q
[
e
n
x
�
�
�
�
�
�
�
�
�
�
�
�
�
)2=GPZcmw�����������������������scSD4$�
�
�
�
�
�
�
�
{
l
\
L
=
-


�	�	�	�	�	�	�	�	�	u	e	V	F	7	(				����z)��4��?��I��U�a�k�w&� � 1 ����=�����I�����U����b����n����z�)�����6�����C�����P�����]����j����w�&����4����B����O����^���l����z�)����7����F�9�U�r�������� �>�[�x��������
�&�C�a�}��������,�I�e���������0�M�i�����������4�P�n����������7�T�q������� ��8�U�r���"�����]������S������D����x�3���� c��H�o%��E	�	�
_�t&��5��?��D��I��L���B���[
�3� x���R���,���t����'�� ���������}���u���m���d���[���T���J���B���9���0���'�������������}���s���i���_���V � K�@�7�,�!��� {�p	�	e
�
Z�N�B�6�+�����tOGVfu�������� 0?O_n~��������	'6FUdt���������,<JZiy�������� />M]l{��������"0@N^m{��������!0?N]l{�������������!*3;CLU]fow���������������			!	)	2	;	C	L	T	]	e	m	v	~	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	



'
0
8
@
I
R
Z
c
k
s
{
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
t
f
X
K
=
0
#


�	�	�	�	�	�	�	�	�	�	s	f	X	K	=	/	"			����������tfYL>0#��]��A��l&��Q�~7��c��I� u / ����[������@�����m�'�����S�����9�����f� �����O�
�����<�����o�+�����`������T�����I�����?����w�4����m�+����c�!����Z�����R�������)�A�Y�p�����������,�D�[�r�����������-�D�\�s������������-�E�\�t�����������-�D�[�r�����������+�A�Y�o�����������'�>�T�l��������6���h����2���b�����+���[�����"���R���� �G�u�:�h��,�Y	�	�
�I�u
�6�a��"�M�x�8�b4��P�	�W� ��`�#�����l�/��������N��'����k���D������`���7���{���R��*����m���D��������]���4���
�v���M���#�����e���:����|���R � '��h�=�}�R�'��g�<�	z	�	P
�
$��b�6�
u�I���Z�,9GTbo}���������,:GTan|���������-;HUcq~���������"0>KYgt����������$1?LZgt����������"0=JXdq���������� %,4;CJQX_gmu{������������������� '-5;BIPW]dkqy��������������������				!	(	/	6	<	C	I	P	V	^	e	k	r	y		�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	v	k	`	U	J	?	4	)				������������yncYMC8-!�����������~ti^SH<��i/���L��i0���N��l4���R� � q 9  ����Y� �����y�A�	�����a�)�������K������m�6�������X� �����{�C������f�/�������R������w�@�	�����e�.������S�����y�B�����h�2������W�!����~�H��������	��0�C�W�k�~������������.�B�U�h�|������������+�>�R�f�y������������(�;�O�b�u�������������#�7�I�\�p��������������
��1�D�W�j�}��������������S���S���Q���O���N���L���I���H���E���C���@ � =�:�7�3�0�,�(�$�	�	
�
�����z�t�n�i�b�Ig����
�5Rq���������$�B�`�~���M����^���n���"�{���-����7����?����E�����H�����L�����O�����Q�����S�����V����W����X����Y����X����X��� X � V��T��R��M��I��D��>��7��/	�	�	'
y
�
o�e�	Z��N��A�
� $.9DNXcmw�������������$/8BLW`kt������������ 
'0:DNWaku�������������"+5?HQ[enw�������������� )2<EOXaks|�������������������	"'+15;@DINSW]aglpuz�������������������������� 	 $).37<AEJNSX\`einrw|����������������������������������������xof\TJA8/&	��������������ypg^ULD:1) �����������j@���pG���|T,���g?���{T-� � � k E  ��������]�7��������w�P�*��������l�G� ���������d�?����������^�8��������~�Z�4��������|�X�3��������|�W�3��������}�Y�5����������]�9����������c�@���������k�H�%��������!�/�=�K�Z�h�v��������������������!�0�=�L�Z�g�v����������������������+�9�G�T�b�p�}���������������������!�/�<�J�X�e�s����������������������� �-�:�G�U�a�o�|���������������(�z����n����b����U�����G�����8�����(�w��� e � S��?��*x�c��M��5��j�Q��6	�	�	
g
�
�
J��-y�Z��;�E��
�	�Y3���x S�0����������`�?����	��R������2�k������J�������)�a������>�u������Q�������,�b������<�r������J������!�V�������+�a����� �5�j������<�q����� B v � � Fz��H{��I|��H{��Dw��@r��9k���1c���(	Y	�	�	�	
�� � � � � � � � � � � � � � � #)/4;AFMRX^djpu{�����������������������"(-38=CHNSY^dhmsx}�������������������������!'+15:?DINSX\bgkptz����������������������������������������������� 	!#%')+-/1468:<>@CDGHJLOPSTWYZ]_`cefijmnpstvxz|~�������������������������������������������}wrmgc^YSNHD?94/*$ �������������������������zvplfb]XSNID<&������s]F0������jU?*� � � � � � ~ i S ? )    ������������n�Z�F�1��	�������������}�j�W�C�/�����������������s�`�N�;�)�����������������y�h�W�F�4�$�����������������z�j�Y�H�8�'�������������������u�d�T�E�4�%�������������������������������������������������������"�*�2�9�A�H�P�W�^�e�m�t�|�����������������������������������������!�(�/�6�=�D�K�R�Y�`�f�n�t�{��������������������������������������������#�*�0�6�=�C�J�P�W�]�c�l����������@�d����������;�_����������2�U�w������� $ F h � � � � 2Tv����<\}����>_~����;Zy����3Qo����$A_}����P�Y�f�r��	�� + ��>���S���h��������%���?���1�I�a�y�������������4�K�c�z�������������0�G�]�t��������������$�9�P�e�{��������������%�;�O�d�y�������������
��2�F�Z�o���������������   4 H [ n � � � � � � � ,>Pcv�������*<N_q��������->N_p���������B E F I K M O Q S U W Y [ ^ _ b c f g i l m o q s u w x { } ~ � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �  	 !"#$$%&''()(())))))*)***)***+****+**+*+**+**+**++*******)**)*)))))))()((((((((''''&&&&&&%%%%$$$#$$##"""!!!!!   

		 � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �  ~ z v r p l i f c _ \ Y V R P L J G D A > ; 8 6 4 1 . , ) ' $ "                  ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������         RSRC   [remap]

importer="wav"
type="AudioStreamSample"
path="res://.import/404743__owlstorm__retro-video-game-sfx-fail.wav-ae66269e972d5e46c4213aea1b2d91a0.sample"

[deps]

source_file="res://Sounds/404743__owlstorm__retro-video-game-sfx-fail.wav"
dest_files=[ "res://.import/404743__owlstorm__retro-video-game-sfx-fail.wav-ae66269e972d5e46c4213aea1b2d91a0.sample" ]

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0
   [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
                  �  `FFTMc�% B   GDEF^ $ A�   (OS/2�Y��  h   `cmap�+��  0  �cvt  "�  	�   gasp��  A�   glyf�6�  \  �Lhead���   �   6hhea  $   $hmtx>�2   �  floca���  	�  `maxpv s  H    namev���  ��  7post���� 2�  7      �:�_<�      ̶%�    ̶%�                                                 / p             @        �  ��   ���  � 3	         � �P `J        PfEd �  �        `  �             �           �           �   � � �      �                  � �   �                     �     �               �         �      � �  �           �     � �   �           �   �   �         � �   �        � �� � �   �   � �   �  �  �   �    �                                   � � � �               �           �   �                         � � � �               �                                                                                                 � � � � � � � � � �       �       �   � � �   �     �                                     �   �   �                 � � � � � �                             �   �            � � � � ��� � �� �  � �� �� �                      �           �                   � �         � �       �                   �                     �                           �     � �                       �                             �                                 �                             �                                 �     � � �                        � �   � �       �         �                     �                       �       � �                      �      �   d @  $ ����z~����_    " & 0 : D � �!!"!�"""""""+"H"`"e%�%�%�%�%�&&`&c&f&j������     �����z~����       & 0 9 D � �!!"!�"""""""+"H"`"d%�%�%�%�%�&&`&c&e&j� ������������~�}�r�������������������������������_�]�����������������߻߸�l�i�d�a�X�������ۿ*	-,                                                                                                      
                                                                       	 
                        ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a b � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � s e f j y � q l w k � � t h x� m }t � � � d oC n ~ c � � ��� �� �" �;
	-. z� � � � � � � � � � � �, � � � � �DN rJKL {OME   "�   2 2 2 2 P l ����L�����.t��X�� P���*j��(^���\~��	
	"	T	�	�	�
$
`
�
�
�P�� `|����*Nx��
.X���  Lv���<d���N`�����F��&~�4���4Fp���
6z����L�$��(r�l��H���6h��H��J��$n��  T � �!!F!�!�"""j"�"�#,#n#�#�$:$j$�$�%%T%�%�&&L&�&�&�'>'r'�'�((R(�(�))H)�)�*0*|*�++Z+�+�,,d,�,�-"-f-�-�..J.�.�//B/�/�00V0�0�1.1d1�1�222h2�2�2�3<3|3�3�44>4x4�4�55@5�5�5�6>6�6�6�77:7j7�7�7�8
808^8�8�9
9:9�9�9�::F:�:�:�;B;�;�<
<F<�<�==@=�=�>>X>�>�?4?z?�@@>@l@�@�@�A.ArA�A�BBNB�B�C&ChC�C�DD`D�D�E,EjE�E�F*FfF�F�GGHGjG�G�G�G�G�HHH@HbH�H�H�H�II:I�I�I�I�J*JjJ�J�K:KxK�K�K�L$L`L�L�L�M"MXM�M�M�NN2N\N�N�N�O.O~O�PP:PxP�P�Q.Q\Q�Q�RRHR�R�SS.S�S�S�TTJTzT�T�UULU�U�U�V
VJV�V�W
W<W�W�X XNX�X�X�Y YnY�Y�ZZ2ZlZ�Z�[[Z[�[�\\4\j\�\�\�]4]v]�]�^0^`^�^�^�_ _*_n_�_�``R`v`�`�`�aaJata�a�b:bnb�b�b�c0cbc�c�d
dVd�d�d�e
e6eRe|e�e�e�f,f\f�f�f�f�g"gRgzg�g�h hbh�h�i
iDizi�i�jj:jrj�j�k4k|k�k�k�k�k�l
l$lNlxl�l�l�mm>m�m�n$nfn�ooTozo�o�ppHp�p�p�q.qVq�q�rr\r�r�s s(sRs|s�t(tzt�t�u ubu�u�u�v@vrv�  � ��      ))5);+;5+;��������� � ������� @@@@@��@�@@�@@@@@@�@@@     ��     %5;+;++ ������@@���@@@@@����  ��      5;+%5;+ ����������@�������       ��  7 ?  5;;=;;+;++=++=+=;=+=;5+;���@@��@@@@@@@@��@@��@@@@@@@@�@@@@�@@@@@@@@@��@@@@@@@@@@@@��@@�����       ��  7 ? G  5;;+;;+++=+=;=+=+=;=;5+;5+;�@@������@@@@��@@������@@@@��@@@@ @@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@�@@@     ��    O _ g  5;++=;5+;5;+++++++=;=;=;=;=;=;%5;++=;5+;���@@��@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@����@@��@@�@@@@�@��@@��@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@��@@��@@@@      ��  3 ; G  5;;+;;=;+;)=+=;=+=;5+;5+;=+���@@@@@@@@@@@@@@����@@@@@@@@ @@@@@@��@@�@@@��@@@@@@@@@@@@@@��@@�������@��@@  �     5;+ ����@���      �   '  5;++;;+=+=+=;=; ��@@@@@@@@��@@@@@@@@�@@@@@��@@@@@@@@��@@     � ��  '  5;;;+++=;=;=+=+���@@@@@@@@��@@@@@@@@�@@@@@��@@@@@@@@��@@    �� 7  5;;=;+;+;+=++=;=+=;=+���@@��@@����@@��@@��@@����@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  � ��   5;;++=+=;������������� ���@@����@@     �   �   5;++=; ��@@��@@ ���@@@@     � ��   5))�������@@@@   � �   5;+ ���� ���       ��  7  5;+++++++=;=;=;=;=;=; @@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@       ��  ' 7  5;;;+++=+=+=;=;5+;;+ ��@@@@@@@@��@@@@@@@@ ��@@��@@�@@@@@��@@@@@@@@��@@@@� � @@       � ��    5;;)=;+=;�����������@@@@�@����@@@@  @@     ��  7  5);+++))=;=;=;=;=++=;�@@@@@@@@��  �@�@@@@@��@@����@@�@@@��@@@@@@@@��@@@@@@@@@@@@      ��  7  5)++;;+)=+=;;=+=;=;=+���@@@@@@@@@@����@@������@@@@���@@@@@@@@@��@@@@@@@@��@@@@@@    ��   +  5;;++=)=;=;=;5++;���@@@@��� � @@@@@@�@@@@���@� � @@������@@@@� �@@@@       ��  '  5)));+)=+=;;=)��� �   @@@@����@@��������@�@@@@@@��@@@@@@@@��       ��  ' /  5)++);+)=+;=;5+;   ��@@  @@@@����@@@@@@������@@@@@@@@@��@@@@  @@� ���      ��  '  5)++++=;=;=;=++��@@@@@@��@@@@@@��������@@@@����@@@@@@@@       ��  ' 3 ?  5);+;+)=+=;=+=;5+;;5+)=+�  @@@@��@@����@@@@@@@@ ��@@��� ��  ���@@@��@@��@@@@��@@����@@@@�@��@@      ��  ' /  5);++)=;=;=)=+=;5+;�@@@@@@@@� � ��@@� � @@@@ �����@@@� � @@@@@@@@@@@@������    �    5;+5;+ ������������ ���  � � �    5;++=;5;+ ��@@��@@��������@@@@ ���  � �   7  5;+++;;;+=+=+=+=;=;=; ��@@@@@@@@@@@@��@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@      ��     5))5))���@�@���@�@�@@@@@@@    � �   7  5;;;;++++=;=;=;=+=+=+���@@@@@@@@@@@@��@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@    ��   /  %5;+5);+++=;=;=++=; �����@@@@@@@@����@@����@@�@@@@@@@��@@@@@@@@@@@@��      ��  ' /  5);)=;;=)))=+;5+;�@@@@������@@����@@����@@@@�@@@@�@@@� � ����������@@@@@@��@@@       ��   /  5;;;+=++;=;5++;=+ ��@@@@������@@@@ @@@@��@@�@@@@@��������@@@@@@@@����       ��    '  );+;+)5+;5+;��@@@@@@@@�������������@�@@��@@��@@����� ���    ��  7  5);+=++;;=;+)=+=+=;=;   @@����@@@@����@@� � @@@@@@@@�@@@@@@@@@��@@@@@@@@@@@@��@@       ��   '  );;++)5+;=;=+@@@@@@@@@@���� ����@@@@@�@@@@��@@@@�@����@@��     ��    ))))))������  � � @@�@�@@�@@��@@��@@    ��    ))))+������  � � ��@�@@��@@��    ��  /  5))+;;=+=;)=+=+=;=; @@� � @@@@��@@������@@@@@@@@�@@@@@��@@��@@� � @@@@��@@       ��    ;;=;+=++������������@������@�@����    � ��    5)+;)=;+����������������@@@����@@@@@@    ��    ;+)=+=;;���@@����@@����������@@@@@@@@      ��  ;  ;;=;=;=;+++;;;+=+=++��@@@@@@��@@@@@@@@@@@@��@@@@��@���@@@@@@@@@@@@@@@@@@@@@@@@��  � ��    ;))���  ����@�����@@     ��  '  ;;;=;=;+=++=++��@@@@@@����@@@@@@��@�@@@@@@@@�@�@��@@@@��      ��  '  ;;;;=;+=+=+=++��@@@@@@����@@@@@@��@�@@@@@@���@�@@@@@@@��      ��     5);+)=+;+;�@@@@@@����@@@@ �����@@@����@@@@@@��@����    ��     );+)+5+;��@@@@� � �������@�@@��@@��@���       ��  # 3  5);+;+=+)=+;5+;=+=;�@@@@@@@@@@@@� � @@@@ ����@@���@@@� � @@@@@@@@@@@@������@@@@      ��  # /  );+;;+=+=++5+;=;��@@��@@@@��@@@@�������@@@�@@��@@@@@@@@@@������@@     ��  7  5);+=+);+)=+=;;=)=+=;�  @@����  @@@@����@@����� � @@@@�@@@@@@@��@@��@@@@@@@@��@@��  � ��    5)+++����������@@@������      ��    ;;;+)=+������@@����@@������������@@@@    ��  /  ;;;=;=;++++=+=+=+��@@@@@@��@@@@@@@@@@@@@@  ��@@@@��� � @@@@@@@@@@@@      ��  '  ;;=;;=;+=+=+++��@@@@@@����@@@@@@��@���@@@@���@�@@@@@@@@@      ��  G  5;;;=;=;++;;+=+=+++=;=;=+=+��@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@��@@@@@@   � ��    5;;=;+++=+=+�������@@@@��@@@@@�������@@����@@    ��  /  5)++++))=;=;=;=;=)��@@@@@@@@  �@�@@@@@@@@@� � �@��@@@@@@@@@@��@@@@@@@@    �     )+;)   ����� � @�@@����@@    ��  7  5;;;;;;;+=+=+=+=+=+=+@@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@   � ��    5))=;+�  � � �����@�@�@@@@@  �      5;;+=++=; ��@@��@@��@@�@@@@@@@@@@@        � �   =))���@�@@@@@   � �    5;;+=+�@@@@@@@@�@@@@@@@       ��   #  5);)=+=;=)=)5+;�@@@@����@@@@  � �  �����@@@� � @@@@@@@@��@@@     ��     ;);+)=+%5+;��  @@@@����@@���������@@��@@@@����    ��    5))))=+=;�������@@����@@@@�@@@��@@@@��    ��     5;)=+=;=)5+;�������@@@@  �������@�@@@��@@�����      ��   #  5);)))=+=;5+;�@@@@����  ����@@@@ �����@@@��@@@@@@��@@@@  � ��    5;+;+++=;=; ��������������@@�@@@@@@@� �   @@@@        �   #  5)+)=)=)=+=;5+;���@@����  � � @@@@ �����@����@@@@@@@@������      ��    ;);+++��  @@������@���@@� �   � �   � ��     5;;)=;=+5;+ ����������@@������@� � @@@@��@@@@     �        5;+)=;+5;+���@@� � ��@@������@����@@@@  @@@@     ��  +  ;;=;++;;+=+=++������@@@@@@@@��@@@@��@���@@@@@@@@@@@@@@@@��  � ��    5;;)=;+ ����������@@�@����@@@@@@     ��    );+++++��@@��@@��@@@@�@@@� �   � �   � �     ��    );+++��@@�������@@@� �   � �     ��     5);+)=+=;5+;�@@@@@@����@@@@ �����@@@��@@@@������     �     );+)+5+;��@@@@� � ���������@@��@@�� ���        �     5)+=)=+=;5+;������ � @@@@ �����@������@@������    � ��    ;;=;+++���@@����@@���@@@@@@@@@��       ��  '  5)));+)=)=)=+=;�@@� �   @@@@����@@� � @@@@�@@@@@@@@@@@@@@@@@@@  � ��    5;;+++=;�����������������@@� �   @@       ��    ;;;)=+����������@@  � �   ����@@  � ��    5;;=;+++=+=+�������@@@@��@@@@@�������@@@@@@@@    ��    ;;;;;)=+@@@@��@@������@@  � �   � �   ����@@    ��  '  5;;=;+;+=++=;=+����������������������@@@@��@@��@@@@��@@      �    5;;=;+)=)=)=+������@@����  � � @@@���������@@@@@@@@     ��  '  5)+++;)=;=;=;=+��@@@@@@���@�@@@@@@@���@@@@@@@@@@@@@@@@@@@    �   '  5;++;;+=+=+=;=; ��@@@@@@@@��@@@@@@@@�@@@��@@��@@@@��@@��    � ��    ;+�����@��@�@  � ��  '  5;;;+++=;=;=+=+���@@@@@@@@��@@@@@@@@�@@@��@@��@@@@��@@��   ��  '  5;;;=;++=+=++=;���@@@@@@@@��@@@@@@@@�@@@@@@@@@@@@@@@@@@@  � � �    5;+%5;+ ���������� �������      ��     5;+=;5;+�����@@�������������@@@      ��  7 ?  5;;;+=+;=;+++=+=+=;=;5+;�@@��@@��@@@@��@@��@@��@@@@��@@@@�@@@@@@@@@��@@@@@@@@@@@@��@@�����    ��  /  5);+=+;+))=;=+=;=;   @@��������  �@�@@@@@@@@@�@@@@@@@��@@��@@@@��@@��   � �� 7 ?  5;;=;;=;+;+=++=++=;=+5+;�@@@@��@@@@@@@@@@@@��@@@@@@@@ ����@@@@@@@@@@@@��@@@@@@@@@@@@������  � ��  7  5;;=;+;+;++=+=;=+=;=+�������@@@@��������������@@@@��������@@@@@@@@@@@@@@@@@@@@ � ��     5;+5;+���������@�������  � ��  / 7 ? G  5);+;;+)=+=;=+=+=;5+;5+;5+;   @@��@@@@@@� � @@��@@@@@@��������������@@@@@@@@@��@@@@@@@@@@��@@@@�@@@�@@@     ��      5;+%5;+ �����������@@@@@@@            ? W  5;+;+=+=;5);;++)=+=+;=;5)+;)=;+���������@@@@�  @@@@@@@@� � @@@@@@@@ � � @@@@  @@@@�@@@��@@@@��@@@@@@� � @@@@@@@@  @@@@@@� � @@@@       �       5);)=+=;=+5+;�  @@� � @@@@@@�@@@@�@@@��@@@@@@�@@@    �� 7 O  5;;=;++;;+=++=+=+=;=;5++;;=+=; ��@@��@@@@@@@@��@@��@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     ���    5)+=)������ � �@����  � ��   5))�������@@@@         # K c  ;;+;+=++5+;5);;++)=+=+;=;5)+;)=;+ ��@@@@@@@@��@@�������  @@@@@@@@� � @@@@@@@@ � � @@@@  @@@@  @@@@@@@@@@@@@@@@�@@@@@� � @@@@@@@@  @@@@@@� � @@@@    ��     5))�@@�����@@@  ��     5;;++=+=;5+;�@@@@@@@@@@@@�@@@@�@@@@@@@@@@@@@@@  � ��     75))5;;++=+=;������� �������������@@@ ���@@����@@        5;;+;)=;=;=+ ��@@@@@@� � @@@@���@@@@@@@@@@@@@@@         5)+;++=;=+=+   @@@@@@����@@@@�@@@@@@@@@@@@@@@  � �    5;++=; @@@@@@@@�@@@@@@@        �    ;;;;+=+++������@@��@@������� �   � � @@@@@@@@    � ��   + 3  5)+=++=+=+=;5++;;%5+; @@@@@@@@��@@@@ @@@@@@@@ @@@@�@�@�@������@@����@@@@@@����     � �   5;+ ���� ���       �    %5;++=; @@@@�����@@@@@@@        5;;)=;=+=;���@@� � @@@@@@�@��@@@@@@@@   �       5;;++=+=;5+; ��@@@@��@@@@ @@@@�@@@��@@@@������       �� 7 O  5;;=;;;+++=++=;=;=+=+5+;+;=;=+��@@��@@@@@@@@��@@��@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��   [  5;+=+=;=;5;;=;=;=;=;+++++++=;=;=+=+=; @@@@��@@@@��@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@� � @@@@@@�@� � @@@@@@@@@@@@@@@@@@@@@@@@@@@@��@@      ��  c  5;;=;=;=;=;++;+;+=;=;=+=+++++=;=;=+=+=;�@@@@@@@@@@@@@@@@��@@@@��@@@@@@@@@@@@@@@@@@@@@@@@@@�@� � @@@@@@@@@@@@@@��@@@@@@@@@@@@@@@@@@@@@@@@@@��@@      ��   c k  5;+=+=;=;5;+;;=;=;=;+++++++=;=;=+=;=+=+5+; @@@@��@@@@� ��@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@����@@@@�@@@@@@� � @@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@��@@@       ��  ' /  5;++;=;+)=+=;=;5;+ ����@@����@@����@@@@@@�����@@@@@@@@@��@@@@��@@@@@@      ��  / ?  5;;;;;+=++=;=;=;=+5++;=+ @@@@@@@@@@������@@@@@@@@ @@@@��@@�@@@@@@@@@��@@@@��@@@@@@��@@@@@@@      ��  / ?  5;+;;;+=++=;=;=;=;5++;=+ @@@@@@@@@@������@@@@@@@@@@@@��@@�@@@@@@@@@��@@@@��@@@@@@��@@@@@@@    ��  / 7 G  5;;+;;+=++=;=;=+=;5+;5++;=+ ��@@@@@@@@������@@@@@@@@ @@@@@@@@��@@�@@@@@@@@@��@@@@��@@@@@@@@@@�@@@@@@@     ��  3 ; K  5;;=;+;;+=++=;=;=+=;5+;5++;=+ ��@@@@@@@@@@������@@@@@@@@�@@@@�@@@@��@@�@@@@@@@��@@��@@@@��@@@@@@@@@@�@@@@@@@     ��   / 7 ?  5;;;+=++=;=;5++;=+5;+%5;+ ��@@@@������@@@@ @@@@��@@�����������@@@@@��@@@@��@@@@@@@@@@�@@@@@@@    ��  ' / ?  5;;;;+=++=;=;=;5+;5++;=+�@@@@@@@@������@@@@@@�@@@@@@@@��@@�@@@��@@��@@@@��@@��@@@@�@@@@@@@      ��  ' /  5)+;+;)=++;=;5+; @@��������� � @@��@@@@�@@@@�@@@��@@��@@����@@@@� ���      �  G  5);+=++;;=;++++=;=+=+=+=;=;   @@����@@@@����@@@@@@������@@@@@@@@�@@@@@@@@@��@@@@@@@@@@@@@@@@@@@@��@@     ��  '  5;;;)))));=+ @@@@������  � � @@�@�@��@@�@@@@@@@@@@@@@@@@@@@       ��  '  5;+;)))));=; @@@@������  � � @@�@�@��@@�@@@@@@@@@@@@@@@@@@@       ��  ' /  5;;;)))));=;5+; ��@@@@����  � � @@�@�@@@@@ @@@@�@@@@@@@@@@@@@@@@@@@@@@@       ��    '  ))))))5;+%5;+������  � � @@�@�@ �����������@@@@@@@@@@@@@@@@@@@     � ��  '  5;;;+;)=;=+=;=+�@@@@����������������@@�@@@@@@@��@@@@��@@@@   � ��  '  5;+;+;)=;=+=;=; @@@@����������������@@�@@@@@@@��@@@@��@@@@   � ��  '  5;;;+;)=;=+=;=;���@@@@������������@@@@�@@@@@@@��@@@@��@@@@   � ��    '  5)+;)=;=+5;+%5;+��������������� ����� �����@@@��@@@@��@@@@@@@@       ��   7  5);;++)=+=;%5+;+;=;=+�  @@@@@@@@� � @@@@�@@@@@@@@@@@@@�@@@@��@@@@��@@�@��@@��@@��    ��  + ?  5;;=;+;+=+=++;=;5+;;;=+ ��@@@@@@����@@@@��@@@@�@@@@@@@@���@@@@@@@@@����@@@@��@@@@@@@@@@@@��    ��  ' /  5;;;;+)=+=;=;=+5+; @@@@��@@@@����@@@@��@@������@@@@@@@��@@@@��@@@@�@���    ��  ' /  5;+;;+)=+=;=;=;5+; @@@@��@@@@����@@@@��@@������@@@@@@@��@@@@��@@@@�@���     ��   ' /  5;;;+)=+=;=;5+;5+; ��@@@@@@����@@@@@@ @@@@������@@@����@@@@����@@@@�����     ��  + 3 ;  5;;=;+;;+)=+=;=;5+;5+; ��@@@@@@@@@@@@����@@@@@@�@@@@ �����@@@@@@@@@@@��@@@@����@@@@�����     ��    ' /  5);+)=+=;5+;5;+%5;+�@@@@@@����@@@@ ����������������@@@��@@@@�������@@@@@@@  �  � G  5;;;=;=;++;;+=+=+++=;=;=+=+�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ��    7  5;+5);+)=+;5+;+;=+=;�@@@@� @@@@@@����@@@@ ��@@@@��@@@@@@@@�@@@����@@@@@@@@��@@@@��@@      ��   '  ;;;+)=+5;;+=+������@@����@@ @@@@@@@@  � �   � � @@@@�@@@@@@@       ��   '  ;;;+)=+5;++=;������@@����@@ @@@@@@@@  � �   � � @@@@�@@@@@@@       ��   /  5;;=;+)=+5;;+=++=;������@@����@@ ��@@��@@��@@��������@@@@�@@@@@@@@@@@      ��    '  ;;;+)=+5;+%5;+������@@����@@ ����������  � �   � � @@@@�@@@@@@@     � ��  /  5;++;=;+++=+=+=;=; @@@@@@����@@@@��@@@@��@@�@@@@@������@@����@@��@@       ��     ;);+)+5+;��  @@@@� � �������@�@@@@��@@@@����     � ��  # 7  5);+;++=++;5+;;=+=;   @@@@@@@@��@@��@@���@@@@@@@@�@@@��@@��@@@@@@����� � @@��@@     ��  + 3  5;;;;)=+=;=)=)=;=+5+; @@@@��@@����@@@@  � � ��@@������@@@@@@@� � @@@@@@@@@@@@��@@@      ��  + 3  5;+;;)=+=;=)=)=;=;5+; @@@@��@@����@@@@  � � ��@@������@@@@@@@� � @@@@@@@@@@@@��@@@       ��  # + 3  5;;;)=+=;=)=)=;5+;5+; ��@@@@����@@@@  � � @@ @@@@������@@@��� � @@@@@@@@��@@@@�@@@@       ��  / 7 ?  5;;=;+;;)=+=;=)=)=;5+;5+; ��@@@@@@@@@@����@@@@  � � @@�@@@@ �����@@@@@@@@@@@� � @@@@@@@@��@@@@�@@@@       ��   # + 3  5);)=+=;=)=)5+;5;+%5;+�@@@@����@@@@  � �  ����������������@@@� � @@@@@@@@��@@@�@@@@@@@     ��  + 3 ;  5;;;;)=+=;=)=)=;=;5+;5+;�@@@@@@@@����@@@@  � � @@@@�@@@@������@@@@@@@� � @@@@@@@@@@@@@@@@�@@@@    ��  # + 3  5);+;)=+=;=;=+5+;5+;�@@@@��������@@@@���� @@@@� @@@@�@@@��@@@@@@@@@@@@@@@@�@@@     �  '  5)))+++=;=+=+=;�������@@��@@������@@@@�@@@��@@@@@@@@@@@@��      ��  + 3  5;;;;)))=+=;=;=+5+; @@@@��@@����  ����@@@@��@@������@@@@@@@��@@@@@@��@@@@��@@@    ��  + 3  5;+;;)))=+=;=;=;5+; @@@@��@@����  ����@@@@��@@������@@@@@@@��@@@@@@��@@@@��@@@     ��  # + 3  5;;;)))=+=;=;5+;5+; ��@@@@����  ����@@@@@@ @@@@������@@@����@@@@@@����@@@@�@@@      ��   # + 3  5);)))=+=;5+;5;+%5;+�@@@@����  ����@@@@ ����������������@@@��@@@@@@��@@@@�@@@@@@@  � ��   #  5;;)=;=+5;;+=+ ����������@@@@@@@@@@@@��@@@@���@@@@@@@    � ��   #  5;;)=;=+5;++=; ����������@@ @@@@@@@@@@��@@@@���@@@@@@@  � ��   +  5;;)=;=+5;;+=++=; ����������@@��@@��@@��@@@@��@@@@���@@@@@@@@@@@    � ��    #  5;;)=;=+5;+%5;+ ����������@@ �����������@� � @@@@��@@@@@@@@      ��  / 7 ?  5;;=;+;;+)=+=;=+=;5+;5+;�����@@@@@@@@@@����@@@@@@@@ ���� ������@@@@@@��@@��@@@@��@@@@@@@@� ���     ��  + 3  5;;=;+;;+++;=;5+; ��@@@@@@@@@@������@@@@�@@@@�@@@@@@@@@@@� �   � � @@@@@@@@    ��  ' /  5;;;;+)=+=;=;=+5+; @@@@��@@@@����@@@@��@@������@@@@@@@��@@@@��@@@@�@���    ��  ' /  5;+;;+)=+=;=;=;5+; @@@@��@@@@����@@@@��@@������@@@@@@@��@@@@��@@@@�@���     ��   ' /  5;;;+)=+=;=;5+;5+; ��@@@@@@����@@@@@@ @@@@������@@@����@@@@����@@@@�����     ��  + 3 ;  5;;=;+;;+)=+=;=;5+;5+; ��@@@@@@@@@@@@����@@@@@@�@@@@ �����@@@@@@@@@@@��@@@@����@@@@�����     ��    ' /  5);+)=+=;5+;5;+%5;+�@@@@@@����@@@@ ����������������@@@��@@@@�������@@@@@@@  � ��     5;+5))5;+������ ������ ����@@@@@@@@@@@@     ��    /  5;+5);+)=+=;5+;;=+�@@@@� @@@@@@����@@@@���@@��@@�@@@@@@@��@@@@��@@��@@��      ��   #  ;;;)=+5;;+=+����������@@ @@@@@@@@  � �   ����@@�@@@@@@@       ��   #  ;;;)=+5;++=;����������@@ @@@@@@@@  � �   ����@@�@@@@@@@       ��   +  5;;=;)=+5;;+=++=;����������@@ ��@@��@@��@@������� � @@�@@@@@@@@@@@    ��    #  ;;;)=+5;+%5;+����������@@ ����������  � �   ����@@�@@@@@@@        �   /  5;;=;+)=)=)=+5;++=;������@@����  � � @@ @@@@@@@@@���������@@@@@@@@@@@@@@@@     �     ;);+)+5+;��  @@@@� � �������  ��@@��@@�� ���        �   ' /  5;;=;+)=)=)=+5;+%5;+������@@����  � � @@ ����������@���������@@@@@@@@@@@@@@@@    ��   / 7  5;;;+=++=;=;5++;=+5)) ��@@@@������@@@@ @@@@��@@��@@�����@@@@@��@@@@��@@@@@@@@@@�@@@      ��   # +  5);)=+=;=)=)5+;5))�@@@@����@@@@  � �  ����� @@�����@@@� � @@@@@@@@��@@@�@@@    ��  / ?  5;;=;+;;+=++=;=;=+5++;=+�@@��@@@@@@@@������@@@@@@�@@@@��@@�@@@@@@@��@@��@@@@��@@����@@@@@@@       ��  3 ;  5;;=;+;;)=+=;=)=)=;=+5+;�@@��@@@@@@@@����@@@@  � � @@@@ �����@@@@@@@@@@@� � @@@@@@@@@@@@��@@@        �  3 C  5;;;++;+=+=;=++=;=;5++;=+ ��@@@@@@@@����@@@@����@@@@ @@@@��@@�@@@@@��@@@@@@@@@@��@@��@@@@@@@@@@        �  3 ;  5);++;+=+=;=+=+=;=)=)5+;�@@@@��@@����@@@@��@@@@  � �  �����@@@� � @@@@@@@@@@@@@@@@@@@@��@@@       ��  G  5;+;;+=++;;=;+)=+=+=;=;=;=; @@@@��@@����@@@@����@@� � @@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��  '  5;+;)))=+=;=;=; @@@@������@@����@@@@��@@�@@@@@@@��@@@@��@@@@     ��  C K  5;;;+=++;;=;+)=+=+=;=;=+=;5+; ��@@@@����@@@@����@@� � @@@@@@@@@@@@ @@@@�@@@��@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��  # +  5;;;)))=+=;=;5+; ��@@@@����@@����@@@@@@ @@@@�@@@@@@@��@@@@����@@@@     ��  7 ?  5);+=++;;=;+)=+=+=;=;5;+   @@����@@@@����@@� � @@@@@@@@������@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       ��     5))))=+=;5;+�������@@����@@@@ �����@@@��@@@@��@@@@       ��  G  5;;=;+;+=++;;=;+)=+=+=;=;=+�������@@@@����@@@@����@@� � @@@@@@@@@@�@@@@@@@��@@@@@@@@@@@@@@@@@@@@@@@@��      ��  /  5;;=;+;)))=+=;=;=+���@@��@@������@@����@@@@@@@@�@@@@@@@@@@@��@@@@��@@@@      ��  + ;  5;;=;+;;++);=+5+;=;=+���@@��@@@@@@@@@@������@@�����@@@@�@@@@@@@��@@@@@@@@@@@@��@��@@@@       �     '  5;++5;)=+=;=;5+; ��@@@@����� � @@@@��@@@@@���@@ ��@�@@@��@@�����       ��   7  5);;++)=+=;%5+;+;=;=+�  @@@@@@@@� � @@@@�@@@@@@@@@@@@@�@@@@��@@@@��@@�@��@@��@@��    ��   '  5;;+)=+=;=;=;5+; ��@@@@����@@@@��@@�����@@@@@����@@��@@@@�@���    ��     ))))))5))������  � � @@�@�@�@@�����@@@@@@@@@@@@@@@    ��   # +  5);)))=+=;5+;5))�@@@@����  ����@@@@ ����� @@�����@@@��@@@@@@��@@@@�@@@       ��  /  5;;=;+;)))));=+�@@��@@@@������  � � @@�@�@��@@�@@@@@@@@@@@@@@@@@@@@@@@    ��  3 ;  5;;=;+;;)))=+=;=;=+5+;�@@��@@@@@@@@����  ����@@@@@@@@ �����@@@@@@@@@@@��@@@@@@��@@@@��@@@     ��     ))))))5;+������  � � @@�@�@������@@@@@@@@@@@@@@@       ��   # +  5);)))=+=;5+;5;+�@@@@����  ����@@@@ ����� �����@@@��@@@@@@��@@@@�@@@        �  /  )))))++;+=+=;=+������  � � @@��@@����@@@@���@@@@@@@@@@@@@@@@@@@@@@@       �  3 ;  5);))++;+=+=;=+=+=;5+;�@@@@����  ��@@����@@@@��@@@@ �����@@@��@@@@@@@@@@@@@@@@@@��@@@@      ��  /  5;;=;+;)))));=+���@@��@@������  � � @@�@�@��@@�@@@@@@@@@@@@@@@@@@@@@@@    ��  3 ;  5;;=;+;;)))=+=;=;=+5+;���@@��@@@@@@����  ����@@@@@@@@ �����@@@@@@@@@@@��@@@@@@��@@@@��@@@     ��  + 3  5;;;);=+=;)=+=;=;5+; ��@@@@������@@������@@@@@@ @@@@�@@@@@@@��@@@@��@@����@@@@        �  ' / 7  5;;;+)=)=)=+=;=;5+;5+; ��@@@@@@����  � � @@@@@@ @@@@������@@@@@����@@@@@@@@����@@@@� ���       ��  7  5;;=;+;);=+=;)=+=;=;=+�@@��@@@@��������@@������@@@@@@@@�@@@@@@@@@@@��@@@@��@@��@@@@     �  3 ;  5;;=;+;+)=)=)=+=;=;=+5+;�@@��@@@@��@@����  � � @@@@@@@@ �����@@@@@@@@@����@@@@@@@@��@@@@�����       ��   '  5));=+=;)=+=;5;+���������@@������@@@@ �����@@@��@@@@��@@��@@@@      �   # +  5)+)=)=)=+=;5+;5;+���@@����  � � @@@@ ����� �����@����@@@@@@@@������@@@@      �  ?  5))+;;=+=;+++=;=+=+=+=;=; @@� � @@@@��@@����@@��@@@@@@@@@@@@�@@@@@��@@@@@@��@@@@@@@@@@@@��@@        �  + 3  5;+;+)=)=)=+=;=;=;5+;���@@��@@����  � � @@@@@@@@ �����@@@@@����@@@@@@@@��@@@@�����      ��   '  5;;+=++;5++;=+ ������������ @@@@��@@�@@@����������@@@@����       ��  +  5;;+=++);+=++; ��@@��@@@@  @@���������@@@@@@@@@@@@@��������       ��     ;;=;+=++5+;�����������������@�@@@@�@�@����@@@@     ��  #  5;;;;++++=;���@@��@@������@@@@�@@@@@@@� �   � � @@@@  � ��  + 3  5;;=;+;+;)=;=+=;5+; ����@@@@@@������������@@ �����@@@@@@@@@@@��@@@@����@@@@   � ��   3  5;;)=;=+5;;=;++=++=; ����������@@����@@@@����@@@@@@��@@@@���@@@@@@@@@@@@@@@    � ��     5)+;)=;=+5))����������������������@@@��@@@@��@@@@   � ��     5;;)=;=+5)) ����������@@�@@�����@� � @@@@��@@@@     � ��  /  5;;=;+;+;)=;=+=;=+ @@��@@@@����������������@@�@@@@@@@@@@@��@@@@��@@@@   � ��  #  5;;=;+;)=;=+=+�@@��@@@@��������@@@@�@@@@@@@����@@@@����  �  �  /  5)+;++;+=+=;=+=;=+���������@@����@@@@�������@@@��@@@@@@@@@@@@@@@@��    �  �  + 3  5;;++;+=+=;=+=;=+5;+ ������@@����@@@@����@@������@��@@@@@@@@@@@@@@@@@@@@@@     � ��     5)+;)=;=+5;+��������������� �����@@@��@@@@��@@@@     � ��    5;;)=;=+ ����������@@�@� � @@@@��       ��   '  ;+)=)5)+;)=;=+���@@����  ��  @@@@� � @@@@������@@@@�@@@��@@@@��        �    ' /  5;+)=;+%5;+=+5;+%5;+ ��@@� � ��@@� ����@@������ �����@����@@@@  @@� � ��@@@@@@@@      ��  '  5;;+)=+=;;++=;���@@@@����@@����@@��@@�@@@����@@@@@@@@@@@@@@   �  �   +  5;+)=;=+5;;+=++=;���@@� � ��@@��@@��@@��@@@@� � @@@@���@@@@@@@@@@@     �  7 C  ;;=;=;++;;;+++=;=+%5+;=+��@@@@��@@@@@@@@@@��@@��@@���@@��@@����@@@@@@@@@@@@@@@@@@@@@@@@�@��@@     �  / ;  ;;=;++;;+++=;=+%5+;=+������@@@@@@@@��@@��@@���@@��@@����@@@@@@@@@@@@@@@@@@@@�@��@@    ��  /  ;;=;=;++;;+=+=++����@@��@@@@@@@@��@@�����@��@@@@@@@@@@@@@@@@@@��  � ��    5;++)); @@@@@@  �������@@@@@� � @@��       �   #  5;+;;)=;=+=;=;�@@@@@@��������@@@@@@�@@@@@� � @@@@��@@@@     �  �    ;)+++=;=+���  ��@@��@@��������@@@@@@@@@@     �  �  #  5;;+++=;=+=;+ ������@@��@@����@@�@����@@@@@@@@@@@@       � ��     5;++;))���@@@@� ��  ����@���@@@�����@@    ��     5;++5;;)=;+���@@@@� ����������@@@���@@@@����@@@@@@  � ��     5;+%;)) ��������  ��������@�����@@    ��     5;+5;;)=;+������ ����������@@�����@����@@@@@@    ��    5;;+))=+=;���@@@@  ����@@@@@���@@��@@��@@  � ��  #  5;;+;)=;=+=;=+ ��@@@@��������@@@@@@�@��@@��@@@@��@@��     ��  /  5;++;;=;+=+=++;=; @@@@@@@@@@����@@@@����@@�@@@@@@@@@������@@@@��@@@@       ��  #  5;+;;+++;=; @@@@��@@��������@@�@@@@@@@� �   � � @@@@        �  3  ;;;=;+++=;=;=+=+=++��@@@@����@@��@@��@@@@@@����@@@@������@@@@@@@@@@@@@@��       �� #  );+++=;=;++��@@��@@��@@������@@@@� � @@@@@@@@  � �     ��  + 7  5;;=;+;+=+=++;=+5+;;���@@��@@����@@@@����@@ ��@@@@�@@@@@@@@@����@@@@��@@@@� �@@@@       ��  +  5;;=;+;;+++;=+���@@��@@@@@@��������@@�@@@@@@@@@@@� �   � � @@@@    ��    5;);+++++��  @@��@@��@@@@@���@@� �   � � @@@@        �  +  ;;;=;+)=;=+=+=++��@@@@��@@� � ��@@@@@@����@@@@���@�@@@@@��@@@@��     ��   );+)=;++��@@@@� � ������@@@@����@@@@@@� �       ��    '  5);+)=+=;5+;5))�@@@@@@����@@@@ ����� @@�����@@@��@@@@�������@@@       ��    '  5);+)=+=;5+;5))�@@@@@@����@@@@ ����� @@�����@@@��@@@@�������@@@       ��  / 7  5;;=;+;;+)=+=;=;=+5+;�@@��@@@@@@@@@@����@@@@@@@@ �����@@@@@@@@@@@��@@@@��@@@@�@���     ��  / 7  5;;=;+;;+)=+=;=;=+5+;�@@��@@@@@@@@@@����@@@@@@@@ �����@@@@@@@@@@@��@@@@��@@@@�@���     ��  3 ;  5;+;=;=;+;;+)=+=;=;5+; @@@@��@@@@@@@@@@@@����@@@@@@������@@@@@@@@@@@@@@@��@@@@�����@���    ��  3 ;  5;+;=;=;+;;+)=+=;=;5+; @@@@��@@@@@@@@@@@@����@@@@@@������@@@@@@@@@@@@@@@��@@@@�����@���    ��   '  5)+;+;)=+;+;���������������@@@@ @@@@�@@@��@@��@@@@@@��@����      ��   # +  5);+;)=+=;5+;5+;�@@@@��������@@@@ @@@@ @@@@�@@@��@@@@@@������@@@@       ��  3 ;  5;+;;+;;+=+=++;=;5+; @@@@��@@��@@@@��@@@@����@@�����@@@@@@@@@@@@@@@@@@@��@@@@��@@@    � ��   '  5;+;+++;=;5+; @@@@����@@����@@@@@@�@@@@@@@@@��@@@@�@@@        �  3 ?  );+;;+++=;=;=+=++5+;=;��@@��@@@@��@@��@@@@@@@@�������@@��@@��@@@@@@@@@@@@@@@@@@��@@��@@   �  �� '  ;;=;++;++=;=+���@@����@@@@@@��@@@@@@@@@@@@@@��@@@@@@@@       ��  ; C  5;;=;+;;+;;+=+=++;=+5+; @@@@@@@@��@@��@@@@��@@@@����@@ �����@@@@@@@@@@@@@@@@@@@@@@@��@@@@��@@@  � ��  ' /  5;;=;+;+++;=+5+; ��@@��@@@@��@@����@@ @@@@�@@@@@@@@@@@@@��@@@@�@@@     ��  7  5;+;));+)=)=)=+=;=;=; @@@@��� �   @@@@����@@� � @@@@��@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��  7  5;+;));+)=)=)=+=;=;=; @@@@��� �   @@@@����@@� � @@@@��@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��  / 7  5;;));+)=)=)=+=;=;5+; ��@@� �   @@@@����@@� � @@@@@@ @@@@�@@@��@@@@@@@@@@@@@@@@��@@@@     ��  / 7  5;;));+)=)=)=+=;=;5+; ��@@� �   @@@@����@@� � @@@@@@ @@@@�@@@��@@@@@@@@@@@@@@@@��@@@@      �  ?  5)));++++=;=+=+=;;=)=+=;�@@� �   @@@@@@@@������@@����� � @@@@�@@@@@@@��@@@@@@@@@@@@@@@@��@@@@     �� 7  5)));++++=;=)=)=)=+=;�@@� �   @@@@@@@@����� � @@� � @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ��  ?  5;;=;+;));+)=)=)=+=;=;=+���@@��@@@@� �   @@@@����@@� � @@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      ��  ?  5;;=;+;));+)=)=)=+=;=;=+���@@��@@@@� �   @@@@����@@� � @@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    �  �    5)+++=;=++�����@@����@@���@@@����@@@@@@@@    �  �  #  5;;+++=;=+=+=;�������@@����@@��������@@� � @@@@@@��@@   � ��  '  5;;=;+;+++=;=+ @@��@@@@����������@@�@@@@@@@@@@@� �   @@@@     � ��  '  5;;=;+;++=+=;=+ @@��@@@@����������@@�@@@@@@@��@@����@@��     � ��    5)+;++=+=;=+�����@@@@��@@@@���@@@��@@����@@��    � ��  '  5;;+;++=+=;=+=;�������@@@@��@@@@��������@@@@@@��@@@@��@@       ��  ' 3  5;;=;+;+)=+;=;5+;+ ��@@@@@@��@@����@@@@@@�@@�����@@@@@@@@@� � @@@@  @@@@����        ��  # /  5;;=;+;)=+;=;5+;+ ��@@@@@@������@@@@@@�@@�����@@@@@@@@@����@@  @@@@����        ��     ;;;+)=+5))������@@����@@�@@����  � �   � � @@@@�@@@    ��     ;;;)=+5))����������@@�@@����  � �   ����@@�@@@    ��  ' /  5;;=;+;+)=+;=++;�@@��@@@@��@@����@@��@@ �����@@@@@@@@@� � @@@@  @@�� � �       ��  # +  5;;=;+;)=+;=++;�@@��@@@@������@@��@@ �����@@@@@@@@@����@@  @@�� � �       ��   ' ?  5;;;+)=+;=;5+;5+;;=;=++ ��@@@@@@����@@@@@@ @@@@� @@@@��@@@@���@@@@@� � @@@@  @@@@@@@@@@����@@@@     ��   # ;  5;;;)=+;=;5+;5+;;=;=++ ��@@@@����@@@@@@ @@@@� @@@@��@@@@���@@@@@����@@  @@@@@@@@@@����@@@@     ��  3  5;+;+=;=;+;+)=+;=; @@@@��@@@@@@@@��@@����@@@@@@�@@@����  @@@@@@@@� � @@@@  @@     ��  /  5;+;+=;=;+;)=+;=; @@@@��@@@@@@@@������@@@@@@�@@@����  @@@@@@@@����@@  @@      �  /  ;;;+++;+=+=;=+=+������@@��@@����@@@@��@@  � �   � � @@@@@@@@@@@@@@@@       �  +  ;;;++;+=+=;=+=+��������@@����@@@@��@@  � �   ����@@@@@@@@@@@@@@      ��   7  5;;;+=++;=;5++;=;;=+ ��@@@@��@@��@@@@ @@@@@@@@@@@@�@@@@@����@@@@@@@@@@@@��@@@@��       ��   + 3  5;;;)=+;=;5+;;++; ��@@@@����@@@@@@ @@@@@@@@� @@@@�@@@@@����@@  @@@@@@� �   �  � �    � ��  ' /  5;;;+++=+=+=;=;5+;���@@@@@@@@��@@@@@@@@ �����@@@@@��@@����@@��@@����        �  ' 7  5;;;+)=)=)=+=;=;5++;=+ ��@@@@@@����  � � @@@@@@ @@@@��@@�@@@@@����@@@@@@@@��@@@@@@����     � ��   ' /  5;;=;+++=+=+5;+%5;+�������@@@@��@@@@ ����� ������������@@����@@�@@@@@@@       ��  7  5;+;+++;)=;=;=;=+=;=; @@@@��@@@@@@���@�@@@@@@@����@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��  7  5;+;+++;)=;=;=;=+=;=; @@@@��@@@@@@���@�@@@@@@@����@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@     ��  ' /  5)+++;)=;=;=;=+5;+��@@@@@@���@�@@@@@@@��������@@@@@@@@@@@@@@@@@@@@@@@    ��  ' /  5)+++;)=;=;=;=+5;+��@@@@@@���@�@@@@@@@��������@@@@@@@@@@@@@@@@@@@@@@@    ��  ?  5;;=;+;+++;)=;=;=;=+=;=+���@@��@@��@@@@@@���@�@@@@@@@����@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      ��  ?  5;;=;+;+++;)=;=;=;=+=;=+���@@��@@��@@@@@@���@�@@@@@@@����@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   � ��    5;++; ������@@�@@@������     � ��  '  5;+;+++=;=+=;=; ��������@@��������@@�@@@@@@@��@@@@��@@@@     �      5;;+=++=; ��@@��@@��@@�@@@@@@@@@@@     �      5;;=;++=+���@@��@@��@@�@@@@@@@@@@@  ��     5))�@@�����@@@ � �    5;++=; @@@@@@@@�@@@@@@@    � �    5;;+=+�@@@@@@@@�@@@@@@@     �  �   5))�@@����@@@@  �      5;;=;++=+�@@��@@@@��@@�@@@@@@@@@@@ ���    5;+������@@@     ��      5;;++=+=;5+; ��@@@@��@@@@ @@@@�@@@@@@@@@@@@@@@       ��   5;+;+=+=;�@@@@����@@@@@@@@@@@@@@@@     �      5;;=;++=++=; ��@@@@@@��@@@@@@�@@@@@@@@@@@@@@@     �       5;++=;%5;++=;�@@@@@@@@��@@@@@@@@�@@@@@@@@@@@@@@@    �       %5;;+=+�@@����@@�@@@@@@@  � � �    5;++=;5;+ ��@@��@@��������@@@@ ��� � �    5;++=; @@@@@@@@�@@@@@@@     � �      5;+%5;++=;%5;+ @@@@� @@@@@@@@��@@@@�@@@@@@@@@@@@@@@       ��  ' / 7  5;;=;;;+=+++=;5+;5+;�@@@@��@@@@������@@@@�@@@@������@@@@@@@@@��������@@@@@@@@����   � �   5;+ ���� ���       �   #  5));+))++=;���� � ����  ����@@@@@@�@@@��@@��@@��@@@@      �   #  5;;=;+=++++=;�������������@@@@@@�@�����@�@������@@@@    ��   '  5)+;)=;+%5;++=;�  @@@@� � @@@@� @@@@@@@@�@@@����@@@@@@@@@@@@@@       �   ' /  5;;=);+)=+++=;+;�@@@@  @@@@� � @@@@@@@@������@@@@@@@����@@@@@@@@@@��@����    �   +  5;;=;+++=+=+=++=;�������@@@@��@@@@@@@@@@�@������@@����@@��@@@@    �   G O  5;;=;;;+;+=;=+=++;+=;=+=+=;5+;�@@@@��@@@@@@@@��@@@@@@@@@@��@@@@@@@@�@@@@�@@@@@@@@@��@@@@����@@@@����@@@@��@@@@@@     �    + 3  5;+%5;+;;+=+=+=;=;%5;+�@@@@� @@@@@@����@@@@@@@@��@@@@�@@@@@@@@@� � @@@@��@@@@@@@@     ��   /  5;;;+=++;=;5++;=+ ��@@@@������@@@@ @@@@��@@�@@@@@��������@@@@@@@@����       ��    '  );+;+)5+;5+;��@@@@@@@@�������������@�@@��@@��@@����� ���  � ��    ))+���� � ��@�@@����     ��   '  5;;;);=;5++;+ ��@@@@�@�@@@@@ @@@@��@@�@@@@@����@@@@@@@@� �        ��    ))))))������  � � @@�@�@@�@@��@@��@@    ��  /  5)++++))=;=;=;=;=)��@@@@@@@@  �@�@@@@@@@@@� � �@��@@@@@@@@@@��@@@@@@@@     ��    ;;=;+=++������������@������@�@����      ��    '  5);+)=+;5+;5+;�@@@@@@����@@@@ ���������@@@����@@@@@@����� ���   � ��    5)+;)=;+����������������@@@����@@@@@@    ��  ;  ;;=;=;=;+++;;;+=+=++��@@@@@@��@@@@@@@@@@@@��@@@@��@���@@@@@@@@@@@@@@@@@@@@@@@@��    ��  '  5;;;++=+++;=; ��@@@@��@@@@@@��@@@@�@@@@@����@@@@@@����@@@@       ��  '  ;;;=;=;+=++=++��@@@@@@����@@@@@@��@�@@@@@@@@�@�@��@@@@��      ��  '  ;;;;=;+=+=+=++��@@@@@@����@@@@@@��@�@@@@@@���@�@@@@@@@��      ��      =))5))5))���@�@�@@��������@�@�@@@�@@@�@@@      ��     5);+)=+;+;�@@@@@@����@@@@ �����@@@����@@@@@@��@����    ��    )+++��������@��@�@������    ��     );+)+5+;��@@@@� � �������@�@@��@@��@���       ��  ?  5)+=+;;++;=;)=;=;=;=+=+=+������@@����@@�����@�@@@@@@@@@@@@@�@��@@@@@@@@@@@@@@��@@@@@@@@@@@@   � ��    5)+++����������@@@������    � ��    5;;=;+++=+=+�������@@@@��@@@@@�������@@����@@    ��  ' / 7  5;;;+++=+=+=;=;5+;%5+;�@@��@@@@��@@��@@@@��@@@@ @@@@�@@@@@��@@@@@@@@��@@���������    ��  G  5;;;=;=;++;;+=+=+++=;=;=+=+��@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@��@@@@@@     �   /  5;;=;;=;++;)=;=+=+��@@��@@��@@��@@� � @@��@@@�����������@@��@@@@��@@       ��  ?  5;;;+;+=;=+=++;+=;=+=;=; ��@@@@@@@@��@@@@@@@@@@��@@@@@@@@�@@@@@��@@@@����@@@@����@@@@��@@     � ��    '  5)+;)=;=+5;+%5;+��������������� ����� �����@@@��@@@@��@@@@@@@@     � ��   ' /  5;;=;+++=+=+5;+%5;+�������@@@@��@@@@ ����� ������������@@����@@�@@@@@@@       ��   '  5;+;)=+=;=;=;5+; @@@@������@@@@��@@������@@@@@����@@��@@@@�@���       ��  7  5;+;)))))=+=;=+=;=;=; @@@@������  � � @@����@@@@@@@@��@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@      �  +  5;+;;++++=;;=; @@@@��@@������@@��@@@@�@@@@@@@����@@� �   @@@@��     � �   #  5;+;;+=+=+=;=;�@@@@@@����@@@@@@@@�@@@@@� � @@@@��@@@@     ��   ? G  5;+%5;++;;=+=;;+)=+=+=;=;%5;+�@@@@� @@@@@@@@��@@��@@@@� � @@@@��@@��@@@@�@@@@@@@@@@@����@@@@��@@@@��@@@@@@@@     ��     5))=+=;5+;�������@@@@ �����@����@@������       �   ' /  5);+;+)+;5+;5+;�@@@@@@@@@@� � ��@@ ���������@@@��@@��@@@@������� ���        �  '  5;;;=;+++=+=+=+��@@����@@@@��@@@@@@�@@@������@@����@@��     ��  + 3  5;+;;+)=+=;=;=+=;5+; ����@@@@@@����@@@@��@@@@������@@@@@@@��@@@@��@@@@@@� ���     ��  '  5))))))=+=;=+=;�������  � � @@����@@@@@@@@�@@@@@@@@@@@@@@@@@@@     �  7  5)+++);++=;=)=+=;=;=+�@@��@@@@  @@@@��@@� � @@@@@@@@�@@@@@@@��@@@@@@@@@@@@��@@@@       �    5;;=;;++++��@@��@@������@@�@@@@@@@����@@� �        ��  ' 7 G  5;;;+++=+=+=;=;5++;=+5+;;=; ��@@@@@@@@��@@@@@@@@ @@@@��@@���@@@@@@�@@@@@��@@@@@@@@��@@@@@@@@@@��@@@@@@@     � �     5;;+=+=+�������@@@@�@� � @@@@��      ��  /  ;;=;=;++;;+=+=++����@@��@@@@@@@@��@@�����@��@@@@@@@@@@@@@@@@@@��    ��  ;  5;;;;;;+=+=+++=;=;=+=+��@@@@@@@@@@��@@@@@@��@@@@@@@@�@@@@@@@@@@@����@@@@����@@��@@      �    ;;;;+=+++������@@��@@������� �   � � @@@@@@@@      ��  '  5;;;=;+++=+=+=+��@@����@@@@��@@@@@@�@@@������@@@@@@@@��         ?  5)+;++;;++=;=+=+=;=;=+=+��������@@��@@@@��@@��@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       ��     5);+)=+=;5+;�@@@@@@����@@@@ �����@@@��@@@@������    ��  #  5)+;+=+=++=;=+��@@@@��@@@@��@@@@�@@@��@@@@��� � @@��      �     5);+)+;5+;�@@@@@@� � ��@@ �����@@@��@@��@@����       �  '  5)));+)=)=)=+=;�@@� �   @@@@����  � � @@@@�@@@��@@@@@@@@@@@@��    ��   '  5)+;+)=+=;5+;=+�����@@@@� � @@@@ @@��@@�@@@@@��@@@@��@@����  � ��    5)+;+=+=+���������@@���@@@��@@@@��      ��  '  5;;;=+=;;+)=+=+��@@��@@��@@@@� � @@@@�@@@����@@@@��@@@@��        �  + 3  5;;=;=;;+++=+=+=;5+;�@@@@@@��@@@@��@@��@@@@ @@@@�@� � ��@@@@��@@@@@@@@������       �  G  5;;;=;=;++;;+=+=+++=;=;=+=+��@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@�@@@@@@@@@@@@@@@@@����@@@@����@@@@@@       � '  ;;;+++=+=+;;���@@��@@������@@��@@@@����  � � @@@@@@@@  � �     ��  /  5;;=;;;;++=++=+=;�@@@@@@@@@@@@@@��@@��@@@@�@� � ����  @@��@@@@@@@@��    �     #  5;;+=+=+5;+%5;+�������@@@@ �����������@� � @@@@��@@@@@@@@     ��  ' / 7  5;;;=+=;;+)=+=+5;+%5;+��@@��@@��@@@@� � @@@@ �����������@@@����@@@@��@@@@��@@@@@@@@      ��  ' /  5;+;;+)=+=;=;=;5+; @@@@��@@@@����@@@@��@@������@@@@@@@��@@@@��@@@@�@���     ��  7  5;+;;+)=+=+=;;;=+=+=; @@@@��@@@@� � @@@@��@@��@@@@@@�@@@@@@@��@@@@��@@@@����@@@@     ��  / ?  5;;=;;;;++=++=+=;5;++=;�@@@@@@@@@@@@@@��@@��@@@@�@@@@@@@@�@� � ����  @@��@@@@@@@@��@@@@@@@@       ��  '  5;;;)))));=+ @@@@������  � � @@�@�@��@@�@@@@@@@@@@@@@@@@@@@       ��    '  ))))))5;+%5;+������  � � @@�@�@ �����������@@@@@@@@@@@@@@@@@@@        �  '  5)+;;++=;+++@@����@@@@��@@����@@�@@@@@@@� � @@@@  � � ��     � ��    5;+;)+;=; @@@@��� � ����@@�@@@@@@@� � @@@@     ��  ?  5);+=++));;=;+)=+=+=;=;   @@����@@  � � @@����@@� � @@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@��@@       ��  7  5);+=+);+)=+=;;=)=+=;�  @@����  @@@@����@@����� � @@@@�@@@@@@@��@@��@@@@@@@@��@@��  � ��    5)+;)=;+����������������@@@����@@@@@@  � ��    '  5)+;)=;=+5;+%5;+��������������� ����� �����@@@��@@@@��@@@@@@@@       ��    ;+)=+=;;���@@����@@����������@@@@@@@@      ��  # +  5;;;++++;=;5+; ����@@@@��@@��@@@@�@@@@�@��@@��@@@@����@@@@�@���    ��  # +  ;;=;;;++=++5+;��@@@@��@@@@��@@���@@@@@�������@@��@@����@���       ��    5)+;;++++@@����@@������@@�@@@@@@@� �   � � ��       ��  / ?  ;;=;=;++;;+=+=++5;++=;����@@��@@@@@@@@��@@���� @@@@@@@@�@��@@@@@@@@@@@@@@@@@@��@@@@@@@@       ��  /  5;;;+=+++;;=;=+=+ @@@@����@@@@����@@@@@@@@�@@@@@������@@@@@@��@@@@@@       ��  / 7  5;;=;+;+)=)=)=+=;=+5+;�@@��@@@@��@@����@@� � @@��@@ �����@@@@@@@@@� � @@@@@@@@��@@� ���        �    ;;;++=+��������@@��@��������@�@@@@@      ��   /  5;;;+=++;=;5++;=+ ��@@@@������@@@@ @@@@��@@�@@@@@��������@@@@@@@@����       ��     )));+)5+;��� �   @@@@���������@�@@��@@��@@ ���       ��    '  );+;+)5+;5+;��@@@@@@@@�������������@�@@��@@��@@����� ���  � ��    ))+���� � ��@�@@����          +  5);+=)+=;=;=;++;�  @@��� � ��@@@@@@ @@@@���@�@�@@@@@@@��������@����       ��    ))))))������  � � @@�@�@@�@@��@@��@@    ��  G  5;;=;;=;++;;+=++=++=;=;=+=+��@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@������������@@@@@@������������@@@@@@     ��  7  5);+;+)=+=;;=+=;=++=;�@@@@@@@@@@����@@������������@@�@@@��@@��@@@@@@@@��@@��@@@@    ��  '  ;;=;=;=;+=++++��@@@@@@����@@@@@@��@���@@@@@@�@�@��@@@@@@      ��  + 7  5;;=;+;+=+++;=+5+;=;�@@��@@@@����@@@@����@@���@@@@�@@@@@@@@@������@@@@@@@@�@��@@    ��  ;  ;;=;=;=;+++;;;+=+=++��@@@@@@��@@@@@@@@@@@@��@@@@��@���@@@@@@@@@@@@@@@@@@@@@@@@��    ��  #  5)+++++=;=;=;�  ��@@@@@@��@@@@@@�@�@�@��@@��������@@     ��  '  ;;;=;=;+=++=++��@@@@@@����@@@@@@��@�@@@@@@@@�@�@��@@@@��      ��    ;;=;+=++������������@������@�@����      ��     5);+)=+;+;�@@@@@@����@@@@ �����@@@����@@@@@@��@����    ��    )+++��������@��@�@������    ��     );+)+5+;��@@@@� � �������@�@@��@@��@���       ��  7  5);+=++;;=;+)=+=+=;=;   @@����@@@@����@@� � @@@@@@@@�@@@@@@@@@��@@@@@@@@@@@@��@@     � ��    5)+++����������@@@������      ��  '  5;;=;+)=+=;;=)=+������@@����@@����� � @@@���������@@@@@@@@��@@       ��  ' / 7  5;;;+++=+=+=;=;5+;%5+;�@@��@@@@��@@��@@@@��@@@@ @@@@�@@@@@��@@@@@@@@��@@���������    ��  G  5;;;=;=;++;;+=+=+++=;=;=+=+��@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@��@@@@@@@@��@@@@@@��@@@@@@@@��@@@@@@      �    ;;;;+=)������@@������@�������������@@    ��    5;;=;+=)=+��������� � @@@������@�@��@@     ��    ;;;;;)��@@@@@@���@�@@��������������@�@          ;;;;;;+=)��@@@@@@��@@������@�������������������@@    ��     5;;;+)+5+;����@@@@����@@������@��@@��@@���@���    ��   #  ;;;=;+=+)5+;����@@����@@� � �@@@@@���@@���@�@@@@@@���       ��     ;);+)5+;��  @@@@���������@���@@��@@@���       ��  ?  5);;++)=+=;;=;=)=)=+=++=;�  @@@@@@@@� � @@����@@� �   @@����@@�@@@@@��@@@@@@@@@@@@@@@@@@@@@@@@    �   ' /  ;;=;=;;++=+=+++;��@@@@��@@@@��@@@@�� @@@@@�����@@@@����@@@@�����@����      ��  # /  5)+=+++=;=;=+=;5+;;�����@@@@��@@@@��@@ ��@@���@�@�@��@@@@@@@@@@������@@    ��   #  5);)=+=;=)=)5+;�@@@@����@@@@  � �  �����@@@� � @@@@@@@@��@@@     ��  # /  5));=;;+)=+;5++;�������@@��@@@@����@@@@ ��@@���@@@��@@@@��@@@@@@�@�@@��       ��    '  );+;+)5+;5+;��@@@@@@@@��������������@@@@@@@@@@@�@@@�@@@   � ��    ))+���� � ���@@@� �       �   #  5)+)=)=)=+=;5+;���@@����  � � @@@@ �����@����@@@@@@@@������      ��   #  5);)))=+=;5+;�@@@@����  ����@@@@ �����@@@��@@@@@@��@@@@    ��  7  5;;=;;=;+;+=++=++=;=+��@@@@@@��@@@@��@@@@@@��@@@@������������@@������������@@     ��  '  5);+;+)=)=)=)=)��@@@@@@@@����@@� �   �����@@@@@@@@@@@@@@@@@@@     ��  '  ;;=;=;=;+=++++��@@@@@@����@@@@@@���@��@@@@@@������@@@@@@      ��  / ?  5;;=;+;+=++++;=+5+;=;=;�@@��@@@@����@@@@@@����@@ ��@@@@@@�@@@@@@@@@������@@@@@@@@@@�@��@@@@    ��  /  ;;=;=;++;;+=+=++����@@��@@@@@@@@��@@�����@��@@@@@@@@@@@@@@@@@@��    ��    5)++++=;=; @@����@@��@@@@�@����  ��������     ��  '  ;;;=;=;+=++=++��@@@@@@����@@@@@@���@@@@@@@@@������������      ��    ;;=;+=++�������������@������������      ��     5);+)=+=;5+;�@@@@@@����@@@@ �����@@@��@@@@������    ��    )+++���������@����  � �      �     );+)+5+;��@@@@� � ���������@@��@@�� ���       ��    5))))=+=;�������@@����@@@@�@@@��@@@@��  � ��    5)+++����������@@@� �          �    5;;=;+)=)=)=+������@@����  � � @@@���������@@@@@@@@      �� ' / 7  5;;;+++=+=+=;=;5+;%5+;�@@��@@@@��@@��@@@@��@@@@ @@@@@@@@@@��@@@@@@@@��@@���������    ��  '  5;;=;+;+=++=;=+����������������������@@@@��@@��@@@@��@@      �    ;;;;+=)������@@�������@� �   � � ��@@    ��    5;;=;+=)=+��������� � @@������������@@     ��    ;;;;;)��@@@@@@���@�@�@� �   � �   ����          ;;;;;;+=)��@@@@@@��@@�������@� �   � �   � � ��@@    ��     5;;;+)+5+;����@@@@����@@������@��@@@@@@  ��@@@    ��   #  ;;;=;+=+)%5+;����@@����@@� � �@@@@�@��@@������@@@@�@@@    ��     ;);+)%5+;��  @@@@����������@��@@@@@@�@@@    ��  /  5);+)=+=;;=+=;=++=;�@@@@@@����@@������������@@�@@@��@@@@@@@@@@@@@@@@@@    �   ' /  ;;=;=;;++=+=++5+;��@@@@��@@@@��@@@@�� @@@@�@��@@@@@@��@@@@@@��@���       ��   #  5)+=++=;=+=;5+;���������@@@@@@ �����@����������@@@@@@@@    ��  + 3  5;;;;)))=+=;=;=+5+; @@@@��@@����  ����@@@@��@@������@@@@@@@��@@@@@@��@@@@��@@@    ��   # + 3  5);)))=+=;5+;5;+%5;+�@@@@����  ����@@@@ ����������������@@@��@@@@@@��@@@@�@@@@@@@     �  /  5;;+;;++=;=+++=;���������@@@@��@@����@@@@�@@@@@@@@@��@@@@����@@@@    � ��    5;+;)+;=; @@@@��� � ����@@�@@@@@@@� � @@@@     ��  /  5);+=+;+;=;+)=+=;�@@@@������������@@����@@@@�@@@@@@@@@@@@@@@@@@@@@��    ��  '  5)));+)=)=)=+=;�@@� �   @@@@����@@� � @@@@�@@@@@@@@@@@@@@@@@@@  � ��     5;;)=;=+5;+ ����������@@������@� � @@@@��@@@@     � ��    #  5;;)=;=+5;+%5;+ ����������@@ �����������@� � @@@@��@@@@@@@@    �        5;+)=;+5;+���@@� � ��@@������@����@@@@  @@@@     ��  # +  5;;;++=++=;=;5+; ����@@@@��@@��@@@@�@@@@�@@@@@��@@������@@� ���      ��  # +  ;;=;;;++=++5+;��@@@@��@@@@��@@���@@@@�@����@@@@��@@���� ���       ��  '  5;;+;;+=+++=;���������@@������@@@@�@@@@@@@@@������@@@@      ��  / ?  ;;=;=;++;;+=+=++5;++=;����@@��@@@@@@@@��@@���� @@@@@@@@�@��@@@@@@@@@@@@@@@@@@��@@@@@@@@       ��  ' 7  ;;=;=;=;+=++++5;;+=+��@@@@@@����@@@@@@�� @@@@@@@@�@��@@@@@@������@@@@@@@@@@@@@@      �  / 7  5;;=;+;+)=)=)=+=;=+5+;�@@��@@@@��@@����  � � @@��@@ �����@@@@@@@@@����@@@@@@@@��@@�����        �    ;;;++=+��������@@���@� �   ����@@@@      ��   5))���@�@@@@@      �   5))  � � @@@@     ��   5))���@�@@@@@   ��    5;++=;���@@��@@�@@@����     ��    5;++=;���@@��@@����@@@@      ��    5;++=;���@@��@@����@@@@     ���    5;;=;++=++=; ��@@��@@��@@��@@�@@@@@@@��������     ���    5;;=;++=++=; ��@@��@@��@@��@@��������@@@@@@@@       �     5;;=;++=++=;���@@��@@��@@��@@��������@@@@@@@@  � ��    5;;+++=;�����������������@@� �   @@     � ��  '  5;;+;++=+=;=+=;�������������������������@@@@@@����@@@@@@           5;;++=+=;���@@@@��@@@@�@@@��@@@@��       ���     5;+%5;+%5;+ @@@@��@@@@��@@@@ �����������       �   ? O W g o  5;+++)+)=+++=;=;=;=;=;=;5+;;=+5+;5;++=;5+; @@@@@@@@  @@� � @@@@@@@@@@@@@@@@@@� @@@@@@@@�@@@@� ��@@��@@�@@@@�@@@@@@@@@��@@��@@@@@@@@@@@@@@@@�@@@@@@@@@@@@�@��@@��@@@@      � '  5;++;;+=+=+=;=; ��@@@@@@@@��@@@@@@@@@@@@@@@@@@@@@@@@@@@@     � �� '  5;;;+++=;=;=+=+���@@@@@@@@��@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ��  7  5;+++++++=;=;=;=;=;=; @@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@       ��  7 ? G  5;;++;;++=+=+=;=+=;=;5+;5+;���@@��������@@��@@��@@@@��@@ @@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@@     �  + 3 ;  5;;;=;;+++=++;+;%5+;���@@@@@@@@@@@@@@@@��@@ �����@@@@�@@@��@@@@��@@@@��@@����@��������      ��    ' ;  %5;+5;;++=+=;5+;%;;+++ �����@@@@@@@@@@@@�@@@@� ��@@@@@@@@�@@@@@@@��@@@@������@�@@����������    � �    5)+=++=++=+���@@@@@@@@@@@@�@� � ����������    �   '  5;))+=+=+=+=;=;=;�@@  � � @@@@@@@@@@@@@@�@������@@@@@@@@@@@@        �  '  5;;;;+++=;=;=;�@@@@@@@@������@@@@@@�@@@@@@@@@� �   @@@@@@       �   '  5;;;;++++=)=) @@@@@@@@@@@@@@@@� �   ��@@@@@@@@@@@@@@����        �  '  ;;++++=+=+=+=; ����@@@@@@@@@@@@@@��  � � @@@@@@@@@@@@@@@@    ��  / 7  5);;+)=+=;=)=+=++=;5+;�  @@@@@@����@@@@  @@����@@ �����@@@@@� � @@@@��@@@@@@@@@@� ���       ��   '  5;;;);=;5++;+ ��@@@@�@�@@@@@ @@@@��@@�@@@@@����@@@@@@@@� �        ��    )+++��������@��@�@������    ��  ?  5)+=+;;++;=;)=;=;=;=+=+=+������@@����@@�����@�@@@@@@@@@@@@@�@��@@@@@@@@@@@@@@��@@@@@@@@@@@@     ��    )++=+=+=;;�  ����@@@@��@@�@@@����@@@@@@@@      �  ' / 7  5;;=;;++=++=+=;5+;%5+;���@@��@@@@��@@��@@@@ ����������@@@@@@@��@@@@@@@@����������  �  �  '  5;;+=+++=+=;;; ��@@@@@@@@��@@@@@@@@�@@@@@@@����@@@@@@@@��        �  ?  5;;=;++=++=;5;;=;++=++=;�����@@@@����@@@@����@@@@����@@@@�@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@     ��  7  5;+;+;)++=;=+=;=+=)=; @@@@@@��������@@@@@@@@����@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@      �    /  %5))5;++;;+=+=+=;=;   � �  ��@@@@@@@@��@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@      �    /  %5))5;;;+++=;=;=+=+   � � ��@@@@@@@@��@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@     ��    5;;;;)=;=;=;�@@@@@@@@�@�@@@@@@@��������@@@@����     ��    ;;;;++++@@������������@@@�@@@@@@@@@@@@@@    ��    5)++++=+=+=+��@@@@@@@@@@@@@@�@@@������������       ��    5;+=+=+=+=;=;=; @@@@�������������@�@�@@@@@@@@@@@@@     ��  7 _  5;;;;++++=+=+=+=;=;=;5+++;;;=;=;=+=+�@@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ��  7  5;;++;+=+=+++=;=+=+=;�@@��@@@@@@@@@@@@@@@@@@@@@@������@@@@@@��@@@@@@@@��@@@@@@       ��  / G  5;;++;+=++=;=+=+=;5++;;=;=+�@@��@@@@@@@@��@@@@@@@@���@@@@@@@@@@@@����@@@@@@��@@@@��@@@@@@@@@@@@@@@@@@    ��  /  5;;;;+;)=;=+=;=;=;�@@@@@@@@��@@����@@��@@@@@@�@@@@@@@��@@@@@@@@��@@@@   � ��   '  5;;+;)=;=+=;5+;�������@@� � @@���� ������������@@@@��������     ��  /  5;;=;;++++=+=+=+=;���@@��@@@@@@@@@@@@@@@@@@�@@@@@@@��@@@@@@@@@@@@��    ��  7  5;;;;++++=+=+=+=;=;=;�@@@@@@@@@@@@@@@@@@@@@@@@@@@@�@@@@@@@@@@@@@@@@@@@@@@@@@@@       ��  7  ;;;;++=;=+=+++=+=;=;�@@@@@@@@@@@@@@@@@@@@��@@@@��  @@@@@@@@@@@@@@@@� � @@@@@@@@  � ��      ))5);+;5+;��������� � ������� @@@@@��@�@@�@@@@@@�@@@    � � �   5;)=;���������@@��@@     �   / 7 G  5;;;+++=++=+=+=;=;5+;5++;=; @@��@@@@@@��@@@@@@@@@@���@@@@ @@@@@@@@�@@@@@��@@@@@@@@@@@@��@@@@@@����@@@@    ��  #  5;+)++++=;=; ����  ������@@@@@@�@@@@@����  � �   @@@@     ��   #  5)++++=;=;5+; @@������@@@@@@������@�@�@  � �   @@@@@@@@     �        N �              *       *�       �       �       $      5$�       6	  	   �    	   �  	    	  T2  	  �  	  �  	  
  	 "j1  	  45� ( c )   2 0 1 1   C o d y   " C o d e M a n 3 8 "   B o i s c l a i r .   R e l e a s e d   u n d e r   t h e   S I L   O p e n   F o n t   L i c e n s e .  (c) 2011 Cody "CodeMan38" Boisclair. Released under the SIL Open Font License.  P r e s s   S t a r t   2 P  Press Start 2P  R e g u l a r  Regular  F o n t F o r g e   2 . 0   :   P r e s s   S t a r t   2 P   :   1 2 - 6 - 2 0 1 1  FontForge 2.0 : Press Start 2P : 12-6-2011  P r e s s   S t a r t   2 P  Press Start 2P  V e r s i o n   2 . 1 4    Version 2.14   P r e s s S t a r t 2 P  PressStart2P  C o p y r i g h t   ( c )   2 0 1 1 ,   C o d y   " C o d e M a n 3 8 "   B o i s c l a i r   ( c o d y @ z o n e 3 8 . n e t ) , 
 w i t h   R e s e r v e d   F o n t   N a m e   P r e s s   S t a r t . 
 
 T h i s   F o n t   S o f t w a r e   i s   l i c e n s e d   u n d e r   t h e   S I L   O p e n   F o n t   L i c e n s e ,   V e r s i o n   1 . 1 . 
 T h i s   l i c e n s e   i s   c o p i e d   b e l o w ,   a n d   i s   a l s o   a v a i l a b l e   w i t h   a   F A Q   a t : 
 h t t p : / / s c r i p t s . s i l . o r g / O F L 
 
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 S I L   O P E N   F O N T   L I C E N S E   V e r s i o n   1 . 1   -   2 6   F e b r u a r y   2 0 0 7 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 
 P R E A M B L E 
 T h e   g o a l s   o f   t h e   O p e n   F o n t   L i c e n s e   ( O F L )   a r e   t o   s t i m u l a t e   w o r l d w i d e 
 d e v e l o p m e n t   o f   c o l l a b o r a t i v e   f o n t   p r o j e c t s ,   t o   s u p p o r t   t h e   f o n t   c r e a t i o n 
 e f f o r t s   o f   a c a d e m i c   a n d   l i n g u i s t i c   c o m m u n i t i e s ,   a n d   t o   p r o v i d e   a   f r e e   a n d 
 o p e n   f r a m e w o r k   i n   w h i c h   f o n t s   m a y   b e   s h a r e d   a n d   i m p r o v e d   i n   p a r t n e r s h i p 
 w i t h   o t h e r s . 
 
 T h e   O F L   a l l o w s   t h e   l i c e n s e d   f o n t s   t o   b e   u s e d ,   s t u d i e d ,   m o d i f i e d   a n d 
 r e d i s t r i b u t e d   f r e e l y   a s   l o n g   a s   t h e y   a r e   n o t   s o l d   b y   t h e m s e l v e s .   T h e 
 f o n t s ,   i n c l u d i n g   a n y   d e r i v a t i v e   w o r k s ,   c a n   b e   b u n d l e d ,   e m b e d d e d ,   
 r e d i s t r i b u t e d   a n d / o r   s o l d   w i t h   a n y   s o f t w a r e   p r o v i d e d   t h a t   a n y   r e s e r v e d 
 n a m e s   a r e   n o t   u s e d   b y   d e r i v a t i v e   w o r k s .   T h e   f o n t s   a n d   d e r i v a t i v e s , 
 h o w e v e r ,   c a n n o t   b e   r e l e a s e d   u n d e r   a n y   o t h e r   t y p e   o f   l i c e n s e .   T h e 
 r e q u i r e m e n t   f o r   f o n t s   t o   r e m a i n   u n d e r   t h i s   l i c e n s e   d o e s   n o t   a p p l y 
 t o   a n y   d o c u m e n t   c r e a t e d   u s i n g   t h e   f o n t s   o r   t h e i r   d e r i v a t i v e s . 
 
 D E F I N I T I O N S 
 " F o n t   S o f t w a r e "   r e f e r s   t o   t h e   s e t   o f   f i l e s   r e l e a s e d   b y   t h e   C o p y r i g h t 
 H o l d e r ( s )   u n d e r   t h i s   l i c e n s e   a n d   c l e a r l y   m a r k e d   a s   s u c h .   T h i s   m a y 
 i n c l u d e   s o u r c e   f i l e s ,   b u i l d   s c r i p t s   a n d   d o c u m e n t a t i o n . 
 
 " R e s e r v e d   F o n t   N a m e "   r e f e r s   t o   a n y   n a m e s   s p e c i f i e d   a s   s u c h   a f t e r   t h e 
 c o p y r i g h t   s t a t e m e n t ( s ) . 
 
 " O r i g i n a l   V e r s i o n "   r e f e r s   t o   t h e   c o l l e c t i o n   o f   F o n t   S o f t w a r e   c o m p o n e n t s   a s 
 d i s t r i b u t e d   b y   t h e   C o p y r i g h t   H o l d e r ( s ) . 
 
 " M o d i f i e d   V e r s i o n "   r e f e r s   t o   a n y   d e r i v a t i v e   m a d e   b y   a d d i n g   t o ,   d e l e t i n g , 
 o r   s u b s t i t u t i n g   - -   i n   p a r t   o r   i n   w h o l e   - -   a n y   o f   t h e   c o m p o n e n t s   o f   t h e 
 O r i g i n a l   V e r s i o n ,   b y   c h a n g i n g   f o r m a t s   o r   b y   p o r t i n g   t h e   F o n t   S o f t w a r e   t o   a 
 n e w   e n v i r o n m e n t . 
 
 " A u t h o r "   r e f e r s   t o   a n y   d e s i g n e r ,   e n g i n e e r ,   p r o g r a m m e r ,   t e c h n i c a l 
 w r i t e r   o r   o t h e r   p e r s o n   w h o   c o n t r i b u t e d   t o   t h e   F o n t   S o f t w a r e . 
 
 P E R M I S S I O N   &   C O N D I T I O N S 
 P e r m i s s i o n   i s   h e r e b y   g r a n t e d ,   f r e e   o f   c h a r g e ,   t o   a n y   p e r s o n   o b t a i n i n g 
 a   c o p y   o f   t h e   F o n t   S o f t w a r e ,   t o   u s e ,   s t u d y ,   c o p y ,   m e r g e ,   e m b e d ,   m o d i f y , 
 r e d i s t r i b u t e ,   a n d   s e l l   m o d i f i e d   a n d   u n m o d i f i e d   c o p i e s   o f   t h e   F o n t 
 S o f t w a r e ,   s u b j e c t   t o   t h e   f o l l o w i n g   c o n d i t i o n s : 
 
 1 )   N e i t h e r   t h e   F o n t   S o f t w a r e   n o r   a n y   o f   i t s   i n d i v i d u a l   c o m p o n e n t s , 
 i n   O r i g i n a l   o r   M o d i f i e d   V e r s i o n s ,   m a y   b e   s o l d   b y   i t s e l f . 
 
 2 )   O r i g i n a l   o r   M o d i f i e d   V e r s i o n s   o f   t h e   F o n t   S o f t w a r e   m a y   b e   b u n d l e d , 
 r e d i s t r i b u t e d   a n d / o r   s o l d   w i t h   a n y   s o f t w a r e ,   p r o v i d e d   t h a t   e a c h   c o p y 
 c o n t a i n s   t h e   a b o v e   c o p y r i g h t   n o t i c e   a n d   t h i s   l i c e n s e .   T h e s e   c a n   b e 
 i n c l u d e d   e i t h e r   a s   s t a n d - a l o n e   t e x t   f i l e s ,   h u m a n - r e a d a b l e   h e a d e r s   o r 
 i n   t h e   a p p r o p r i a t e   m a c h i n e - r e a d a b l e   m e t a d a t a   f i e l d s   w i t h i n   t e x t   o r 
 b i n a r y   f i l e s   a s   l o n g   a s   t h o s e   f i e l d s   c a n   b e   e a s i l y   v i e w e d   b y   t h e   u s e r . 
 
 3 )   N o   M o d i f i e d   V e r s i o n   o f   t h e   F o n t   S o f t w a r e   m a y   u s e   t h e   R e s e r v e d   F o n t 
 N a m e ( s )   u n l e s s   e x p l i c i t   w r i t t e n   p e r m i s s i o n   i s   g r a n t e d   b y   t h e   c o r r e s p o n d i n g 
 C o p y r i g h t   H o l d e r .   T h i s   r e s t r i c t i o n   o n l y   a p p l i e s   t o   t h e   p r i m a r y   f o n t   n a m e   a s 
 p r e s e n t e d   t o   t h e   u s e r s . 
 
 4 )   T h e   n a m e ( s )   o f   t h e   C o p y r i g h t   H o l d e r ( s )   o r   t h e   A u t h o r ( s )   o f   t h e   F o n t 
 S o f t w a r e   s h a l l   n o t   b e   u s e d   t o   p r o m o t e ,   e n d o r s e   o r   a d v e r t i s e   a n y 
 M o d i f i e d   V e r s i o n ,   e x c e p t   t o   a c k n o w l e d g e   t h e   c o n t r i b u t i o n ( s )   o f   t h e 
 C o p y r i g h t   H o l d e r ( s )   a n d   t h e   A u t h o r ( s )   o r   w i t h   t h e i r   e x p l i c i t   w r i t t e n 
 p e r m i s s i o n . 
 
 5 )   T h e   F o n t   S o f t w a r e ,   m o d i f i e d   o r   u n m o d i f i e d ,   i n   p a r t   o r   i n   w h o l e , 
 m u s t   b e   d i s t r i b u t e d   e n t i r e l y   u n d e r   t h i s   l i c e n s e ,   a n d   m u s t   n o t   b e 
 d i s t r i b u t e d   u n d e r   a n y   o t h e r   l i c e n s e .   T h e   r e q u i r e m e n t   f o r   f o n t s   t o 
 r e m a i n   u n d e r   t h i s   l i c e n s e   d o e s   n o t   a p p l y   t o   a n y   d o c u m e n t   c r e a t e d 
 u s i n g   t h e   F o n t   S o f t w a r e . 
 
 T E R M I N A T I O N 
 T h i s   l i c e n s e   b e c o m e s   n u l l   a n d   v o i d   i f   a n y   o f   t h e   a b o v e   c o n d i t i o n s   a r e 
 n o t   m e t . 
 
 D I S C L A I M E R 
 T H E   F O N T   S O F T W A R E   I S   P R O V I D E D   " A S   I S " ,   W I T H O U T   W A R R A N T Y   O F   A N Y   K I N D , 
 E X P R E S S   O R   I M P L I E D ,   I N C L U D I N G   B U T   N O T   L I M I T E D   T O   A N Y   W A R R A N T I E S   O F 
 M E R C H A N T A B I L I T Y ,   F I T N E S S   F O R   A   P A R T I C U L A R   P U R P O S E   A N D   N O N I N F R I N G E M E N T 
 O F   C O P Y R I G H T ,   P A T E N T ,   T R A D E M A R K ,   O R   O T H E R   R I G H T .   I N   N O   E V E N T   S H A L L   T H E 
 C O P Y R I G H T   H O L D E R   B E   L I A B L E   F O R   A N Y   C L A I M ,   D A M A G E S   O R   O T H E R   L I A B I L I T Y , 
 I N C L U D I N G   A N Y   G E N E R A L ,   S P E C I A L ,   I N D I R E C T ,   I N C I D E N T A L ,   O R   C O N S E Q U E N T I A L 
 D A M A G E S ,   W H E T H E R   I N   A N   A C T I O N   O F   C O N T R A C T ,   T O R T   O R   O T H E R W I S E ,   A R I S I N G 
 F R O M ,   O U T   O F   T H E   U S E   O R   I N A B I L I T Y   T O   U S E   T H E   F O N T   S O F T W A R E   O R   F R O M 
 O T H E R   D E A L I N G S   I N   T H E   F O N T   S O F T W A R E .  Copyright (c) 2011, Cody "CodeMan38" Boisclair (cody@zone38.net),
with Reserved Font Name Press Start.

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at:
http://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded, 
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.  h t t p : / / s c r i p t s . s i l . o r g / O F L  http://scripts.sil.org/OFL          �� 3                   /           	 
                        ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � b c � d � e � � � � � � � f � � � � g � � � � � h � � � j i k m l n � o q p r s u t v w � x z y { } | � �  ~ � � � � �	
 � � �  ! � �"#$%&'()*+,-./01 � �23456789:;<=>?@ � �ABCDEFGHIJKLMNO � �PQRSTUVWXY � � � �Z[\]^_`abcdefghijklmno �pqrs � �t � � �uvwx � � � � � �yz{|}~��������� �������������������� ������������������� ���� �������������������������������������������������������������������������������� 	
 � � � � � � � � � � � � � � � � !" �#$%& �' � � � � � � � � �()*+ �,-./01234567uni007Funi00A0uni00ADuni00B2uni00B3uni00B5uni00B9AmacronamacronAbreveabreveAogonekaogonekCcircumflexccircumflex
Cdotaccent
cdotaccentDcarondcaronDcroatEmacronemacronEbreveebreve
Edotaccent
edotaccentEogonekeogonekEcaronecaronGcircumflexgcircumflex
Gdotaccent
gdotaccentGcommaaccentgcommaaccentHcircumflexhcircumflexHbarhbarItildeitildeImacronimacronIbreveibreveIogonekiogonekIJijJcircumflexjcircumflexKcommaaccentkcommaaccentkgreenlandicLacutelacuteLcommaaccentlcommaaccentLcaronlcaronLdotldotNacutenacuteNcommaaccentncommaaccentNcaronncaronnapostropheEngengOmacronomacronObreveobreveOhungarumlautohungarumlautRacuteracuteRcommaaccentrcommaaccentRcaronrcaronSacutesacuteScircumflexscircumflexTcommaaccenttcommaaccentTcarontcaronTbartbarUtildeutildeUmacronumacronUbreveubreveUringuringUhungarumlautuhungarumlautUogonekuogonekWcircumflexwcircumflexYcircumflexycircumflexZacutezacute
Zdotaccent
zdotaccentlongsuni02C9uni02CAuni02CBuni02D7uni037Auni037Etonosdieresistonos
Alphatonos	anoteleiaEpsilontonosEtatonos	IotatonosOmicrontonosUpsilontonos
OmegatonosiotadieresistonosAlphaBetaGammaEpsilonZetaEtaThetaIotaKappaLambdaMuNuXiOmicronPiRhoSigmaTauUpsilonPhiChiPsiIotadieresisUpsilondieresis
alphatonosepsilontonosetatonos	iotatonosupsilondieresistonosalphabetagammadeltaepsilonzetaetathetaiotakappalambdanuxiomicronrhosigma1sigmatauupsilonphichipsiomegaiotadieresisupsilondieresisomicrontonosupsilontonos
omegatonosuni0400	afii10023	afii10051	afii10052	afii10053	afii10054	afii10055	afii10056	afii10057	afii10058	afii10059	afii10060	afii10061uni040D	afii10062	afii10145	afii10017	afii10018	afii10019	afii10020	afii10021	afii10022	afii10024	afii10025	afii10026	afii10027	afii10028	afii10029	afii10030	afii10031	afii10032	afii10033	afii10034	afii10035	afii10036	afii10037	afii10038	afii10039	afii10040	afii10041	afii10042	afii10043	afii10044	afii10045	afii10046	afii10047	afii10048	afii10049	afii10065	afii10066	afii10067	afii10068	afii10069	afii10070	afii10072	afii10073	afii10074	afii10075	afii10076	afii10077	afii10078	afii10079	afii10080	afii10081	afii10082	afii10083	afii10084	afii10085	afii10086	afii10087	afii10088	afii10089	afii10090	afii10091	afii10092	afii10093	afii10094	afii10095	afii10096	afii10097uni0450	afii10071	afii10099	afii10100	afii10101	afii10102	afii10103	afii10104	afii10105	afii10106	afii10107	afii10108	afii10109uni045D	afii10110	afii10193	afii00208Eurouni20AF	afii61352	arrowleftarrowup
arrowright	arrowdownuni2206triagupuni25B6triagdnuni25C0uni2605uni2606spadeclubheartdiamondmusicalnoteuniF100uniF101uniF8FFuniFB01uniFB02    ��               .                    �=��    ��    ̶%wGDST@   @            �  WEBPRIFF�  WEBPVP8L�  /?����m��������_"�0@��^�"�v��s�}� �W��<f��Yn#I������wO���M`ҋ���N��m:�
��{-�4b7DԧQ��A �B�P��*B��v��
Q�-����^R�D���!(����T�B�*�*���%E["��M�\͆B�@�U$R�l)���{�B���@%P����g*Ųs�TP��a��dD
�6�9�UR�s����1ʲ�X�!�Ha�ߛ�$��N����i�a΁}c Rm��1��Q�c���fdB�5������J˚>>���s1��}����>����Y��?�TEDױ���s���\�T���4D����]ׯ�(aD��Ѓ!�a'\�G(��$+c$�|'�>����/B��c�v��_oH���9(l�fH������8��vV�m�^�|�m۶m�����q���k2�='���:_>��������á����-wӷU�x�˹�fa���������ӭ�M���SƷ7������|��v��v���m�d���ŝ,��L��Y��ݛ�X�\֣� ���{�#3���
�6������t`�
��t�4O��ǎ%����u[B�����O̲H��o߾��$���f���� �H��\��� �kߡ}�~$�f���N\�[�=�'��Nr:a���si����(9Lΰ���=����q-��W��LL%ɩ	��V����R)�=jM����d`�ԙHT�c���'ʦI��DD�R��C׶�&����|t Sw�|WV&�^��bt5WW,v�Ş�qf���+���Jf�t�s�-BG�t�"&�Ɗ����׵�Ջ�KL�2)gD� ���� NEƋ�R;k?.{L�$�y���{'��`��ٟ��i��{z�5��i������c���Z^�
h�+U�mC��b��J��uE�c�����h��}{�����i�'�9r�����ߨ򅿿��hR�Mt�Rb���C�DI��iZ�6i"�DN�3���J�zڷ#oL����Q �W��D@!'��;�� D*�K�J�%"�0�����pZԉO�A��b%�l�#��$A�W�A�*^i�$�%a��rvU5A�ɺ�'a<��&�DQ��r6ƈZC_B)�N�N(�����(z��y�&H�ض^��1Z4*,RQjԫ׶c����yq��4���?�R�����0�6f2Il9j��ZK�4���է�0؍è�ӈ�Uq�3�=[vQ�d$���±eϘA�����R�^��=%:�G�v��)�ǖ/��RcO���z .�ߺ��S&Q����o,X�`�����|��s�<3Z��lns'���vw���Y��>V����G�nuk:��5�U.�v��|����W���Z���4�@U3U�������|�r�?;�
         [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
              [gd_resource type="Theme" load_steps=3 format=2]

[ext_resource path="res://font/codeman38_press-start-2p/PressStart2P.ttf" type="DynamicFontData" id=1]

[sub_resource type="DynamicFont" id=1]
font_data = ExtResource( 1 )

[resource]
default_font = SubResource( 1 )
      [remap]

path="res://Cloud.gdc"
[remap]

path="res://Floor.gdc"
[remap]

path="res://Main.gdc"
 [remap]

path="res://Obstacles/Obstacle.gdc"
   [remap]

path="res://Player.gdc"
               �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx��ytTU��?�ի%���@ȞY1JZ �iA�i�[P��e��c;�.`Ow+4�>�(}z�EF�Dm�:�h��IHHB�BR!{%�Zߛ?��	U�T�
���:��]~�������-�	Ì�{q*�h$e-
�)��'�d�b(��.�B�6��J�ĩ=;���Cv�j��E~Z��+��CQ�AA�����;�.�	�^P	���ARkUjQ�b�,#;�8�6��P~,� �0�h%*QzE� �"��T��
�=1p:lX�Pd�Y���(:g����kZx ��A���띊3G�Di� !�6����A҆ @�$JkD�$��/�nYE��< Q���<]V�5O!���>2<��f��8�I��8��f:a�|+�/�l9�DEp�-�t]9)C�o��M~�k��tw�r������w��|r�Ξ�	�S�)^� ��c�eg$�vE17ϟ�(�|���Ѧ*����
����^���uD�̴D����h�����R��O�bv�Y����j^�SN֝
������PP���������Y>����&�P��.3+�$��ݷ�����{n����_5c�99�fbסF&�k�mv���bN�T���F���A�9�
(.�'*"��[��c�{ԛmNު8���3�~V� az
�沵�f�sD��&+[���ke3o>r��������T�]����* ���f�~nX�Ȉ���w+�G���F�,U�� D�Դ0赍�!�B�q�c�(
ܱ��f�yT�:��1�� +����C|��-�T��D�M��\|�K�j��<yJ, ����n��1.FZ�d$I0݀8]��Jn_� ���j~����ցV���������1@M�)`F�BM����^x�>
����`��I�˿��wΛ	����W[�����v��E�����u��~��{R�(����3���������y����C��!��nHe�T�Z�����K�P`ǁF´�nH啝���=>id,�>�GW-糓F������m<P8�{o[D����w�Q��=N}�!+�����-�<{[���������w�u�L�����4�����Uc�s��F�륟��c�g�u�s��N��lu���}ן($D��ת8m�Q�V	l�;��(��ڌ���k�
s\��JDIͦOzp��مh����T���IDI���W�Iǧ�X���g��O��a�\:���>����g���%|����i)	�v��]u.�^�:Gk��i)	>��T@k{'	=�������@a�$zZ�;}�󩀒��T�6�Xq&1aWO�,&L�cřT�4P���g[�
p�2��~;� ��Ҭ�29�xri� ��?��)��_��@s[��^�ܴhnɝ4&'
��NanZ4��^Js[ǘ��2���x?Oܷ�$��3�$r����Q��1@�����~��Y�Qܑ�Hjl(}�v�4vSr�iT�1���f������(���A�ᥕ�$� X,�3'�0s����×ƺk~2~'�[�ё�&F�8{2O�y�n�-`^/FPB�?.�N�AO]]�� �n]β[�SR�kN%;>�k��5������]8������=p����Ցh������`}�
�J�8-��ʺ����� �fl˫[8�?E9q�2&������p��<�r�8x� [^݂��2�X��z�V+7N����V@j�A����hl��/+/'5�3�?;9
�(�Ef'Gyҍ���̣�h4RSS� ����������j�Z��jI��x��dE-y�a�X�/�����:��� +k�� �"˖/���+`��],[��UVV4u��P �˻�AA`��)*ZB\\��9lܸ�]{N��礑]6�Hnnqqq-a��Qxy�7�`=8A�Sm&�Q�����u�0hsPz����yJt�[�>�/ޫ�il�����.��ǳ���9��
_
��<s���wT�S������;F����-{k�����T�Z^���z�!t�۰؝^�^*���؝c
���;��7]h^
��PA��+@��gA*+�K��ˌ�)S�1��(Ե��ǯ�h����õ�M�`��p�cC�T")�z�j�w��V��@��D��N�^M\����m�zY��C�Ҙ�I����N�Ϭ��{�9�)����o���C���h�����ʆ.��׏(�ҫ���@�Tf%yZt���wg�4s�]f�q뗣�ǆi�l�⵲3t��I���O��v;Z�g��l��l��kAJѩU^wj�(��������{���)�9�T���KrE�V!�D���aw���x[�I��tZ�0Y �%E�͹���n�G�P�"5FӨ��M�K�!>R���$�.x����h=gϝ�K&@-F��=}�=�����5���s �CFwa���8��u?_����D#���x:R!5&��_�]���*�O��;�)Ȉ�@�g�����ou�Q�v���J�G�6�P�������7��-���	պ^#�C�S��[]3��1���IY��.Ȉ!6\K�:��?9�Ev��S]�l;��?/� ��5�p�X��f�1�;5�S�ye��Ƅ���,Da�>�� O.�AJL(���pL�C5ij޿hBƾ���ڎ�)s��9$D�p���I��e�,ə�+;?�t��v�p�-��&����	V���x���yuo-G&8->�xt�t������Rv��Y�4ZnT�4P]�HA�4�a�T�ǅ1`u\�,���hZ����S������o翿���{�릨ZRq��Y��fat�[����[z9��4�U�V��Anb$Kg������]������8�M0(WeU�H�\n_��¹�C�F�F�}����8d�N��.��]���u�,%Z�F-���E�'����q�L�\������=H�W'�L{�BP0Z���Y�̞���DE��I�N7���c��S���7�Xm�/`�	�+`����X_��KI��^��F\�aD�����~�+M����ㅤ��	SY��/�.�`���:�9Q�c �38K�j�0Y�D�8����W;ܲ�pTt��6P,� Nǵ��Æ�:(���&�N�/ X��i%�?�_P	�n�F�.^�G�E���鬫>?���"@v�2���A~�aԹ_[P, n��N������_rƢ��    IEND�B`�       ECFG      application/config/name         Pachicefalosaurus      application/run/main_scene         res://Main.tscn "   application/boot_splash/show_image              application/boot_splash/bg_color      ��w?��w?��w?  �?   application/config/icon         res://icon.png     display/window/stretch/mode         viewport   display/window/stretch/aspect         keep+   gui/common/drop_mouse_on_gui_input_disabled         
   input/jumpd              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode          physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            InputEventMouseButton         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           button_mask           position              global_position               factor       �?   button_index         pressed           doubleclick           script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index          pressure          pressed           script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   W      physical_scancode             unicode           echo          script         input/go_down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   S      physical_scancode             unicode           echo          script      )   physics/common/enable_pause_aware_picking         $   rendering/quality/driver/driver_name         GLES2   (   rendering/2d/snapping/use_gpu_pixel_snap         %   rendering/vram_compression/import_etc         &   rendering/vram_compression/import_etc2          )   rendering/environment/default_clear_color      ��w?��w?��w?  �?)   rendering/environment/default_environment          res://default_env.tres        