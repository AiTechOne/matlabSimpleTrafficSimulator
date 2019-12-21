clc
clear 
close all

guardar = 1;

Vi = 13.889;
vf = 2.7778;
% vf = 0;
dx = 75;
c = [0.5 1 1.5 2 2.5];
% c=1;

fig_vel = figure(); hold on; grid on; fig_vel.Position=[500 130 340 263];
fig_dres = figure(); hold on; grid on; fig_dres.Position=[100 130 340 263];
fig_acel = figure(); hold on; grid on; box on; fig_acel.Position=[900 130 340 263];
Tabla = cell(1,length(c));

Ds = [];
t_max = 0;
epsilon = 0.01;
delta = 1;
drmin = 0;
for j=1:length(c)
    V = [Vi];
    a = [0];
    X = [0];
    Ds = [dx];
    for t=2:30
%         tau = (V(t-1)+vf)/(2*(Ds(t-1)));
%         if X(t-1)/dx <=1
%             factor = -(1 - X(t-1)/dx);
%         else
%             factor = 0;
%         end
%         V2 = vf*exp(factor);
        tau = (V(t-1)+vf)/(2*(Ds(t-1)));
        V(t) = (V(t-1)-vf)*exp(-tau*c(j)) + vf;
        
%         if -delta < V(t)-vf  && V(t)-vf< delta
%             if Ds(t-1) < 5
%                 V(t) = 0;
%                 a(t) = V(t) - V(t-1);
%                 X(t) = X(t-1)+V(t-1)+0.5*a(t-1);
%                 Ds(t) = dx-X(t);
%                 break
%             else
%                 V(t) = delta;
%                 a(t) = V(t)-V(t-1);
%             end
%         else
%             a(t) = V(t)-V(t-1);
%         end
        a(t) = V(t)-V(t-1);
        X(t) = X(t-1)+V(t-1)+0.5*a(t-1);
        Ds(t) = dx-X(t);
        if -delta < V(t)-vf  && V(t)-vf< delta
            if Ds(t) < 2
                break
            end
        end
        if 0 > Ds(t) && Ds(t) < -5
            
            break
        end
%         if a(t) > epsilon && t>1 || a(t)>0
% %             Dr(end) = 0;
%             break
%         end
%         if Ds(t) > 0 && Ds(t) < delta
%             X(t+1) = dx;
%             a(t) = 2*(X(t+1)-X(t)-V(t));
%             V(t+1) = V(t) + a(t);
%             a(t+1) = 0;
%             Ds(t+1) = 0;
%             t=t+1;
%             break
%         elseif Ds(t) < 0
%             break
%         end

    end
    if t_max < t
        t_max = t;
    end
    t_max = 16;
    % Data
    T = table();
    T.tiempo = (0:t-1)';
    T.X = X';
    T.Ds = Ds';
    T.X_mas_Ds = T.X + T.Ds;
    T.V = V';
    T.A = a';
    T.C = ones(length(V),1)*c(j);
    Tabla{j} = T;
    if drmin > T.Ds(end)
        drmin = T.Ds(end);
    end
    
    % Ploteo
    figure(fig_vel)
    plot(0:t-1,V, '-.*')
    figure(fig_dres)
    plot(0:t-1,Ds, '-.*')
    figure(fig_acel)
    plot(1:t-1,a(2:t), '-.*')
end

% Figura velocidad
figure(fig_vel)
plot(0:t_max, ones(1,t_max+1)*vf, '-..k', 'MarkerSize', 12)
% axis([1 t_max 0 18*3.6])
axis([0 t_max 0 round(Vi+1)])
ax = gca;
ax.XLim = [0 t_max];
ax.XTick = [0:2:t_max];
ax.YTick = [1:2:16];
% axis([0 t_max 0 18])
leyenda = cellstr(num2str(c', 'C = %0.1f'));
leyenda{length(c)+1} = 'Limite';
legend(leyenda)
xlabel('Tiempo [s]')
ylabel('Velocidad [m/s]')
hold off
if guardar
    print(strcat('desaceleracion_v_', num2str(dx),'_',num2str(vf)), '-dpng', '-r1000')
end

% Figura distancia restante
figure(fig_dres)
axis([0 t_max drmin dx])
ax = gca;
ax.XLim = [0 t_max];
ax.XTick = [0:2:t_max];
plot(0:t_max, zeros(1,t_max+1), '-..k', 'MarkerSize', 12)
leyenda = cellstr(num2str(c', 'C = %0.1f'));
leyenda{length(c)+1} = 'Limite';
legend(leyenda)
xlabel('Tiempo [s]')
ylabel('Distancia Semaforo [m]')
hold off
if guardar
    print(strcat('desaceleracion_ds_', num2str(dx),'_',num2str(vf)), '-dpng', '-r1000')
end


% Figura aceleracion
figure(fig_acel)
ax = gca;
ax.XLim = [0 t_max];
ax.YLim = [-5 1];
ax.XTick = [0:2:t_max];
plot(0:t_max, zeros(1,t_max+1), '-..k', 'MarkerSize', 12)
leyenda = cellstr(num2str(c', 'C = %0.1f'));
leyenda{length(c)+1} = 'Limite';
legend(leyenda)
ax.Legend.Location = 'southeast';
xlabel('Tiempo [s]')
ylabel('Aceleración [m/s^2]')
hold off
if guardar
    print(strcat('desaceleracion_a_', num2str(dx),'_',num2str(vf)), '-dpng', '-r1000')
end

% 
% Vi = 16.667;
% Vf = 0;
% dx = 50;
% fig_vel2 = figure(); hold on; grid on; fig_vel.Position=[100 130 340 500];
% V = [];
% tau =(Vi+Vf)/(2*dx);
% for t=1:50
%     V(t) = (Vi-Vf)*exp(-(t-1)*2*tau) + Vf;
% end
% plot(1:t, V, '-.*')
