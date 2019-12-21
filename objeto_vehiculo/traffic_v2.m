clearvars -EXCEPT music
close all
clc

% Music
play_music = 0;
if play_music
    if exist('music') %#ok<UNRCH>
        play(music)
    else
        [mdata, fs] = audioread('Grinspoon-Champion.mp3');
        music = audioplayer(mdata, fs);
        play(music)
    end
end

% Initialization
intersection = [100 90];
time_step = 1;
duration = 140;
% acceleration = [0.1 0];
% velocity = [0 0];
max_velocity = [60 60];
n_horz_veh = 10;
n_vert_veh = 10;
h_horz_veh = zeros(6, n_horz_veh);
h_vert_veh = zeros(6, n_vert_veh);
traffic_lights = 1;
n_obj = n_horz_veh + n_vert_veh + traffic_lights;
h_objects = zeros(6, n_obj);
mainvars = zeros(8, n_obj); %xpos, ypos, xvel, yvel, xacc, yacc, xobs?, yobs?
id = 1;

% Graphical Interface
h_fig = figure(1);
set(h_fig, 'Position', [4 80 1800 360], 'Color', [0.9 0.9 0.9])
subplot(2,1,1)
h_traffic_light = traffic_light_init(intersection(1), intersection(2), 0);
mainvars(:,id) = [intersection(1); intersection(2); 0; 0; 0; 0; 0; 1];
id = id + 1;
for n = 1:n_horz_veh
    h_objects(:,id) = vehicle_init(0, intersection(2), 20, 'right', rand(1,3));
    mainvars(:,id) = [0; intersection(2); 0; 0; 0.1; 0; 1; 0];
    id = id + 1;
end
for n = 1:n_vert_veh
    h_objects(:,id) = vehicle_init(intersection(1), 0, 20, 'up', rand(1,3));
    mainvars(:,id) = [intersection(1); 0; 0; 0; 0; 0.1; 0; 1];
    id = id + 1;
end
axis([0, 1000, 0, intersection(1)])
set(gca, 'XMinorTick', 'on', 'TickDir', 'out', 'Position', [0.03 0.55 0.96 0.36])
subplot(2,1,2)
h_velcty = plot(0:time_step:duration, (0:time_step:duration)*NaN, 'g');
set(gca, 'XMinorTick', 'on', 'Position', [0.03 0.06 0.96 0.36], 'Color', [0 0 0])
axis([0, duration, 0, 60])

% http://www.batesville.k12.in.us/physics/phynet/mechanics/kinematics/BrakingDistData.html

plot_velcty = zeros(1, length((0:time_step:duration)))*NaN;
s = 1;
init_time = randi([1,40],[1,n_horz_veh+n_vert_veh])*time_step;
for t = 0:time_step:duration
    for car = 2:(n_horz_veh+n_vert_veh+1)
        if init_time(car - 1) < t
            [delta, v] = vehicle_dynamics(car, [0; 0], mainvars(3:4,car), mainvars(5:6,car), time_step, 0, 0);
            mainvars(1:2,car) = mainvars(1:2,car) + delta;
            mainvars(3:4,car) = v;
            h_objects(:,car) = vehicle_position_update(h_objects(:,car), delta(1), delta(2));
            
            %         plot_velcty(s) = v(1); s = s + 1;
            %         set(h_velcty, 'YData', plot_velcty)
            drawnow %pause(time_step/10)
        end
    end
end
