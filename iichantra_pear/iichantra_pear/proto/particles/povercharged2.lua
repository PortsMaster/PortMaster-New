--forbidden
texture = "pexplosionblue";
--FunctionName = "CreateSprite";

z = 0.999;

start_color = { 1.0, 1, 1, 1.0 };
var_color = { 0.1, 0.1, 0.1, 0.0 };
end_color = { 1, 1, 1, 1.0 };

max_particles = 64;
particle_life_min = 5;
particle_life_max = 25;

start_size = 10.0;
size_variability = 5.0;
end_size = 15.0;

particle_life = 2;
particle_life_var = 1;

system_life = -1;
emission = 3;
particle_min_speed = 8;
particle_max_speed = 15;
particle_min_angle = 0;
particle_max_angle = 360;
particle_min_param = 0;
particle_max_param = 2*3.1415;
particle_min_trace = 0;
particle_max_trace = 0;
trajectory_type = constants.pttTwist;
trajectory_param1 = 1;
trajectory_param2 = 0;
affected_by_wind = 0;
gravity_x = 0;
gravity_y = 0;