--forbidden
texture = "pblood2";
--FunctionName = "CreateSprite";

z = 0.6;

start_color = { 1.0, 1, 1, 1.0 };
var_color = { 0.1, 0.1, 0.1, 0.0 };
end_color = { 1, 1, 1, 1.0 };

max_particles = 32;
particle_life_min = 5;
particle_life_max = 15;

start_size = 32.0;
size_variability = 10.0;
end_size = 32.0;

particle_life = 5;
particle_life_var = 2;

system_life = 2;
emission = 5;
particle_min_speed = 1;
particle_max_speed = 5;
particle_min_angle = 0;
particle_max_angle = 360;
particle_min_param = 0;
particle_max_param = 2;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttLine;
trajectory_param1 = 2;
trajectory_param2 = 1;
affected_by_wind = 1;
gravity_x = 0;
gravity_y = -0.1;