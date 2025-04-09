--forbidden
texture = "pexplosion";
--FunctionName = "CreateSprite";

z = 0.999;

start_color = { 1.0, 1, 1, 1.0 };
var_color = { 0.1, 0.1, 0.1, 0.0 };
end_color = { 1, 1, 1, 1.0 };

max_particles = 10;
particle_life_min = 5;
particle_life_max = 25;

start_size = 64.0;
size_variability = 20.0;
end_size = 64.0;

particle_life = 5;
particle_life_var = 2;

system_life = 2;
emission = 10;
particle_min_speed = 8;
particle_max_speed = 15;
particle_min_angle = 0;
particle_max_angle = 360;
particle_min_param = 0;
particle_max_param = 2*3.1415;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttLine;
trajectory_param1 = 0.1;
trajectory_param2 = 0;
affected_by_wind = 0;
gravity_x = 0;
gravity_y = 0;