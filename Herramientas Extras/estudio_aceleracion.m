clear
clc
close all

a = 0;
vmax = 13.889;
v = 0;
x = [0];

agresividad= [1 2 3];
graficar = 1;

t_max = 0;
d_max = 0;

% fig_vel = figure(); hold on; grid on; box on; fig_vel.Position=[500 130 340 500];
% fig_dres = figure(); hold on; grid on; box on; fig_dres.Position=[100 130 340 500];
% fig_acel = figure(); hold on; grid on; box on; fig_acel.Position=[900 130 340 500];
fig_vel = figure(); hold on; grid on; box on; fig_vel.Position=[500 130 379 263];
fig_dres = figure(); hold on; grid on; box on; fig_dres.Position=[100 130 379 263];
fig_acel = figure(); hold on; grid on; box on; fig_acel.Position=[900 130 379 263];



Tabla = cell(1,length(agresividad));

for c=1:length(agresividad)
    for t=2:20
        tau = 1-v(t-1)/(vmax);
        K=1.7;
        factor = agresividad(c)*K;
        v(t) = v(t-1)*exp(tau/factor) + tau;
        a(t) = v(t) - v(t-1);
        x(t) = x(t-1) + v(t-1) + 0.5*a(t-1);
        if vmax-v(t) < 0.1
            break
        end
    end
    if max(x) > d_max
        d_max = max(x);
    end
    if t_max < t+1
        t_max = t+1;
    end
    T = table();
    T.tiempo = (0:length(v)-1)';
    T.x = x';
    T.v = v';
    T.a = a';
    T.agres = ones(length(v),1)*agresividad(c);
    Tabla{c} = T;
    
    % Ploteo
    figure(fig_vel)
    plot(0:t-1,v(1:t), '-.o')
    figure(fig_dres)
    plot(0:length(x)-1,x, '-.o')
    figure(fig_acel)
    plot(0:t-1,a, '-.o')
end

leyenda = cellstr(num2str(agresividad', 'Agresividad = %d'));
% leyenda{+1} = 'Vmax';

% Figura velocidad
figure(fig_vel)
plot(0:t_max, ones(1,t_max+1)*vmax, '-..k', 'MarkerSize', 12)
axis([0 t_max 0 vmax+1])
ax = gca;
ax.XLim = [0 t_max];
ax.XTick = [0:2:t_max];
leyenda2 = [leyenda ;'Velocidad Maxima'];
legend(leyenda2)
ax.Legend.Location = 'southeast';
xlabel('Tiempo [s]')
ylabel('Velocidad [m/s]')
hold off
if graficar
    print('aceleracion_v_50', '-dpng', '-r1000')
end
% Figura distancia
figure(fig_dres)
axis([0 t_max 0 d_max])
ax = gca;
ax.XLim = [0 t_max];
ax.XTick = [0:2:t_max];
plot(0:t_max, zeros(1,t_max+1), '-..k', 'MarkerSize', 12)
legend(leyenda)
ax.Legend.Location = 'northwest';
xlabel('Tiempo [s]')
ylabel('Distancia Recorrida [m]')
hold off
if graficar
    print('aceleracion_x_50', '-dpng', '-r1000')
end

% Figura aceleracion
figure(fig_acel)
ax = gca;
ax.XLim = [1 t_max];
ax.XTick = [0:2:t_max];
% plot(0:t_max, zeros(1,t_max+1), '-..k', 'MarkerSize', 12)
plot(0:t_max, ones(1,t_max+1)*3.07, '-..k', 'MarkerSize', 12)
leyenda3 = [leyenda ; 'Aceleración Máxima']
legend(leyenda3)
ax.Legend.Position = [0.4078 0.6403 0.4706 0.1310];
% ax.Legend.Location = 'northeast';
xlabel('Tiempo [s]')
ylabel('Aceleración [m/s^2]')
hold off
if graficar
    print('aceleracion_a_50', '-dpng', '-r1000')
end




