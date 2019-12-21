function sim = init_calles( sim )
% Generar coordenadas para gr�fica del escenario. Metodolog�a:
% 1. Generar coordenadas (x,y) de las intersecciones pseudo-aleatoriamente
% 2. Generar arreglos para guardar coordenadas de las calles V, H e Inter.
% 3. Asignar dichas coordenadas a los nodos del sim.grafo generado

config_calles = sim.config.calles;
%% 1. Generar coordenadas X,Y
% Numero de cuadras a definir:
cuadras_calle = sim.grilla + 1;
cuadras = cuadras_calle * sim.grilla;

% Generar puntos pseudo-aleatorios (vertices)
% Fila 1 = x & Fila 2 = y
largos_cuadras = randi([config_calles.largo_cuadra * config_calles.factor_min,...
                        config_calles.largo_cuadra * config_calles.factor_max ],...
                        2, cuadras_calle);

% Puntos de interseccion en el mapa
c_x = zeros(1, cuadras_calle+1);
c_y = zeros(1, cuadras_calle+1);
% c_x = 0;
% c_y = 0;
for i=1:cuadras_calle
%     c_x = [c_x, sum(largos_cuadras(1,1:i))];
%     c_y = [c_y, sum(largos_cuadras(2,1:i))];
    c_x(i+1) = sum(largos_cuadras(1,1:i));
    c_y(i+1) = sum(largos_cuadras(2,1:i));
end


%% Calles
% a. Calles verticales
idx = 1;
calles_v = zeros(cuadras, 3);
for v=2:size(c_x, 2) - 1
    for h=1:size(c_y, 2) - 1
        if h == 1
            calles_v(idx,:) = [c_x(v) c_y(h) c_y(h+1)-c_y(h)-config_calles.ancho_calle/2];
        elseif h == size(c_y,2)-1
            calles_v(idx,:) = [c_x(v) config_calles.ancho_calle/2+c_y(h) c_y(h+1)-c_y(h)-config_calles.ancho_calle/2];
        else 
            calles_v(idx,:) = [c_x(v) config_calles.ancho_calle/2+c_y(h) c_y(h+1)-c_y(h)-config_calles.ancho_calle];
        end
        idx = idx + 1;
    end
end

% b. Calles horizontales
calles_h = zeros(cuadras, 3);
idx = 1;
for h=2:size(c_y, 2) - 1
    for v=1:size(c_x, 2) - 1
        if v == 1
            calles_h(idx,:) = [c_x(v) c_y(h) c_x(v+1)-c_x(v)-config_calles.ancho_calle/2];
        elseif v == size(c_x,2)-1
            calles_h(idx,:) = [c_x(v)+config_calles.ancho_calle/2 c_y(h) c_x(v+1)-c_x(v)-config_calles.ancho_calle/2];
        else 
            calles_h(idx,:) = [c_x(v)+config_calles.ancho_calle/2 c_y(h) c_x(v+1)-c_x(v)-config_calles.ancho_calle];
        end
        idx = idx + 1;
    end
end

%% Extraccion de imagenes:
% idx = 1;
% calles_v = zeros(cuadras, 3);
% for v=2:size(c_x, 2) - 1
%     for h=1:size(c_y, 2) - 1
%         if h == 1
%             calles_v(idx,:) = [c_x(v) c_y(h) c_y(h+1)-c_y(h)];
%         elseif h == size(c_y,2)-1
%             calles_v(idx,:) = [c_x(v) c_y(h) c_y(h+1)-c_y(h)];
%         else 
%             calles_v(idx,:) = [c_x(v) +c_y(h) c_y(h+1)-c_y(h)];
%         end
%         idx = idx + 1;
%     end
% end
% calles_h = zeros(cuadras, 3);
% idx = 1;
% for h=2:size(c_y, 2) - 1
%     for v=1:size(c_x, 2) - 1
%         if v == 1
%             calles_h(idx,:) = [c_x(v) c_y(h) c_x(v+1)-c_x(v)];
%         elseif v == size(c_x,2)-1
%             calles_h(idx,:) = [c_x(v) c_y(h) c_x(v+1)-c_x(v)];
%         else 
%             calles_h(idx,:) = [c_x(v) c_y(h) c_x(v+1)-c_x(v)];
%         end
%         idx = idx + 1;
%     end
% end
% 
% figure(4); hold on
% plot([calles_v(1:3,1); calles_v(1,1)], [calles_v(1:3,2); calles_v(3,2)+calles_v(3,3)], 'g--*')
% plot([calles_v(4:end,1);calles_v(4,1)], [calles_v(4:end,2); calles_v(end,2)+calles_v(end,3)], 'g--*')
% plot([calles_h(1:3,1); calles_h(3,1)+calles_h(3,3)], [calles_h(1:3,2);calles_h(3,2)], 'b--*')
% plot([calles_h(4:end,1); calles_h(end,1)+calles_h(end,3)], [calles_h(4:end,2);calles_h(end,2)], 'b--*')
% hold off
% saveas(gcf,'Calles2x2','epsc')

%% Asignar coordenadas a nodos del sim.grafo y generar tabla de calles
% Vectores aux - del tama�o del sim.grafo
x = zeros(size(sim.grafo.Nodes,1),1);
y = zeros(size(sim.grafo.Nodes,1),1);
id_cuadra = zeros(size(sim.grafo.Nodes,1),1);

n_cuadras_calle = sim.grilla + 1;
% n_nodos_cuadra = 4; % definici�n

% Generar un ID para las calles verticales y horizontales
% a. Identificar el numero de calles con el sim.grafo
num_calles = max(sim.grafo.Nodes.id_calle);
% b. Generar primero los IDs para las verticales
ids_ver = 1:num_calles/2;
% c. Generar los IDs para las horizontales
ids_hor = num_calles/2 +1:num_calles;

% Indices auxiliares para recorrer calles_v
d = 0;
e = n_cuadras_calle+1;

% 
sim.grafo.Nodes.VH = zeros(sim.n_nodos,1);
for v=ids_ver
    % Buscar nodos sim.calle "v-esima"
    nodos = find(sim.grafo.Nodes.id_calle == v);
    sim.grafo.Nodes.VH(nodos) = 1;
    % Carril "de vuelta" (izq - impares por definici�n)
    idx_impar = logical(mod(nodos,2));
    nodos_vuelta = flipud(sim.grafo.Nodes.id(nodos(idx_impar)));
    % Carril "de ida" (der - pares por definici�n)
    nodos_ida = sim.grafo.Nodes.id(nodos(~idx_impar));
    % Auxiliares
    n = 1;
    aux_cuadra = 1;
    c = 1;
    % Asignar coordenadas a los nodos correspondientes:
    while c <= n_cuadras_calle
        % 1. Eje y: arreglo mas variaciones por largo de sim.calle
        %  a. Ida (derecha)
        y(nodos_ida(n:n+3)) = calles_v(c+d,2)...
            + [0 calles_v(c+d,3)*config_calles.factor calles_v(c+d,3) calles_v(c+d,3)];
        %  b. Vuelta (izquierda)
        y(nodos_vuelta(n:n+3)) = calles_v(e-c,2)...
            + [calles_v(e-c,3) calles_v(e-c,3)*(1-config_calles.factor) 0 0];

        % 2. Eje X: arreglo mas variaciones por ancho de sim.calle
        %  a. Ida (derecha)
        x(nodos_ida(n:n+3)) = calles_v(c+d,1)...
            + [config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               0 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2];
        %  b. Vuelta (izqierdas)
        x(nodos_vuelta(n:n+3)) = calles_v(e-c,1)...
            - [config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               0 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2];
        % 3. ID cuadra
        id_cuadra(nodos_ida(n:n+3)) = aux_cuadra;
        id_cuadra(nodos_vuelta(n:n+3)) = sim.n_cuadras_calle - aux_cuadra + 1;
        
        % 4. Guardar en struct cuadra
        sim.calle(v).cuadra(aux_cuadra).id_calle = v;
        sim.calle(v).cuadra(aux_cuadra).id_cuadra = aux_cuadra;
        sim.calle(v).cuadra(aux_cuadra).nodos_ida = nodos_ida(n:n+3)';
        sim.calle(v).cuadra(aux_cuadra).nodos_vuelta = nodos_vuelta(n:n+3)';
        sim.calle(v).cuadra(aux_cuadra).x_if = [(x(nodos_ida(n))+x(nodos_vuelta(n)))/2,...
                                               (x(nodos_ida(n+3))+x(nodos_vuelta(n+3)))/2];
        sim.calle(v).cuadra(aux_cuadra).y_if = [y(nodos_ida(n)), y(nodos_ida(n+3))];
        sim.calle(v).cuadra(aux_cuadra).largo = calles_v(e-c,3);
        % 5. Aumentar auxiliares
        n = n + 4;
        aux_cuadra = aux_cuadra + 1;
        c = c+1;
        
    end
    % Guardar en struct sim.calle
    sim.calle(v).nodos_ida = nodos_ida';
    sim.calle(v).nodos_vuelta = nodos_vuelta';
    sim.calle(v).orientacion = 'vertical';
    sim.calle(v).x_if = [sim.calle(v).cuadra(1).x_if(1) sim.calle(v).cuadra(end).x_if(end)];
    sim.calle(v).y_if = [sim.calle(v).cuadra(1).y_if(1) sim.calle(v).cuadra(end).y_if(end)];
    sim.calle(v).largo = sum([sim.calle(v).cuadra.largo]);
    
    % Aumentar indices auxiliares
    d = d+n_cuadras_calle;
    e = e+n_cuadras_calle;
end

% Indices auxiliares para recorrer calles_h
d = 0;
e = n_cuadras_calle+1;
for h=ids_hor
    % Buscar nodos sim.calle "v-esima"
    nodos = find(sim.grafo.Nodes.id_calle == h);
    sim.grafo.Nodes.VH(nodos) = 2;
    % Carril "de vuelta" (izq - impares por definici�n)
    idx_impar = logical(mod(nodos,2));
    nodos_vuelta = flipud(sim.grafo.Nodes.id(nodos(idx_impar)));
    % Carril "de ida" (der - pares por definici�n)
    nodos_ida = sim.grafo.Nodes.id(nodos(~idx_impar));
    % Asignar coordenadas
    n = 1;
    aux_cuadra = 1;
    c = 1;
    while c <= n_cuadras_calle
        % 1. Eje y: arreglo mas variaciones por largo de sim.calle
        %  a. Ida (abajo)
        y(nodos_ida(n:n+3)) = calles_h(c+d,2)...
            - [config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               0 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2];
        %  b. Vuelta (arriba)
        y(nodos_vuelta(n:n+3)) = calles_h(e-c,2)...
             + [config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2 ...
               0 ...
               config_calles.ancho_pista_giro/2 + config_calles.ancho_pista/2];
        % 2. Eje X: arreglo mas variaciones por ancho de sim.calle
        %  a. Ida (abajo)
        x(nodos_ida(n:n+3)) = calles_h(c+d,1)...
            + [0 calles_h(c+d,3)*config_calles.factor calles_h(c+d,3) calles_h(c+d,3)];
        %  b. Vuelta (arriba)
        x(nodos_vuelta(n:n+3)) = calles_h(e-c,1)...
            + [calles_h(e-c,3) calles_h(e-c,3)*(1-config_calles.factor) 0 0];
        % 3. ID cuadra
        id_cuadra(nodos_ida(n:n+3)) = aux_cuadra;
        id_cuadra(nodos_vuelta(n:n+3)) = sim.n_cuadras_calle - aux_cuadra + 1;
        
        % 4. Guardar en struct cuadra
        sim.calle(h).cuadra(aux_cuadra).id_calle = h;
        sim.calle(h).cuadra(aux_cuadra).id_cuadra = aux_cuadra;
        sim.calle(h).cuadra(aux_cuadra).nodos_ida = nodos_ida(n:n+3)';
        sim.calle(h).cuadra(aux_cuadra).nodos_vuelta = nodos_vuelta(n:n+3)';
        sim.calle(h).cuadra(aux_cuadra).x_if = [x(nodos_ida(n)) x(nodos_ida(n+3))];
        sim.calle(h).cuadra(aux_cuadra).y_if = [y(nodos_ida(n)) y(nodos_ida(n+3))];
        sim.calle(h).cuadra(aux_cuadra).largo = calles_h(e-c,3);
        sim.calle(h).cuadra(aux_cuadra).obj = [];
        
        % 5. Aumentar auxiliares
        n = n + 4;
        aux_cuadra = aux_cuadra + 1;
        c = c+1;
    end
    % Guardar en struct sim.calle
    sim.calle(h).nodos_ida = nodos_ida';
    sim.calle(h).nodos_vuelta = nodos_vuelta';
    sim.calle(h).orientacion = 'horizontal';
    sim.calle(h).x_if = [sim.calle(h).cuadra(1).x_if(1) sim.calle(h).cuadra(end).x_if(end)];
    sim.calle(h).y_if = [sim.calle(h).cuadra(1).y_if(1) sim.calle(h).cuadra(end).y_if(end)];
    sim.calle(h).largo = sum([sim.calle(h).cuadra.largo]);

    % Aumentar indices auxiliares
    d = d+n_cuadras_calle;
    e = e+n_cuadras_calle;
end

%% Build calles

% 4.1 Calles verticales
aux_id = 0;
for k=1:sim.n_calles/2
    for j=1:sim.n_cuadras_calle
        sim.calle(k).cuadra(j+aux_id).obj = build_cuadra(calles_v(j+aux_id,:), config_calles, 'vertical');
    end
    aux_id = aux_id + j;
end

% 4.1 Calles horizontales
aux_id = 0;
for k=sim.n_calles/2+1:sim.n_calles
    for j=1:sim.n_cuadras_calle
        
        sim.calle(k).cuadra(j+aux_id).obj = build_cuadra(calles_h(j+aux_id,:), config_calles, 'horizontal');
    end
    aux_id = aux_id + j;
end


%% Intersecciones
intersecciones = zeros(sim.grilla^2,2);
idx = 1;
for v=2:size(c_x, 2)-1
    for h=2:size(c_y, 2)-1
        intersecciones(idx,:) = [c_x(v) c_y(h)];
        idx = idx + 1;
    end
end

% Generar tabla de intersecciones
inter = table();
inter.id = transpose(1:sim.n_intersecciones);
inter.id_nodos = zeros(sim.n_intersecciones, 12);
inter.id_semaforos = zeros(sim.n_intersecciones, 1);
inter.obj = zeros(sim.n_intersecciones, 1);

% Completar tabla inter y asignar id_interseccion para cada nodo
id_interseccion = zeros(sim.n_nodos,1);
for i=1:sim.n_intersecciones
    aux_inter = abs(x-intersecciones(i,1))...
                + abs(y-intersecciones(i,2));
    idx_inter_i = find(aux_inter==config_calles.ancho_calle/2);
    idx_inter_i = [idx_inter_i ; idx_inter_i + [2 2 -2 -2]' ;...
                   idx_inter_i + [1 1 -1 -1]'];
    id_interseccion(idx_inter_i) = i;
    % completar tabla
    inter.id_nodos(i,:) = idx_inter_i';
    inter.obj(i) = build_inter(intersecciones(i,:), config_calles);
end
sim.intersecciones = inter;

% Nodos iniciales y finales:
id_interseccion(sim.nodos_iniciales) = -1;
id_interseccion(sim.nodos_finales) = -1;



%% Exportar en sim.grafo:

sim.grafo.Nodes.x = x;
sim.grafo.Nodes.y = y;
sim.grafo.Nodes.id_cuadra = id_cuadra;
sim.grafo.Nodes.id_interseccion = id_interseccion;



%% Graficar nodos
if sim.config.grafo.graficar_nodos
    sim.grafo.Nodes.obj = cell(sim.n_nodos, 1);
    for n=1:size(sim.grafo.Nodes)
        sim.grafo.Nodes.obj{n} = rectangle('Position', [sim.grafo.Nodes.x(n)-sim.config.grafo.size_nodos/2 sim.grafo.Nodes.y(n)-sim.config.grafo.size_nodos/2 sim.config.grafo.size_nodos sim.config.grafo.size_nodos],...
                               'Curvature', [1 1], 'EdgeColor', sim.config.grafo.color_nodos);
    end
end

%% Reordenar tabla Nodes:
% sim.grafo.Nodes = [sim.grafo.Nodes(:,1:2) sim.grafo.Nodes(:,10:11)...
%                    sim.grafo.Nodes(:,3) sim.grafo.Nodes(:,8:9)...
%                    sim.grafo.Nodes(:,4:7)];
         
end


