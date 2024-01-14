--forbidden
texture = "psmoke";

z = 0.6;

start_color = { 0.4, 0.4, 0.4, 1.0 };
var_color = { 0.0, 0.3, 0.0, 0.0 };
end_color = { 0.0, 0.0, 0.0, 0.5 };

max_particles = 16;
particle_life_min = 10;
particle_life_max = 15;

start_size = 4.0;
size_variability = 2.0;
end_size = 8.0;

particle_life = 5;
particle_life_var = 2;

system_life = -1;
emission = 2;

particle_min_speed = 10;
particle_max_speed = 15;
particle_min_angle = -100;
particle_max_angle = -80;
particle_min_param = 0;
particle_max_param = 3;
trajectory_type = constants.pttLine;
affected_by_wind = 1;