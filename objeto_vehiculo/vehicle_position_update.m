function vehicle_handle = vehicle_position_update(vehicle_handle, dx, dy)
%vehicle_position_update Updates the position of the vehicle!
L = length(vehicle_handle);
p = zeros(L,4);
for n = 1:L
    p(n,:) = get(vehicle_handle(n), 'Position');
    set(vehicle_handle(n), 'Position', [p(n,1)+dx, p(n,2)+dy, p(n,3), p(n,4)])
end
end

