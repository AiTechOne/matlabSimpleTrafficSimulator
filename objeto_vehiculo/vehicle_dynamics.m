function [ my_next_pos, my_next_vel] = vehicle_dynamics(car, my_pos, my_vel, acceleration, time_step, mainvars, veh_len)
my_next_pos = my_pos + my_vel*time_step + 0.5*acceleration*time_step^2;
my_next_vel = my_vel + acceleration*time_step;
[front_pos, front_vel] = check_next_obstacle(car, mainvars);
safe_time = 3;
if ~isempty(front_vel)
    if my_vel > front_vel
        danger_dist = safe_time*my_vel + (my_vel>0)*veh_len;
        danger_pos = front_pos - danger_dist;
        if my_next_pos > danger_pos
            coll_pos = (front_pos.*my_vel - my_next_pos.*front_vel)./(my_vel - front_vel);
            fd = (coll_pos - my_next_pos)./(coll_pos - danger_pos);
            delta_pos = my_next_pos - my_pos;
            my_next_pos = my_pos + delta_pos.*fd;
            my_next_vel = delta_pos/time_step;
        end
    end
end
max_vel = 60/3.6;
if max(my_next_vel) > max_vel % max velocity (m/s)
    acceleration =  (max_vel - my_vel)/time_step;
    my_next_vel = my_vel + acceleration*time_step;
    my_next_pos = my_pos + my_vel*time_step + 0.5*acceleration*time_step^2;
end

end
