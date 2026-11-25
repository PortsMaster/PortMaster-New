function area_add_culling_obj_list()
{
    var areaList = ds_list_create();
    instance_place_list(x, y, 36, areaList, 0);
    
    for (var i = 0; i < ds_list_size(areaList); i++)
    {
        var ins = ds_list_find_value(areaList, i);
        ds_list_add(ins.objects, id);
    }
    
    ds_list_destroy(areaList);
}

function area_check_active()
{
    if (!place_meeting(x, y, oBasePlayer))
        exit;
    
    for (var i = 0; i < ds_list_size(objects); i++)
    {
        var obj = ds_list_find_value(objects, i);
        instance_activate_object(obj);
        
        if (!instance_exists(obj))
            throw debug_get_obj_param_text();
        
        obj.Active();
    }
}

function area_check_deactive()
{
    if (place_meeting(x, y, oBasePlayer))
        exit;
    
    for (var i = 0; i < ds_list_size(objects); i++)
    {
        var obj = ds_list_find_value(objects, i);
        instance_deactivate_object(obj);
        obj.Deactive();
    }
}
