--forbidden
texture = "pliquid";

z = 0.4;

start_color = { 42/255, 153/255, 7/255, 1.0 };
var_color = { 0, 0, 0.1, 0.0 };
end_color = { 42/255, 153/255, 7/255, 1.0 };

max_particles = 10;
particle_life_min = 5;
particle_life_max = 25;

start_size = 32.0;
size_variability = 16.0;
end_size = 5.0;

particle_life = 10;
particle_life_var = 1;

system_life = 8;
emission = 10;
particle_min_speed = 4;
particle_max_speed = 12;
particle_min_angle = 0;
particle_max_angle = 360;
particle_min_param = 0;
particle_max_param = 2*3.1415;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttLine;
trajectory_param1 = 0.1;
trajectory_param2 = 0;
affected_by_wind = 1;
gravity_x = 0;
gravity_y = 1;
