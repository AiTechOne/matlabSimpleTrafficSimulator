function [ sim ] =  sim_kinematics( t, sim, supersegmentos)

% orden_autos = cell con n supersegmentos como fila y 1 columna.

% Recorrer cada super segmento
for ss = 1:size(supersegmentos, 1) 
    % 1. Recorrer cada segmento de supersegmento
    n_segmentos_ss = size(supersegmentos{ss}, 2);
    vector_vehiculos = [];
    % epsilon = 0.5;
    for vv = 1:n_segmentos_ss
        % 2. Concatenar ids vehiculos de cada segmento del supersegmento:
         vector_vehiculos = [vector_vehiculos sim.grafo.Edges.ids_vehiculos{supersegmentos{ss}(vv)}];
    end
%     fprintf('Vector a procesar desde el ultimo al primero: ')
%     disp([vector_vehiculos])
    % Recorrer vehiculo a vehiculo:
    for idv = length(vector_vehiculos):-1:1 % recorrer de el fin hacia el inicio
        % Condicion inicial nula
        frenado_seco = 0;
        % ID del vehiculo:
        k = vector_vehiculos(idv);
        % Si ID = -1 => es un semaforo en rojo!
        if k==-1 
            continue
        else
            % Si no, analizar id_seg actual del vehiculo k:
            id_seg = sim.vehiculo(k).idx_seg_actual;
        end
        
        % A. Posicion relativa del vehiculo en el tiempo t
        sim.vehiculo(k).d(t) = sim.vehiculo(k).d(t-1) + sim.vehiculo(k).v(t-1) + .5*sim.vehiculo(k).a(t-1);       
        
        % B. Condición para alcances (primero no necesita esto)
        if k ~= vector_vehiculos(end)
            % ID del vehiculo delante de el:
            k2 = vector_vehiculos(idv+1); 
            if k2 == -1  % Si adelante tiene un semaforo en rojo, procesar diferente
                if sim.grafo.Edges.largo(id_seg) - sim.vehiculo(k).d(t) - sim.vehiculo(k).largo/2 < sim.vehiculo(k).v(t-1)*2
                    frenado_seco = 1;
%                     fprintf('frenado 1:\n')
                end
                if sim.grafo.Edges.largo(id_seg) - sim.vehiculo(k).d(t) - sim.vehiculo(k).largo/2 < 5
                    frenado_seco = 1;
%                     fprintf('frenado 2:\n')
                end 
            else % Si adelante tiene un vehiculo
                % ID del segmento del auto de al frente:
                id_seg2 = sim.vehiculo(k2).idx_seg_actual;
                % Analizar velocidades:
                if sim.vehiculo(k).v(t-1) > sim.vehiculo(k2).v(t-1)
                    % Analizar segmentos (pueden pertenecer a diferentes)
                    if id_seg == id_seg2 % estan en el mismo segmento
                        aux_largo_segmento = 0;
                    else % Estan en segmentos continuos:
                        aux_largo_segmento = sim.grafo.Edges.largo(id_seg);
                    end
                    % Distancia de precaución tiempo seguro * velocidad y
                    % largo/2 de ambos vehiculos
                    Dp = sim.tS * sim.vehiculo(k).v(t-1) + sim.vehiculo(k).largo/2;
                    % Posición de precaución
                    Xp = (sim.vehiculo(k2).d(t)-sim.vehiculo(k2).largo/2) + aux_largo_segmento - Dp;
                    % Ver si fue superada dicha distancia
                    if sim.vehiculo(k).d(t) > Xp % [todo] revisar si hay que corregir usando largo/2
                        % Contador de cuantas veces ocurre el alcance
                        sim.grafo.Edges.alcances(id_seg) = sim.grafo.Edges.alcances(id_seg) + 1;
                        % Punto futuro de colision
                        XD = ( (sim.vehiculo(k2).d(t)+aux_largo_segmento) * sim.vehiculo(k).v(t-1) - sim.vehiculo(k).d(t) * sim.vehiculo(k2).v(t-1) )/...
                            ( sim.vehiculo(k).v(t-1) - sim.vehiculo(k2).v(t-1));
                        % factor de desaceleración
                        fd = (XD - sim.vehiculo(k).d(t)) / (XD - Xp);
                        % Velocidad con supuesto avance
                        Dsc = sim.vehiculo(k).d(t) - sim.vehiculo(k).d(t-1);
                        % Imponer nueva posicion para el tiempo t
                        sim.vehiculo(k).d(t) = sim.vehiculo(k).d(t-1) + Dsc*fd;
                        % Recalcular la aceleracion para t-1 y asi lograr d(t)
                        sim.vehiculo(k).a(t-1) = 2 * (sim.vehiculo(k).d(t) - sim.vehiculo(k).d(t-1) - sim.vehiculo(k).v(t-1));
                    end
                end
            end 
        end

        % C. Velocidad del vehículo id_vehiculo en el tiempo t:
        sim.vehiculo(k).v(t) = sim.vehiculo(k).v(t-1) + sim.vehiculo(k).a(t-1);
        
        % D. Condición sobre velocidades min y max
        if sim.vehiculo(k).v(t) < sim.Vmin
            % Aceleracion en t-1 igual a velocidad en t-1 + limite inferior de
            % velocidad (dado que hay semaforos, limite = 0)
            sim.vehiculo(k).a(t-1) = sim.vehiculo(k).v(t-1) + sim.Vmin;
            sim.vehiculo(k).v(t) = sim.vehiculo(k).v(t-1) + sim.vehiculo(k).a(t-1);
            sim.vehiculo(k).d(t) = sim.vehiculo(k).d(t-1) + sim.vehiculo(k).v(t-1) + 0.5*sim.vehiculo(k).a(t-1);
        end
        if sim.vehiculo(k).v(t) > sim.grafo.Edges.Vmax(id_seg)
            sim.vehiculo(k).a(t-1) = sim.grafo.Edges.Vmax(id_seg) - sim.vehiculo(k).v(t-1);
            sim.vehiculo(k).v(t) = sim.vehiculo(k).v(t-1) + sim.vehiculo(k).a(t-1);
            sim.vehiculo(k).d(t) = sim.vehiculo(k).d(t-1) + sim.vehiculo(k).v(t-1) + 0.5*sim.vehiculo(k).a(t-1);
        end

       
        if (sim.vehiculo(k).activo == 1) % condicion de actividad
            % puede cambiar maximo 2 segmentos 
            % 1. Diferencia entre d y largo seg:
            delta = sim.vehiculo(k).d(t) - sim.grafo.Edges.largo(sim.vehiculo(k).idx_seg_actual);
            % 2. Si es positiva => cambio de segmento
            if delta > 0 
                % 3. Aplicar cambio
                [ sim.vehiculo(k), sim.grafo ] = sim_cambio_segmento( sim.vehiculo(k), sim.grafo, t );
                % 4. Si el nuevo segmento existe (puede haber terminado)
                if (sim.vehiculo(k).activo == 1) % condicion de actividad
                    % Si la diferencia sigue siendo mayor que el largo del
                    % nuevo segmento => avanzo doble
                    if delta > sim.grafo.Edges.largo(sim.vehiculo(k).idx_seg_actual)
                        sim.vehiculo(k).d(t) = delta - sim.grafo.Edges.largo(sim.vehiculo(k).idx_seg_actual);
                        [ sim.vehiculo(k), sim.grafo ] = sim_cambio_segmento( sim.vehiculo(k), sim.grafo, t );
                    else % avanzo solo uno :)
                        sim.vehiculo(k).d(t) = delta ;
                    end
                end
            end
        end
        
        % F. Aceleracion tiempo siguiente
        if sim.vehiculo(k).activo == 1
            sim = sim_aceleraciones(t, k, sim.vehiculo(k).idx_seg_actual, frenado_seco, sim);
%             [sim.vehiculo(1).d(t-1:t) sim.vehiculo(1).v(t-1:t) sim.vehiculo(1).a(t-1:t)]
        end

        % G. Guardar el segmento an el cual estuvo el vehículo en el segundo t
        sim.vehiculo(k).idx_seg_tiempo(t) = sim.vehiculo(k).idx_seg_actual;
        
        % H. Calcular coordenadas X,Y:
        funcion = ['[sim.vehiculo(k).x(t),sim.vehiculo(k).y(t)] = GPS_G', num2str(sim.grilla),...
                        '_T', num2str(sim.tiempo), '_', sim.trafico,...
                        '(', num2str(sim.vehiculo(k).idx_seg_actual), ',', num2str(sim.vehiculo(k).d(t)), ');'];
        eval(funcion);

    end
end
end

