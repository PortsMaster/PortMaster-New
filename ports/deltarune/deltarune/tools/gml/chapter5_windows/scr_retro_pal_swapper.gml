function pal_swap_init_system(arg0, arg1, arg2)
{
    var _swapper = 
    {
        shader: -4,
        html5: false,
        html5_sprite: -4,
        html5_surface: -4,
        texel_size: [0],
        uvs: [0],
        index: [0],
        texture: [0],
        layer_priority: 0,
        layer_temp_priority: 0,
        layer_map: 0,
        
        cleanup: function()
        {
            ds_priority_destroy(layer_priority);
            ds_priority_destroy(layer_temp_priority);
            ds_map_destroy(layer_map);
        }
    };
    _swapper.html5 = false;
    
    if (!_swapper.html5)
    {
        _swapper.shader = arg0;
        _swapper.texel_size[0] = shader_get_uniform(arg0, "u_pixelSize");
        _swapper.uvs[0] = shader_get_uniform(arg0, "u_Uvs");
        _swapper.index[0] = shader_get_uniform(arg0, "u_paletteId");
        _swapper.texture[0] = shader_get_sampler_index(arg0, "u_palTexture");
    }
    else
    {
        if (arg1 == undefined || arg2 == undefined)
        {
            show_message("Must provide pal_swap_init_system() with 2 additional arguments for HTML5 Compatible Sprite and Surface Shaders");
            game_end();
        }
        
        _swapper.html5_sprite = arg1;
        _swapper.html5_surface = arg2;
        _swapper.texel_size[1] = shader_get_uniform(arg1, "u_pixelSize");
        _swapper.uvs[1] = shader_get_uniform(arg1, "u_Uvs");
        _swapper.index[1] = shader_get_uniform(arg1, "u_paletteId");
        _swapper.texture[1] = shader_get_sampler_index(arg1, "u_palTexture");
        _swapper.texel_size[2] = shader_get_uniform(arg2, "u_pixelSize");
        _swapper.uvs[2] = shader_get_uniform(arg2, "u_Uvs");
        _swapper.index[2] = shader_get_uniform(arg2, "u_paletteId");
        _swapper.texture[2] = shader_get_sampler_index(arg2, "u_palTexture");
    }
    
    _swapper.layer_priority = ds_priority_create();
    _swapper.layer_temp_priority = ds_priority_create();
    _swapper.layer_map = ds_map_create();
    global.retro_pal_swapper = _swapper;
}

function pal_swap_set(arg0, arg1, arg2)
{ /*
    var _swapper = global.retro_pal_swapper;
    
    if (arg1 == 0)
        exit;
    
    var _mode = 0;
    
    if (!arg2)
    {
        if (_swapper.html5)
        {
            shader_replace_simple_set_hook(_swapper.html5_sprite);
            _mode = 1;
        }
        else
        {
            shader_replace_simple_set_hook(_swapper.shader);
        }
        
        var _tex = sprite_get_texture(arg0, 0);
        var _UVs = sprite_get_uvs(arg0, 0);
        texture_set_stage(_swapper.texture[_mode], _tex);
        var _texel_x = texture_get_texel_width(_tex);
        var _texel_y = texture_get_texel_height(_tex);
        var _texel_hx = _texel_x * 0.5;
        var _texel_hy = _texel_y * 0.5;
        shader_set_uniform_f(_swapper.texel_size[_mode], _texel_x, _texel_y);
        shader_set_uniform_f(_swapper.uvs[_mode], _UVs[0] + _texel_hx, _UVs[1] + _texel_hy, _UVs[2], _UVs[3]);
        shader_set_uniform_f(_swapper.index[_mode], arg1);
    }
    else
    {
        if (_swapper.html5)
        {
            shader_replace_simple_set_hook(_swapper.html5_surface);
            _mode = 2;
        }
        else
        {
            shader_replace_simple_set_hook(_swapper.shader);
        }
        
        var _tex = surface_get_texture(arg0);
        texture_set_stage(_swapper.texture[_mode], _tex);
        var _texel_x = texture_get_texel_width(_tex);
        var _texel_y = texture_get_texel_height(_tex);
        var _texel_hx = _texel_x * 0.5;
        var _texel_hy = _texel_y * 0.5;
        shader_set_uniform_f(_swapper.texel_size[_mode], _texel_x, _texel_y);
        shader_set_uniform_f(_swapper.uvs[_mode], _texel_hx, _texel_hy, 1 + _texel_hx, 1 + _texel_hy);
        shader_set_uniform_f(_swapper.index[_mode], arg1);
    }
	*/
}

function pal_swap_reset()
{
    if (shader_current() != -1)
        shader_replace_simple_reset_hook();
}

function pal_swap_layer_init()
{
    ds_map_clear(global.retro_pal_swapper.layer_map);
    ds_priority_clear(global.retro_pal_swapper.layer_priority);
    ds_priority_clear(global.retro_pal_swapper.layer_temp_priority);
}

function pal_swap_set_layer(arg0, arg1, arg2, arg3)
{
    var _data = ds_map_find_value(global.retro_pal_swapper.layer_map, arg2);
    
    if (_data == undefined)
        exit;
    
    ds_map_set(global.retro_pal_swapper.layer_map, arg2, 
    {
        sprite: arg0,
        index: arg1,
        is_surf: arg3
    });
}

function pal_swap_enable_layer(arg0)
{
    if (!layer_exists(arg0))
        exit;
    
    var _data = 
    {
        sprite: undefined,
        index: undefined,
        is_surf: undefined
    };
    layer_script_begin(arg0, function()
    {
        if (event_type == ev_draw)
        {
            var _id = ds_priority_delete_min(global.retro_pal_swapper.layer_priority);
            var _data = ds_map_find_value(global.retro_pal_swapper.layer_map, _id);
            
            if (_data == "<undefined>")
                exit;
            
            pal_swap_set(_data.sprite, _data.index, _data.is_surf);
            ds_priority_add(global.retro_pal_swapper.layer_temp_priority, _id, layer_get_depth(_id));
        }
    });
    layer_script_end(arg0, function()
    {
        if (event_type == ev_draw)
        {
            pal_swap_reset();
            
            if (ds_priority_empty(global.retro_pal_swapper.layer_priority))
            {
                ds_priority_copy(global.retro_pal_swapper.layer_priority, global.retro_pal_swapper.layer_temp_priority);
                ds_priority_clear(global.retro_pal_swapper.layer_temp_priority);
            }
        }
    });
    ds_map_set(global.retro_pal_swapper.layer_map, arg0, _data);
    ds_priority_add(global.retro_pal_swapper.layer_priority, arg0, layer_get_depth(arg0));
}
