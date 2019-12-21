function [x, y] = rot(x, y, angle)
%rot Rotates the point x, y by angle degrees with respect to the origin
r = sqrt(x^2+y^2);
phi = atan2(y,x);
x = r*cos(phi+angle);
y = r*sin(phi+angle);
end

