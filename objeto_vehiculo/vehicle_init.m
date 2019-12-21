function h_vehicle = vehicle_init(x, y, len, dir, vehicle_color) 
%vehicle_init Draws vehicle
%   x horizontal location
%   y vertical location
%   dir direction it is facing, string: 'up', 'down', 'right', 'left'

% Dimentions
body_length = len;
ref = 0.5*len;
body_width = ref;
tire_gap = 0.125*ref;
tire_width = 0.125*ref;
tire_length = 0.5*ref;
wshield_gap = 0.125*ref;
wshield_width = 0.75*ref;
wshield_length = 0.5*ref;

% Coordinates
tire_LF = [body_width/2, -body_length/2 + tire_gap, tire_width, tire_length];
tire_RF = [-body_width/2 - tire_width, -body_length/2 + tire_gap, tire_width, tire_length];
tire_LB = [body_width/2, body_length/2 - tire_gap - tire_length, tire_width, tire_length];
tire_RB = [-body_width/2 - tire_width, body_length/2 - tire_gap - tire_length, tire_width, tire_length];
body = [-body_width/2, -body_length/2, body_width, body_length];
wshield = [-body_width/2 + wshield_gap, -wshield_length - wshield_gap, wshield_width, wshield_length];

% Illustration
tire_color = 'k';
%vehicle_color = color;
wshield_color = 'c';
h_tire_LF = rectangle('Position', tire_LF, 'EdgeColor', 'none', 'FaceColor', tire_color, 'Curvature', 1);
h_tire_RF = rectangle('Position', tire_RF, 'EdgeColor', 'none', 'FaceColor', tire_color, 'Curvature', 1);
h_tire_LB = rectangle('Position', tire_LB, 'EdgeColor', 'none', 'FaceColor', tire_color, 'Curvature', 1);
h_tire_RB = rectangle('Position', tire_RB, 'EdgeColor', 'none', 'FaceColor', tire_color, 'Curvature', 1);
h_body = rectangle('Position', body, 'EdgeColor', 'none', 'FaceColor', vehicle_color, 'Curvature', 0.4);
h_wshield = rectangle('Position', wshield, 'EdgeColor', 'none', 'FaceColor', wshield_color, 'Curvature', 0.6);
axis([-body_length, body_length, -body_length, body_length])

h_vehicle = [h_tire_LF; h_tire_RF; h_tire_LB; h_tire_RB; h_body; h_wshield];

switch dir
    case 'up'
        for n = 1:length(h_vehicle)
            set(h_vehicle(n), 'Position', rot_rect(h_vehicle(n), pi) + [x y 0 0])
        end
    case 'down'
        for n = 1:length(h_vehicle)
            set(h_vehicle(n), 'Position', rot_rect(h_vehicle(n), 0) + [x y 0 0])
        end
    case 'left'
        for n = 1:length(h_vehicle)
            set(h_vehicle(n), 'Position', rot_rect(h_vehicle(n), -pi/2) + [x y 0 0])
        end
    case 'right'
        for n = 1:length(h_vehicle)
            set(h_vehicle(n), 'Position', rot_rect(h_vehicle(n), pi/2) + [x y 0 0])
        end
end

end

