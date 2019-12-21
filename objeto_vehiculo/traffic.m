clearvars -EXCEPT music
close all
clc

% Music
play_music = 0;
if play_music
    if exist('music')
        play(music)
    else
        [mdata, fs] = audioread('Grinspoon-Champion.mp3');
        music = audioplayer(mdata, fs);
        play(music)
    end
end

% Initialization
time_step = 1;
duration = 100;
acceleration = [0.1 0];
velocity = [0 0];
max_velocity = [60 60];
n_horz_veh = 10;
n_vert_veh = 10;
h_horz_veh = zeros(6, n_horz_veh);
h_vert_veh = zeros(6, n_vert_veh);
traffic_lights = 1;
n_obj = n_horz_veh + n_vert_veh + traffic_lights;
location_matrix = zeros(n_obj, 6); %xpos, ypos, xvel, yvel, xobs?, yobs?
id = 1;

% Graphical Interface
h_fig = figure(1);
set(h_fig, 'Position', [4 80 1800 720], 'Color', [0.9 0.9 0.9])
subplot(2,1,1)
h_traffic_light = traffic_light_init(100, 10, 0);
for n = 1:n_horz_veh
    h_horz_veh(:,n) = vehicle_init(0, 10, 20, 'right', rand(1,3));
    location_matrix(id,:) = [0; 10; 0; 0; 0; 0];
    id = id + 1;
end
for n = 1:n_vert_veh
    h_vert_veh(:,n) = vehicle_init(100, 100, 20, 'down', rand(1,3));
    location_matrix(id,:) = [100; 100; 0; 0; 0; 0];
    id = id + 1;
end
axis([0,1000,0,200])
set(gca, 'XMinorTick', 'on', 'TickDir', 'out', 'Position', [0.03 0.55 0.96 0.42])
subplot(2,1,2)
h_velcty = plot(0:time_step:duration, (0:time_step:duration)*NaN, 'g');
set(gca, 'XMinorTick', 'on', 'Position', [0.03 0.06 0.96 0.42], 'Color', [0 0 0])
axis([0,duration,0,60])

% http://www.batesville.k12.in.us/physics/phynet/mechanics/kinematics/BrakingDistData.html

plot_velcty = zeros(1, length((0:time_step:duration)))*NaN;
s = 1;
for t = 0:time_step:duration
    [delta, v] = vehicle_dynamics([0 0], velocity, acceleration, time_step);
    velocity = v;
    h_horz_veh(:,1) = vehicle_position_update(h_horz_veh(:,1), delta(1), delta(2));
    plot_velcty(s) = v(1); s = s + 1;
    set(h_velcty, 'YData', plot_velcty)
    drawnow %pause(time_step/10)
end

    