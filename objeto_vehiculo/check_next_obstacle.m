function [pos, vel] = check_next_obstacle(car, mainvars)
%check_next_obstacle Searches for the closest obstacle based on mainvars
%structure
index = mainvars(9,car);
% disp([size(mainvars(index,car)), size(mainvars(index,car))])
[~, imin] = min((mainvars(index,car) < mainvars(index,:)).*mainvars(index,:).*mainvars(index+6,:));
if imin == 1
    pos = [];
    vel = [];
else
    pos = mainvars(1:2, imin);
    vel = mainvars(3:4, imin);
end
end

