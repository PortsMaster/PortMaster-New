--forbidden
texture = "pdust2";
--FunctionName = "CreateSprite";

z = -0.1;

start_color = { 67/255, 57/255, 79/255, .1 };
var_color = { 0.1, 0.1, 0.1, 0.0 };
end_color = { 0, 0, 0, 1.0 };

max_particles = 10;
particle_life_min = 5;
particle_life_max = 15;

start_size = 32.0;
size_variability = 10.0;
end_size = 32.0;

particle_life = 5;
particle_life_var = 2;

system_life = -1;
emission = 10;
particle_min_speed = 1;
particle_max_speed = 2;
particle_min_angle = -180;
particle_max_angle = 0;
particle_min_param = 0;
particle_max_param = 2;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttRandom;
trajectory_param1 = 2;
trajectory_param2 = 1;
affected_by_wind = 1;
gravity_x = 0;
gravity_y = 0;