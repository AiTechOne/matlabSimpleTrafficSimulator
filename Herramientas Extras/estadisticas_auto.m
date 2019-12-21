function estadisticas_auto( sim )

t_i = sim.vehiculo(1).t_inicial;
t_f = sim.vehiculo(1).t_final-1;

%% Grafica PU
figure(sim.fig_sim)

% Plot id segmento
% segs = sim.vehiculo(1).ruta_f;
% delta = 20;
% for id_seg=sim.vehiculo(1).ruta_f
%     if sim.grafo.Edges.xy_i(id_seg, 1) == sim.grafo.Edges.xy_f(id_seg, 1) % vertical
%         if sim.grafo.Edges.direccion(id_seg) == 1 % ida  
%             text((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2 + delta,...
%                  (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2,...
%                  strcat('S=',num2str(id_seg)));
%         elseif sim.grafo.Edges.direccion(id_seg) == -1 % vuelta
%             text((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2 - delta,...
%                  (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2,...
%                  strcat('S=',num2str(id_seg)));
%         end
%         
%     elseif sim.grafo.Edges.xy_i(id_seg, 2) == sim.grafo.Edges.xy_f(id_seg, 2) % horizontal
%         if sim.grafo.Edges.direccion(id_seg) == 1 % ida  
%             text((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2,...
%                  (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2 - delta,...
%                  strcat('S=',num2str(id_seg)));
%         elseif sim.grafo.Edges.direccion(id_seg) == -1 % vuelta
%             text((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2,...
%                  (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2 + delta,...
%                  strcat('S=',num2str(id_seg)));
%         end
%     else % diagonal
%         if sim.grafo.Edges.direccion(id_seg) == 1 % ida
%             text((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2 + delta,...
%                  (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2 + delta,...
%                  strcat('S=',num2str(id_seg)));
%         elseif sim.grafo.Edges.direccion(id_seg) == -1 % vuelta
%             text((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2 - delta,...
%                  (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2 - delta,...
%                  strcat('nS=',num2str(id_seg)));
%         end
%         
%     end
% %     plot((sim.grafo.Edges.xy_i(id_seg, 1) + sim.grafo.Edges.xy_f(id_seg, 1))/2,...
% %          (sim.grafo.Edges.xy_i(id_seg, 2) + sim.grafo.Edges.xy_f(id_seg, 2))/2,...
% %          '*', 'MarkerSize', 14)
% end
% leyenda = cellstr(num2str(sim.vehiculo(1).ruta_f', 'S = %d'));
% legend(leyenda)

% Inicio
% plot(sim.vehiculo(1).x(t_i), sim.vehiculo(1).y(t_i), 'or', 'MarkerSize', 18)
t1 = text(sim.vehiculo(1).x(t_i), sim.vehiculo(1).y(t_i), 'Inicio');
t1.FontSize = 14;
t1.EdgeColor = [1 0 0];

% Recorrido
plot(sim.vehiculo(1).x(t_i+1:t_f-1), sim.vehiculo(1).y(t_i+1:t_f-1), '.g', 'MarkerSize', 12)

% Fin
% plot(sim.vehiculo(1).x(t_f), sim.vehiculo(1).y(t_f), 'ob', 'MarkerSize', 18)
t2 = text(sim.vehiculo(1).x(t_f), sim.vehiculo(1).y(t_f), 'Fin');
t2.FontSize = 14;
t2.EdgeColor = [0 0 1];


%% Segmentos
segmentos = figure();
subplot(2,1,1)
hold on
box on
for t=t_i:t_f
    seg = sim.vehiculo(1).idx_seg_tiempo(t);
    sem = sim.grafo.Edges.id_semaforo(seg);
    if sem > 0
        if sim.semaforo(sem).tiempos(t) == 0
            plot(t, seg, 'rs')
        elseif sim.semaforo(sem).tiempos(t) == 1
            plot(t, seg, 'gs')
        elseif sim.semaforo(sem).tiempos(t) == 2
            plot(t, seg, 'ys')
        end
    else
        plot(t, seg, '.k')
    end
end
% plot([t_i:t_f], sim.vehiculo(1).idx_seg_tiempo(t_i:t_f), 'sk')
title('Color Semaforo de los Segmentos Recorridos vs Tiempo')
xlabel('Tiempo [s]')
ylabel('ID Segmento')
ax_min = min(sim.vehiculo(1).idx_seg_tiempo(t_i:t_f-1));
ax_max = max(sim.vehiculo(1).idx_seg_tiempo(t_i:t_f-1));
axis([t_i t_f ax_min-5 ax_max+5])
hold off


%% Velocidad
% velocidad = figure();
% hold on;
subplot(2,1,2)
box on
plot([t_i:t_f], sim.vehiculo(1).v(t_i:t_f)*3.6, '-..b')
title('Velocidad del Vehículo vs Tiempo')
xlabel('Tiempo [s]')
ylabel('Velocidad [km/h]')
axis([t_i t_f 0 60])
hold off

%% Aceleracion
aceleracion = figure();
hold on;
% plot([t_i+1:t_f], diff(sim.vehiculo(1).a(t_i:t_f)), '-..r')
plot([t_i:t_f], sim.vehiculo(1).a(t_i:t_f), '-..r')
title('Aceleracion del Vehículo vs Tiempo')
xlabel('Tiempo [s]')
ylabel('Aceleración [m/s^2]')
axis([t_i t_f -7 7])
hold off

%% Grafo y Grafo destacado con la ruta:
sim = build_grafo( sim );
grafo_destacado = figure();
grafo_destacado.Color = [1 1 1];
hold on
axis_seg = gca;
axis_seg.Visible = 'off'; % <=> axis tight off; 
% G = plot(sim.grafo, 'Layout', 'force', 'NodeLabel', sim.grafo.Nodes.id, 'EdgeLabel', sim.grafo.Edges.id);

ids_nodos = sim.vehiculo(1).ruta_nodos_i;
nodos_label = cell(1,sim.n_nodos);
for i=1:sim.n_nodos
    if any(ids_nodos==i)
        nodos_label{i} = strcat('N=', num2str(i));
    else
        nodos_label{i} = '';
    end
end

ids_segs = sim.vehiculo(1).ruta_f;
segs_label = cell(1,sim.n_segmentos) ;
for i=1:sim.n_segmentos
    if any(ids_segs==i)
        segs_label{i} = strcat('S=', num2str(i));
    else
        segs_label{i} = '';
    end
end

G = plot(sim.grafo, 'Layout', 'force');
% G.NodeLabel = nodos_label;
G.EdgeColor = [0.8 0.8 0.8];
G.NodeColor = [0.65 0.65 0.65];
G.ArrowSize = 10;
highlight(G, sim.vehiculo(1).ruta_nodos_i, 'EdgeColor', [1 0.33 0.1], 'NodeColor', [0.85 0.33 0.1]);
% highlight(G, sim.vehiculo(1).ruta_nodos_i, 'NodeColor', [0.85 0.33 0.1]);
hold off

grafo_destacado2 = figure();
grafo_destacado2.Color = [1 1 1];
hold on
axis_seg = gca;
axis_seg.Visible = 'off'; % <=> axis tight off; 
% G = plot(sim.grafo, 'Layout', 'force', 'NodeLabel', sim.grafo.Nodes.id, 'EdgeLabel', sim.grafo.Edges.id);

G = plot(sim.grafo, 'Layout', 'force');
G.EdgeLabel = segs_label;
G.EdgeColor = [0.8 0.8 0.8];
G.NodeColor = [0.65 0.65 0.65];
G.ArrowSize = 10;
highlight(G, sim.vehiculo(1).ruta_nodos_i, 'EdgeColor', [1 0.33 0.1], 'NodeColor', [0.85 0.33 0.1]);
hold off

%%

end

