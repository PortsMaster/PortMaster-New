--forbidden
texture = "pleaf";
--FunctionName = "CreateSprite";

z = 0.4;

start_color = { 1.0, 1, 1, 1.0 };
var_color = { 0.1, 0.1, 0.1, 0.0 };
end_color = { 1, 1, 1, 1.0 };

max_particles = 5;
particle_life_min = 20;
particle_life_max = 35;

start_size = 7.0;
size_variability = 3.0;
end_size = 7.0;

particle_life = 20;
particle_life_var = 5;

system_life = -1;
emission = 1;
particle_min_speed = 2;
particle_max_speed = 8;
particle_min_angle = 0;
particle_max_angle = 90;
particle_min_param = 90;
particle_max_param = 2;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttLine;
trajectory_param1 = 2;
trajectory_param2 = 1;
affected_by_wind = 1;
gravity_x = 0;
gravity_y = 0.3;