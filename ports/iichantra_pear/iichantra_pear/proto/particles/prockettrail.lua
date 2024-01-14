--forbidden
texture = "pspark";

z = 0.6;

start_color = { 0.8, 0.4, 0.0, 1.0 };
var_color = { 0.3, 0.3, 0.0, 0.0 };
end_color = { 0.0, 0.0, 0.0, 0.5 };

max_particles = 128;
particle_life_min = 1;
particle_life_max = 5;

start_size = 6.0;
size_variability = 2.0;
end_size = 8.0;

particle_life = 10;
particle_life_var = 1;

system_life = -1;
emission = 10;

particle_min_speed = 0;
particle_max_speed = 1;
particle_min_angle = 0;
particle_max_angle = 260;
particle_min_param = 0;
particle_max_param = 3;
trajectory_type = constants.pttRandom;
affected_by_wind = 0;