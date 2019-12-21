function sim = init_semaforos( sim  )
% Genera los semaforos segun la grilla 
% 0 = rojo
% 1 = verde
% 2 = amarilla

config_semaforos = sim.config.semaforos;
%% Inicializar tabla
semaforo = table();
semaforo.nodo = zeros(sim.n_semaforos,1);
semaforo.tipo = zeros(sim.n_semaforos, 1);
semaforo.sentido = zeros(sim.n_semaforos, 1);
semaforo.id_calle = zeros(sim.n_semaforos, 1);
semaforo.id_cuadra = zeros(sim.n_semaforos, 1);
semaforo.id_interseccion = zeros(sim.n_semaforos, 1);
semaforo.id_segmento = ones(sim.n_semaforos, 1)*-1;
semaforo.x = zeros(sim.n_semaforos, 1);
semaforo.y = zeros(sim.n_semaforos, 1);
semaforo.id_coordinado = zeros(sim.n_semaforos, 1)-1;

%% Procesar data basica
% Auxiliares
id_parcial = 1;
% Pasar a una celda de str los nodos y detectar semaforos en tramos
strk = cellstr(num2str(sim.grafo.Edges.EndNodes(:,2)));
for seg=1:sim.n_segmentos
    % Semaforo principal (recto y derecha)
    if strcmp(strk{seg}(end),'1')
        aux_double = str2double(strk{seg});
        semaforo.tipo(id_parcial) = config_semaforos.principal;
        semaforo.sentido(id_parcial) = -1;
        semaforo.x(id_parcial) = sim.grafo.Nodes.x(aux_double);
        semaforo.y(id_parcial) = sim.grafo.Nodes.y(aux_double);
        semaforo.id_cuadra(id_parcial) = sim.grafo.Nodes.id_cuadra(aux_double);
        semaforo.id_calle(id_parcial) = sim.grafo.Nodes.id_calle(aux_double);
        semaforo.id_interseccion(id_parcial) = sim.grafo.Nodes.id_interseccion(aux_double);
        % Importantes: guardar id segmento e id semaforo
        semaforo.id_segmento(id_parcial) = seg;
        semaforo.nodo(id_parcial,:) = aux_double;
        id_parcial = id_parcial + 1;
    elseif strcmp(strk{seg}(end),'0')
        aux_double = str2double(strk{seg});
        semaforo.tipo(id_parcial) = config_semaforos.principal;
        semaforo.sentido(id_parcial) = 1;
        semaforo.x(id_parcial) = sim.grafo.Nodes.x(aux_double);
        semaforo.y(id_parcial) = sim.grafo.Nodes.y(aux_double);
        semaforo.id_cuadra(id_parcial) = sim.grafo.Nodes.id_cuadra(aux_double);
        semaforo.id_calle(id_parcial) = sim.grafo.Nodes.id_calle(aux_double);
        semaforo.id_interseccion(id_parcial) = sim.grafo.Nodes.id_interseccion(aux_double);
        % Importantes: guardar id segmento e id semaforo
        semaforo.id_segmento(id_parcial) = seg;
        semaforo.nodo(id_parcial,:) = aux_double;
        id_parcial = id_parcial + 1;    
    % Semaforos solo izquierda (tercer tiempo)
    elseif strcmp(strk{seg}(end),'3')
        aux_double = str2double(strk{seg});
        semaforo.tipo(id_parcial) = config_semaforos.secundario;
        semaforo.sentido(id_parcial) = -1;
        semaforo.x(id_parcial) = sim.grafo.Nodes.x(aux_double);
        semaforo.y(id_parcial) = sim.grafo.Nodes.y(aux_double);
        semaforo.id_cuadra(id_parcial) = sim.grafo.Nodes.id_cuadra(aux_double);
        semaforo.id_calle(id_parcial) = sim.grafo.Nodes.id_calle(aux_double);
        semaforo.id_interseccion(id_parcial) = sim.grafo.Nodes.id_interseccion(aux_double);
        % Importantes: guardar id segmento e id semaforo
        semaforo.id_segmento(id_parcial) = seg;
        semaforo.nodo(id_parcial,:) = aux_double;
        id_parcial = id_parcial + 1;
    elseif strcmp(strk{seg}(end),'8')
        aux_double = str2double(strk{seg});
        semaforo.tipo(id_parcial) = config_semaforos.secundario;
        semaforo.sentido(id_parcial) = 1;
        semaforo.x(id_parcial) = sim.grafo.Nodes.x(aux_double);
        semaforo.y(id_parcial) = sim.grafo.Nodes.y(aux_double);
        semaforo.id_cuadra(id_parcial) = sim.grafo.Nodes.id_cuadra(aux_double);
        semaforo.id_calle(id_parcial) = sim.grafo.Nodes.id_calle(aux_double);
        semaforo.id_interseccion(id_parcial) = sim.grafo.Nodes.id_interseccion(aux_double);
        % Importantes: guardar id segmento e id semaforo
        semaforo.id_segmento(id_parcial) = seg;
        semaforo.nodo(id_parcial,:) = aux_double;
        id_parcial = id_parcial + 1;
    end
end

%% Ordenar la tabla segun id_interseccion
semaforo = sortrows(semaforo, {'id_calle' 'id_interseccion' 'id_cuadra'}, {'ascend' 'ascend' 'ascend'});


% %% Semaforos simetricos:
% if config_semaforos.simetricos
%     % Recorrer de forma inteligente, segun el nuevo orden de filas
%     for s=6:4:sim.n_semaforos-1
%         % Eliminar casos de semaforos en nodos finales (inter = -1)
%         if semaforo.id_interseccion(s) > 0
%             % Semaforos principales
%             semaforo.id_coordinado(s) = s + 1;
%             semaforo.id_coordinado(s + 1) = s;
%             % Semaforos secundarios
%             semaforo.id_coordinado(s - 1) = s + 2;
%             semaforo.id_coordinado(s + 2) = s - 1;
%         end
%     end
% end

%% reorden 2
semaforo = sortrows(semaforo, {'id_calle' 'id_cuadra' 'sentido'}, {'ascend' 'ascend' 'ascend'});
semaforo.id = (1:sim.n_semaforos)';
semaforo = [semaforo(:,end) semaforo(:,1:end-1)];

%% Asociar id semaforo a id segmento:
for idx = 1:sim.n_semaforos
    sim.grafo.Edges.id_semaforo(semaforo.id_segmento(idx)) = idx;
end

%% Tiempos

% Ciclo semaforo primario 
ciclo_p = [ones(config_semaforos.t_verde_p,1);... % verde principal
    2 * ones(config_semaforos.t_amarilla,1);... % amarilla
    zeros(config_semaforos.t_rojo_entreverde,1);...
    zeros(config_semaforos.t_verde_s,1);... % roja (verde sec)
    zeros(config_semaforos.t_amarilla,1);...% roja (amarilla sec)
    zeros(config_semaforos.t_rojo_entreverde,1);...
    zeros(config_semaforos.t_ciclo,1)]; % roja (ciclo completo)
% Ciclo semaforo secundario
ciclo_s = [zeros(config_semaforos.t_verde_p,1);...
    zeros(config_semaforos.t_amarilla,1);...
    zeros(config_semaforos.t_rojo_entreverde,1);...
    ones(config_semaforos.t_verde_s,1);...
    2* ones(config_semaforos.t_amarilla,1);...
    zeros(config_semaforos.t_rojo_entreverde,1);...
    zeros(config_semaforos.t_ciclo,1)];
% Repetir ciclo hasta generar un vector del tamaï¿½o del 
% tiempo de la simulacion
vector_p = repmat(ciclo_p, ceil(sim.tiempo/config_semaforos.t_delta), 1);
vector_p = vector_p(1:sim.tiempo);
vector_s = repmat(ciclo_s, ceil(sim.tiempo/config_semaforos.t_delta), 1);
vector_s = vector_s(1:sim.tiempo);
% Añadir tiempo delta al principio y luego repetir el ciclo hasta
% cumplir el tiempo de la simulacion
vector_p_delta = [zeros(config_semaforos.t_delta, 1); ...
    repmat(ciclo_p, ceil(sim.tiempo/size(ciclo_p,1)), 1)];
vector_p_delta = vector_p_delta(1:sim.tiempo);
vector_s_delta = [zeros(config_semaforos.t_delta, 1); ...
    repmat(ciclo_s, ceil(sim.tiempo/size(ciclo_s,1)), 1)];
vector_s_delta = vector_s_delta(1:sim.tiempo);
% Calculo matrices de tiempos verticales y horizontales
tiempos_v = zeros(sim.tiempo, sim.n_semaforos/2);
id_parcial = 1;
for c=1:sim.n_calles/2 % recorrer calles verticales
    if mod(c,2) % calle impar -> partir normal
        delta = 0;
    else  % calle par -> aplicar delta al inicio
        delta = 1;
    end
    % Inicio
    if delta
        tiempos_v(:,id_parcial:id_parcial+1) = [vector_p_delta, vector_s_delta];
        delta = 0;
    else 
        tiempos_v(:,id_parcial:id_parcial+1) = [vector_p, vector_s];
        delta = 1;
    end
    id_parcial = id_parcial + 2;
    % Intersecciones
    for i=1:sim.grilla % tiempos de semaforos segun interseccion (grilla = interseccionxcalle)
        if delta
            tiempos_v(:,id_parcial:id_parcial+3) = [vector_s_delta, vector_p_delta, vector_p_delta, vector_s_delta];
            delta = 0;
        else
            tiempos_v(:,id_parcial:id_parcial+3) = [vector_s, vector_p, vector_p, vector_s];
            delta = 1;
        end
        id_parcial = id_parcial + 4;
    end
    % Final
    if delta
        tiempos_v(:,id_parcial:id_parcial+1) = [vector_s_delta, vector_p_delta];

    else
        tiempos_v(:,id_parcial:id_parcial+1) = [vector_s, vector_p];
    end
    id_parcial = id_parcial + 2;
end
% Horizontal => "inverso (o complemento)" del vertical PERO reordenando el vector para
% que cuadren las intersecciones (por el desfase delta)
% Tomar un ciclo con el desfase y repetir hasta lograr el tiempo de la
% simulacion
tiempos_h = repmat(tiempos_v(config_semaforos.t_ciclo+1:config_semaforos.t_ciclo*3,:),...
                       ceil(sim.tiempo/(config_semaforos.t_ciclo*2)), 1);

% Ajuste en tiempo
tiempos_h = tiempos_h(1:sim.tiempo,:);

% Asignar Tiempos
tiempos = [tiempos_v, tiempos_h];
semaforo.tiempos = cell(sim.n_semaforos, 1);
for s=1:sim.n_semaforos
    semaforo.tiempos{s} = tiempos(:,s);
end
%% Generar Objetos semaforos (rectangulos) y guardarlos en tabla semaforo
semaforo.obj = cell(sim.n_semaforos, 1);
for v=1:sim.grilla
    id_parcial = find(semaforo.id_calle == v);
    for c=1:size(id_parcial,1)
        if semaforo.sentido(id_parcial(c)) == 1 % ida
            if semaforo.tipo(id_parcial(c)) == 1 %principal
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c))-config_semaforos.ancho_p/2, ...
                    semaforo.y(id_parcial(c)),...
                    config_semaforos.ancho_p,...
                    config_semaforos.alto], ...
                    'FaceColor', 'b');
            else
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c))-config_semaforos.ancho_s/2, ...
                    semaforo.y(id_parcial(c)),...
                    config_semaforos.ancho_s,...
                    config_semaforos.alto], ...
                    'FaceColor', 'b');
            end
        else % sentido = -1 => vuelta
            if semaforo.tipo(id_parcial(c)) == 1 %principal
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c))-config_semaforos.ancho_p/2, ...
                    semaforo.y(id_parcial(c))-config_semaforos.alto,...
                    config_semaforos.ancho_p,...
                    config_semaforos.alto], ...
                    'FaceColor', 'b');
            else
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c))-config_semaforos.ancho_s/2, ...
                    semaforo.y(id_parcial(c))-config_semaforos.alto,...
                    config_semaforos.ancho_s,...
                    config_semaforos.alto], ...
                    'FaceColor', 'b');
            end
        end
    end
end
% Recorrer calles horizontales
for h=v+1:2*sim.grilla
    id_parcial = find(semaforo.id_calle == h);
    for c=1:size(id_parcial,1)
        if semaforo.sentido(id_parcial(c)) == 1 % ida
            if semaforo.tipo(id_parcial(c)) == 1 %principal
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c)), ...
                    semaforo.y(id_parcial(c)) - config_semaforos.ancho_p/2,...
                    config_semaforos.alto,...
                    config_semaforos.ancho_p], ...
                    'FaceColor', 'b');
            else % secundario
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c)), ...
                    semaforo.y(id_parcial(c)) - config_semaforos.ancho_s/2,...
                    config_semaforos.alto,...
                    config_semaforos.ancho_s], ...
                    'FaceColor', 'b');
            end
        else % sentido = -1 => vuelta
            if semaforo.tipo(id_parcial(c)) == 1 %principal
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c)) - config_semaforos.alto, ...
                    semaforo.y(id_parcial(c)) - config_semaforos.ancho_p/2,...
                    config_semaforos.alto,...
                    config_semaforos.ancho_p], ...
                    'FaceColor', 'b');
            else % secundario
                semaforo.obj{id_parcial(c)} = rectangle('Position',...
                    [semaforo.x(id_parcial(c)) - config_semaforos.alto, ...
                    semaforo.y(id_parcial(c)) - config_semaforos.ancho_s/2,...
                    config_semaforos.alto,...
                    config_semaforos.ancho_s], ...
                    'FaceColor', 'b');
            end
        end
    end
end

%% Exportar
sim.fig_sim.Visible = 'off';
% Agregar struct semaforo a sim
% sim.semaforo_tabla = semaforo;
sim.semaforo = table2struct(semaforo);
end

