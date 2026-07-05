if (!cam_update)
{
    camy = camera_get_view_y(view_camera[0]);
    finalheight = round(height - (camy / 2));
    cam_update = true;
}

var _mid = fixed_position ? 320 : x;
var _height = round_to_multiple(finalheight, 2);
var _rot = round_to_multiple(rotation, 2);
debug_print_persistent("h", string(height));
debug_print_persistent("r", string((rotation + 360) % 360));
var _flowery = i_ex(obj_flowery_enemy);
var _top = cameray() - 120;
var _ratio = 3;
var _xs = 120;
var _circ = _xs * _ratio;
var _ys = 360;
var _hs = _ys / 2;
var _scaling = 2;
var _speed = floor(max((point_distance(0, 0, obj_flowery_towery.final_rise, obj_flowery_towery.final_spin) / 5) - 2, 0));

if (!surface_exists(tower_surface[0]))
{
    var _sl = 0;
    
    if (depth_map || true)
    {
        layers = 20;
        //shader_replace_simple_set_hook(mapshader);
        shader_set_uniform_f(u_top, 1);
        shader_set_uniform_f(u_thickness, 1);
        shader_set_uniform_f(u_modifier, 1);
        
        for (i = 0; i < layers; i++)
        {
            tower_surface[i] = surface_create(_circ, _ys);
            surface_set_target(tower_surface[i]);
            draw_clear_alpha(c_black, 0);
            
            if (i == (layers - 1) && depth_map)
            {
                shader_replace_simple_reset_hook();
                draw_sprite_tiled_ext(spr_towery_vines, 1, 0, 0, 1, 1, #99BB99, 1);
            }
            else
            {
                draw_sprite_tiled_ext(spr_towery_vines_depth, 0, 0, 0, 1, 1, #99BB99, 1);
            }
            
            shader_set_uniform_f(u_top, 1 - (i * (1 / layers)));
            surface_reset_target();
            _sl++;
        }
        
        shader_replace_simple_reset_hook();
    }
    
    if (!depth_map)
    {
        var _sprite = spr_towery_vines;
        var _skip = 1;
        var _true_layers = sprite_get_number(_sprite) - _skip;
        var _layer_thickness = 1;
        layers += ((_true_layers - _skip) * _layer_thickness);
        
        for (i = 0; i < _true_layers; i++)
        {
            repeat (_layer_thickness)
            {
                tower_surface[_sl] = surface_create(_circ, _ys);
                surface_set_target(tower_surface[_sl]);
                draw_clear_alpha(c_black, 0);
                draw_sprite_tiled_ext(_sprite, i + _skip, 0, 0, 1, 1, #99BB99, 1);
                surface_reset_target();
                _sl++;
            }
        }
    }
}

if (!surface_exists(tower_front))
    tower_front = surface_create(_xs * _scaling, _ys * _scaling);

if (!surface_exists(tower_back))
    tower_back = surface_create(_xs * _scaling, _ys * _scaling);

if (!surface_exists(final_surface))
    final_surface = surface_create(_xs * _scaling, _ys * _scaling);

var _hcirc = _circ / (1 + (1 / _ratio));

if (room == room_plat_lab && keyboard_check_pressed(vk_space))
{
    draw_set_color(make_color_hsv(random(255), 128, 128));
    draw_set_alpha(1);
    var _size = random_range(5, 15);
    gpu_set_colourwriteenable(true, true, true, false);
    var _yoff = irandom_range(-20, 20);
    var _xoff = irandom_range(-20, 20);
    var _xx = (((rotation / 360) * _circ) + _hcirc + _xoff) % _circ;
    var _yy = _ys - ((finalheight + _hs + _yoff) % _ys);
    
    for (i = 0; i < layers; i++)
    {
        surface_set_target(tower_surface[i]);
        draw_circle(_xx, _yy, _size, false);
        draw_circle(_xx + _circ, _yy, _size, false);
        draw_circle(_xx - _circ, _yy, _size, false);
        draw_circle(_xx, _yy + _ys, _size, false);
        draw_circle(_xx, _yy - _ys, _size, false);
        surface_reset_target();
        
        if (i == 0)
            gpu_set_colourwriteenable(true, true, true, false);
    }
    
    gpu_set_colourwriteenable(true, true, true, true);
    snd_play_pitch(snd_splat, 0.8 + ((_size - 5) / 20));
}

var uv_mode = 0;
var _left = ((_circ / 2) - (_xs / 2)) + (1 / _xs);
var ss = 0.9;
var _midmid = (_xs / 2) * _scaling;
var _thickness = 2 / (_xs * _scaling);
_rot = rotation / 360;
//shader_replace_simple_set_hook(shader);
shader_set_uniform_f(u_rotation, scr_loop(_rot + 0.5, 1));
shader_set_uniform_f(u_texel, _circ, _ys);
shader_set_uniform_f(u_height, finalheight / _ys / _scaling);
shader_set_uniform_f(u_scale, _ratio);
shader_set_uniform_i(u_face, 0);
shader_set_uniform_f(u_blendCol, color_get_red(towerCol) / 255, color_get_green(towerCol) / 255, color_get_blue(towerCol) / 255);
scale_y = 0.5;

if ((beat_timer % 25) == 0)
{
}

beat_timer++;
horizon = 0.35;
scale_y = 0;

if (beat > 0)
    beat -= 0.2;

surface_set_target(tower_back);
draw_clear_alpha(c_black, 0);

for (i = 0; i < layers; i++)
{
    var _scale = _scaling - (i * _thickness);
    var _yscale = lerp(_scaling, _scale, scale_y);
    var _ypos = round(_ys * (_scaling - _scale) * scale_y * horizon);
    draw_surface_part_ext(tower_surface[i], _left, 0, _xs, _ys, _midmid - ((_xs / 2) * _scale), _ypos, _scale, _yscale, brightness, 1);
}

surface_reset_target();
surface_set_target(tower_front);
draw_clear_alpha(c_black, 0);
shader_set_uniform_f(u_rotation, _rot);
shader_set_uniform_i(u_face, 1);
var i = layers - 1;

while (i >= 0)
{
    var _scale = _scaling - (i * _thickness);
    var _yscale = lerp(_scaling, _scale, scale_y);
    var _ypos = _ys * (_scaling - _scale) * scale_y * horizon;
    draw_surface_part_ext(tower_surface[i], _left, 0, _xs, _ys, _midmid - ((_xs / 2) * _scale), _ypos, _scale, _yscale, brightness, 1);
    i--;
}

surface_reset_target();
shader_replace_simple_reset_hook();
var _sc = 2 / _scaling;
gpu_set_fog(true, outlineCol, 0, 1);
draw_surface_ext(tower_front, _mid - _xs - 2, _top, _sc, _sc, 0, outlineCol, 1);
draw_surface_ext(tower_front, (_mid - _xs) + 2, _top, _sc, _sc, 0, outlineCol, 1);
draw_surface_ext(tower_back, (_mid + _xs) - 2, _top, -_sc, _sc, 0, outlineCol, 1);
draw_surface_ext(tower_back, _mid + _xs + 2, _top, -_sc, _sc, 0, outlineCol, 1);
gpu_set_fog(false, outlineCol, 0, 1);
draw_surface_ext(tower_back, _mid + _xs, _top, -_sc, 1, 0, c_white, 1);
draw_surface_ext(tower_front, _mid - _xs, _top, 1, 1, 0, c_white, 1);

if (!(i_ex(obj_orangeheart) && obj_orangeheart.hitstop > 0))
    siner++;
