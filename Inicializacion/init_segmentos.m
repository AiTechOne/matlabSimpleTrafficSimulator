function [ sim ] = init_segmentos( sim )
% Edge o segmento es el tramo compueto por dos nodos, cuyo sentido esta
% dado por el signo de Nf-Ni

%% Calculos para Edges:
rect = sim.grafo.Edges.Weight == sim.config.grafo.peso_recta;
der = sim.grafo.Edges.Weight == sim.config.grafo.peso_der;
izq = sim.grafo.Edges.Weight == sim.config.grafo.peso_izq;
tipo = rect + der*2 + izq*3;
Vmax = rect * sim.Vmax + (der+izq) * sim.Vmax_curva;
sim.grafo.Edges.tipo_curva = tipo;
sim.grafo.Edges.Vmax = Vmax;

% Largo de los Segmentos
% rectas_vh => vertical (1) u horizontal (2)
% direccion del segmento => -1 vuelta y 1 ida
% coordenadas x,y iniciales y finales
% id de los segmentos
% factores para grafica X,Y
largo = zeros(sim.n_segmentos, 1);
rectas_vh = zeros(sim.n_segmentos, 1);
dir_seg = zeros(sim.n_segmentos, 1);
xy_i = zeros(sim.n_segmentos, 2);
xy_f = zeros(sim.n_segmentos, 2);
id = transpose(1:sim.n_segmentos);
factores_xy = zeros(sim.n_segmentos, 2);

h = waitbar(0, 'Sincronizando mapa con Segmentos (Edges)...');
for s=1:sim.n_segmentos
    waitbar(s / sim.n_segmentos)
    % Dir carril: calculada como el signo entre la resta entre nodo inicial
    % y final -> si es negativo => ida, si es positivo => vuelta
    if sim.grafo.Edges.Weight(s) ~= Inf
        if sim.grafo.Edges.EndNodes(s,1) - sim.grafo.Edges.EndNodes(s,2) < 0
            dir_seg(s) = 1;
        else
            dir_seg(s) = -1;
        end
    end
    % Si la curva es recta (incluyendo cambios de pista)
    if sim.grafo.Edges.tipo_curva(s) == 1 % rectas
        % Guardar coordenadas xy iniciales y finales
        xy_i(s,:) = [sim.grafo.Nodes.x(sim.grafo.Edges.EndNodes(s,1))...
                sim.grafo.Nodes.y(sim.grafo.Edges.EndNodes(s,1))];
        xy_f(s,:) = [sim.grafo.Nodes.x(sim.grafo.Edges.EndNodes(s,2))...
                sim.grafo.Nodes.y(sim.grafo.Edges.EndNodes(s,2))];
        % Definir si la recta es horizontal o vertical: 3 casos
        if xy_i(s,1) == xy_f(s,1) % mismo x => vertical
            rectas_vh(s) = 1;
            largo(s) = abs(xy_i(s,2)-xy_f(s,2));
            if xy_i(s,2) > xy_f(s,2) % vuelta (signo -)
                factores_xy(s,:) = [0, -1];
            else % ida (signo +)
                factores_xy(s,:) = [0, 1]; 
            end
        elseif xy_i(s,2) == xy_f(s,2) % mismo y => horizontal
            rectas_vh(s) = 2; 
            largo(s) = abs(xy_i(s, 1)-xy_f(s,1));
            if xy_i(s,1) > xy_f(s,1) % vuelta (signo -)
                factores_xy(s,:) = [-1, 0];
            else % ida (signo +)
                factores_xy(s,:) = [1, 0]; 
            end
        else % recta pero de carril solo doblar 
            % Definir horientacion segun "distancia mayor entre
            % coordenadas"
            largo_xy = [abs(xy_i(s,2) - xy_f(s,2)), abs(xy_i(s,1)-xy_f(s,1))];
            idx_max = find(largo_xy == max(largo_xy));
            % horientacion
            rectas_vh(s) = idx_max;
            % actualizar tipo de curva a 13 o 23 (cambio de pista vertical
            % u horizontal)
            sim.grafo.Edges.tipo_curva(s) = idx_max*10 + 3;
            % largo y factores
            delta_cambio = largo_xy(idx_max) * sim.config.calles.porcentaje_cambio_pista;
            diagonal = sqrt(delta_cambio^2 + sim.config.calles.ancho_cambio_pista^2);
            % largo pista giro - % + recta de cambio
            largo(s) = diagonal + largo_xy(idx_max)*(1-sim.config.calles.porcentaje_cambio_pista);
            if sim.grafo.Edges.tipo_curva(s) == 13 % vertical implica:
                % sen eje y ; cos eje x
                if xy_i(s,2) > xy_f(s,2) % Y - vuelta (signos x+, y-)
                    factores_xy(s,:) = [sim.config.calles.ancho_cambio_pista/diagonal,...
                                       -delta_cambio/diagonal];
                else % ida (signos x-, y+)
                    factores_xy(s,:) = [-sim.config.calles.ancho_cambio_pista/diagonal,...
                                       delta_cambio/diagonal];
                end
            elseif sim.grafo.Edges.tipo_curva(s) == 23 % horizontal implica:
                % sen eje x ; cos eje y
                if xy_i(s,1) > xy_f(s,1) % X - vuelta (signos x-, y-)
                    factores_xy(s,:) = [-delta_cambio/diagonal,...
                                        -sim.config.calles.ancho_cambio_pista/diagonal];
                else % ida (signos x+, y+)
                    factores_xy(s,:) = [delta_cambio/diagonal,...
                                        sim.config.calles.ancho_cambio_pista/diagonal];
                end
            end
        end
    elseif sim.grafo.Edges.tipo_curva(s) > 1 % curvas
        xy_i(s,:) = [sim.grafo.Nodes.x(sim.grafo.Edges.EndNodes(s,1))...
                sim.grafo.Nodes.y(sim.grafo.Edges.EndNodes(s,1))];
        xy_f(s,:) = [sim.grafo.Nodes.x(sim.grafo.Edges.EndNodes(s,2))...
                sim.grafo.Nodes.y(sim.grafo.Edges.EndNodes(s,2))];
        if sim.grafo.Edges.tipo_curva(s) == 2 % derecha
            largo(s) = sim.config.calles.recta_derecha;
            % factores segun paridad de los nodos
            impar_i = mod(sim.grafo.Edges.EndNodes(s,1), 2); % si es 1, nodo impar
            impar_f = mod(sim.grafo.Edges.EndNodes(s,2), 2);
            factor = cos(sim.config.calles.angulo_derecha);
            if ~impar_i && ~impar_f % ambos son pares (++)
                factores_xy(s,:) = [factor, factor];
            elseif impar_i && ~impar_f % inicio impar y fin par (-+)
                factores_xy(s,:) = [-factor, factor];
            elseif impar_i && impar_f % ambos impares (--)
                factores_xy(s,:) = [-factor, -factor];
            elseif ~impar_i && impar_f % inicio par y fin impar (+-)
                factores_xy(s,:) = [factor, -factor];
            end 
        elseif sim.grafo.Edges.tipo_curva(s) == 3 % izquierda
            largo(s) = sim.config.calles.recta_izquierda;
            % factores segun paridad de los nodos
            impar_i = mod(sim.grafo.Edges.EndNodes(s,1), 2); % si es 1, nodo impar
            impar_f = mod(sim.grafo.Edges.EndNodes(s,2), 2);
            factor_sin = sin(sim.config.calles.angulo_izquierda);
            factor_cos = cos(sim.config.calles.angulo_izquierda);
            if ~impar_i && ~impar_f % ambos son pares (++) (H->V)
                factores_xy(s,:) = [factor_cos, factor_sin];
            elseif impar_i && ~impar_f % inicio impar y fin par (+-) (V->H)
                factores_xy(s,:) = [factor_sin, -factor_cos];
            elseif impar_i && impar_f % ambos impares (--) (H->V)
                factores_xy(s,:) = [-factor_cos, -factor_sin];
            elseif ~impar_i && impar_f % inicio par y fin impar (-+) (V->H)
                factores_xy(s,:) = [-factor_sin, factor_cos];
            end
        end
    end
end

sim.grafo.Edges.id = id;
sim.grafo.Edges.rectas_vh = rectas_vh;
sim.grafo.Edges.direccion = dir_seg;
sim.grafo.Edges.xy_i = xy_i;
sim.grafo.Edges.xy_f = xy_f;
sim.grafo.Edges.largo = largo;
sim.grafo.Edges.factores_xy = factores_xy;
sim.grafo.Edges.id_semaforo = ones(sim.n_segmentos, 1)*-1;
sim.grafo.Edges.ids_vehiculos = cell(sim.n_segmentos, 1);
sim.grafo.Edges.v_promedio = zeros(sim.n_segmentos, 1);
sim.grafo.Edges.cruces = zeros(sim.n_segmentos, 1);
sim.grafo.Edges.alcances = zeros(sim.n_segmentos, 1);
close(h);
end