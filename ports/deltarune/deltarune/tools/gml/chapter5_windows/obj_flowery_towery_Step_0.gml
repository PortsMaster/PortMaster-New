var _debug_room = room == room_plat_lab;

if (_debug_room && sunkus_kb_check_pressed(ord("R")) && !sunkus_kb_check(vk_backspace))
{
    snd_free_all();
    room_restart();
    global.interact = 0;
}

if (!init)
{
    camylast = cameray();
    
    if (i_ex(obj_flowery_enemy))
        party_hp = global.hp[0] + global.hp[1] + global.hp[2];
    
    init = true;
    
    if (!_debug_room && !i_ex(obj_flowery_enemy) && !i_ex(obj_rotating_tower_controller_new))
        spin = 0;
}

if (i_ex(pillars))
    pillars.depth = depth + 40;

if (knockback != 0)
    knockback = scr_movetowards(knockback, 0, 0.5 + (extraspin / 20));

rotation = scr_loop(rotation, 360);

with (pillars)
{
    rotation = other.rotation;
    height = other.height;
}

if (i_ex(obj_flowery_enemy))
{
    var _new_hp = global.hp[0] + global.hp[1] + global.hp[2];
    
    if (_new_hp < party_hp)
        var _dif = party_hp - _new_hp;
    
    party_hp = _new_hp;
    
    if (i_ex(obj_orangeheart) && obj_orangeheart.dashstate >= 2)
        extraspin = 5;
    else
        extraspin = scr_movetowards(extraspin, i_ex(obj_orangeheart) ? 1 : 0, 0.5);
}

if (i_ex(obj_orangeheart) && obj_orangeheart.hitstop > 0)
    exit;

var _spinplus = extraspin + max(-20, knockback);
final_spin = spin + _spinplus;

if (halt)
    final_spin = 0;

rotation += final_spin;
final_rise = rise * ((spin / 2) + (_spinplus / 10));
height += final_rise;
var _rot = -80;

if (petals)
{
    if (spawner >= 4)
    {
        with (instance_create(x, y, obj_towery_particle))
        {
            rotation = _rot;
            radius = 200;
            sprite_index = spr_bush_leaf_gold;
        }
        
        spawner = 0;
    }
    else
    {
        spawner++;
    }
}

var _climb = room == room_dw_fcastle_flowerclimb;

if (_climb || (i_ex(obj_flowery_enemy) && petal_con == 0))
{
    var _camy = cameray();
    var _freq = 10;
    
    if (_climb)
        _freq = round(clamp(remap(11000, 3000, 9, 1, _camy), 1, 9)) * 10;
    
    if ((petal_timer <= 40 || _climb) && (petal_timer % _freq) == 0)
    {
        var _petal_count = 1 + bonus_petals;
        
        repeat (1 + bonus_petals)
        {
            with (instance_create(x, _camy - (_petal_count * 10) - 10, obj_towery_particle))
            {
                rotation = random(360);
                
                if (_climb && _freq > 10)
                {
                    rotation = random(360 - _freq);
                    
                    if (rotation > (scr_loop((360 - other.rotation) + 180, 360) - (_freq / 2)))
                        rotation += _freq;
                }
                
                radius = 200;
                var _flowerycon = 0;
                
                if (i_ex(obj_flowery_enemy))
                    _flowerycon = obj_flowery_enemy.phase;
                
                if (!_climb && (other.petal_timer % 20) == 10 && _flowerycon >= 3 && _flowerycon <= 5)
                {
                    sprite_index = choose(spr_bush_leaf_colorless, spr_bush_leaf2_colorless, spr_bush_leaf3_colorless);
                    var _col = (_flowerycon - 3) * 2;
                    
                    if (other.petal_timer == 30)
                        _col++;
                    
                    if (_col == 0)
                    {
                        base_color = 10766755;
                        secondary_color = 8388736;
                    }
                    else if (_col == 1)
                    {
                        base_color = 16776960;
                        secondary_color = 12876650;
                    }
                    else if (_col == 2)
                    {
                        base_color = 5077241;
                        secondary_color = 2372452;
                    }
                    else if (_col == 3)
                    {
                        base_color = 6877911;
                        secondary_color = 32768;
                    }
                    else if (_col == 4)
                    {
                        base_color = 65535;
                        secondary_color = 9777767;
                    }
                    else if (_col == 5)
                    {
                        base_color = 15425616;
                        secondary_color = 16711680;
                    }
                    
                    overlay = true;
                }
                else
                {
                    sprite_index = choose(spr_bush_leaf_gold, spr_bush_leaf2_gold, spr_bush_leaf3_gold);
                }
                
                count = 1;
                simple = true;
                velocity = random_range(-1, 1);
                height_speed = 2;
                lifetime = 200;
                radius = irandom_range(160, 200);
                height = 0;
                climb = _climb;
                
                if (_climb)
                    visible = false;
                
                image_alpha = 1;
                image_speed = 1/3;
            }
            
            _petal_count--;
        }
        
        bonus_petals = 0;
        
        if (petal_timer <= 0)
            petal_timer = _climb ? _freq : 40;
    }
    
    petal_timer--;
    
    if (_climb)
    {
        var _max = petal_timer % 10;
        var _dif = round((camylast - _camy) / 2);
        
        if (_dif >= 20)
            bonus_petals = floor(_dif / 10);
        
        petal_timer -= clamp(_dif, _max - 9, _max);
        camylast = _camy;
    }
}
