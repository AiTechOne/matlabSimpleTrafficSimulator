function p = rot_rect(handle, angle)
%rot_rect Rotates the point x, y by angle degrees with respect to the origin
% only multiples of pi/2
p = get(handle, 'Position');
x1 = p(1);
y1 = p(2);
x2 = p(1) + p(3);
y2 = p(2) + p(4);
r1 = sqrt(x1^2+y1^2);
r2 = sqrt(x2^2+y2^2);
phi1 = atan2(y1,x1);
phi2 = atan2(y2,x2);
x1 = r1*cos(phi1 + angle);
y1 = r1*sin(phi1 + angle);
x2 = r2*cos(phi2 + angle);
y2 = r2*sin(phi2 + angle);
xmin = min([x1, x2]);
ymin = min([y1, y2]);
xmax = max([x1, x2]);
ymax = max([y1, y2]);
p = [xmin, ymin, xmax - xmin, ymax - ymin];
end

