--forbidden
name = "pblood-wound";
--texture = "pblood";
--FunctionName = "CreateSprite";

z = 0.999;

start_color = { 1.0, 0.1, 0.1, 1.0 };
var_color = { 0.2, 0.0, 0.0, 0.0 };
end_color = { 0.2, 0.15, 0.1, 1.0 };

max_particles = 50;
particle_life_min = 10;
particle_life_max = 30;

start_size = 1.0;
size_variability = 0.5;
end_size = 0.1;

particle_life = 3;
particle_life_var = 2;

system_life = 2;
emission = 10;
particle_min_speed = 5;
particle_max_speed = 10;
particle_min_angle = 0;
particle_max_angle = 360;
particle_min_param = 0;
particle_max_param = 3;
particle_min_trace = 1;
particle_max_trace = 3;
trajectory_type = constants.pttLine;
trajectory_param1 = 90;
trajectory_param2 = 8;
affected_by_wind = 1;
gravity_x = 0;
gravity_y = 0.3;