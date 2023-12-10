--forbidden
texture = "psnow";
--FunctionName = "CreateSprite";

z = 0.4;

start_color = { 1.0, 1, 1, 1.0 };
var_color = { 0.1, 0.1, 0.1, 0.0 };
end_color = { 0.9, 0.9, 1, 1.0 };

max_particles = 1300;

start_size = 6.0;
size_variability = 3.0;
end_size = 6.0;

particle_life = 120;
particle_life_var = 0;

system_life = -1;
emission = 10;
particle_min_speed = 0;
particle_max_speed = 3;
particle_min_angle = 135;
particle_max_angle = 45;
particle_min_param = 90;
particle_max_param = 2;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttSine;
trajectory_param1 = 2;
trajectory_param2 = 5;
affected_by_wind = 1;
gravity_x = 0;
gravity_y = 0.02;
