function [ vehiculo_j, grafo ] = sim_cambio_segmento( vehiculo_j, grafo, t )
% vehiculo_j es el struct especifico del vehiculo_j, ej: sim.vehiculo(id_vehiculo)

% 1. Corroborar que existe el id del vehiculo_j en el segmento actual
esta = any(grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual} == vehiculo_j.id);   

if esta
    % 2. Buscar los indices de los ids de los otros vehiculos
    idx = grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual}~=vehiculo_j.id;
    % 3. Eliminar reemplazando los idx
    grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual} = grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual}(idx);
    % 4. Procesar el struct del vehiculo_j
    vehiculo_j.idx_seg_anteriores = [vehiculo_j.idx_seg_anteriores vehiculo_j.idx_seg_actual];
    
    % 4.1 Analizar si hay mas segmentos por recorrer
    if size(vehiculo_j.idx_seg_siguientes, 2) == 0 % No hay mas segmentos por recorrer! = Fin
        vehiculo_j.idx_seg_actual = 0;
        % Otras variables
        vehiculo_j.accion_siguiente = 0;
        vehiculo_j.ruta_f = vehiculo_j.idx_seg_anteriores;
        vehiculo_j.activo = 2;
        vehiculo_j.t_final = t;
        
    elseif size(vehiculo_j.idx_seg_siguientes, 2) == 1 % Queda 1 segmento por recorrer !
        vehiculo_j.idx_seg_actual = vehiculo_j.idx_seg_siguientes(1);
        vehiculo_j.idx_seg_siguientes = [];
        % Accion siguiente:
        vehiculo_j.accion_siguiente = grafo.Edges.tipo_curva(vehiculo_j.idx_seg_actual);
        %5. Actualizar id del vehiculo en el nuevo segmento
        grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual} = [vehiculo_j.id grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual}];
        % Orientacion grafica
        vehiculo_j.orientacion_a = grafo.Edges.rectas_vh(vehiculo_j.idx_seg_actual);
        
    else % Quedan mas de 1 segmento que recorrer
        vehiculo_j.idx_seg_actual = vehiculo_j.idx_seg_siguientes(1);
        vehiculo_j.idx_seg_siguientes = vehiculo_j.idx_seg_siguientes(2:end);
        % Accion siguiente:
        vehiculo_j.accion_siguiente = grafo.Edges.tipo_curva(vehiculo_j.idx_seg_siguientes(1));
        %5. Actualizar id del vehiculo en el nuevo segmento
        grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual} = [vehiculo_j.id grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual}];
        % Orientacion grafica
        if grafo.Edges.rectas_vh(vehiculo_j.idx_seg_actual) ~= 0
            vehiculo_j.orientacion_a = grafo.Edges.rectas_vh(vehiculo_j.idx_seg_actual);
        end
    end    
    
else
    % Esto nunca deberia pasar !
    fprintf('El ID del vehiculo no existe en el segmento! \n')
    vehiculo_j.idx_seg_actual
    grafo.Edges.ids_vehiculos{vehiculo_j.idx_seg_actual}
    fprintf('TRANSITO - No existe!! T=%d - idx_vehiculo=%d - idx_segmento=%d\n', t, vehiculo_j.id, vehiculo_j.idx_seg_actual)
end
end

