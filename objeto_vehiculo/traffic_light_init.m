function handle = traffic_light_init(x, y, orientation)
%traffic_light_init Creates a traffic light in position x, y where the 
% green light is oriented north-south if 'v' is used, west-east if 'h'.
ref = 10;
light_radius = 0.5*ref;
if orientation
    south_color = 'g';
    west_color = 'r';
else
    south_color = 'r';
    west_color = 'g';
end
h_south_light = rectangle('Position', [x-light_radius*0.5, y-ref-light_radius*0.5, light_radius, light_radius], ...
    'Curvature', [1 1], 'EdgeColor', 'none', 'FaceColor', south_color);
h_west_light = rectangle('Position', [x-ref-light_radius*0.5, y-light_radius*0.5, light_radius, light_radius], ...
    'Curvature', [1 1], 'EdgeColor', 'none', 'FaceColor', west_color);
handle = [orientation; h_south_light; h_west_light];
end
