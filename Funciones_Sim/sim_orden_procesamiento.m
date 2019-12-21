function [ supersegmentos ] = sim_orden_procesamiento( t, sim, activos )
% Funcion encargada de ordenar los vehiculos para que no se active el
% mecanismo para evitar colisiones en casos que no aplique (mover "el de
% mas adelante". SUPERSEGMENTOS

idx = find(activos);
n_autos = size(idx, 2);
segmentos = zeros(1, n_autos);

for k=1:n_autos
    try
        segmentos(k) = sim.vehiculo(idx(k)).idx_seg_actual;
    catch exception
        fprintf('\n------------------------ Error!! ----------------------\n')
        fprintf(' -----> sim_orden_procesamiento')
        msgText = getReport(exception);
        disp(msgText)
%         idx(k)
%         sim.vehiculo(idx(k)).idx_seg_actual
    end
end

% segmentos
segmentos = unique(segmentos);
n_segmentos = size(segmentos, 2);
orden = [];

% fprintf('\n\n\n\n\n\n\n\n\n\n----------------orden procesamiento----------------\n')
if n_autos > 0
%     fprintf('Tiempo = %d:\n', t)
    for s=1:n_segmentos
%         fprintf('\n\n')
%         fprintf('Orden = ')
%         disp(orden)
%         fprintf('\n')
        % 1. Agregar el segmento al vector orden si no existe:
        existe = any(orden == segmentos(s));
        if ~existe % no existe en el vector orden. Agregarlo:
            orden = [orden 0 segmentos(s) 0];
%             fprintf('agregando segmento %d', segmentos(s))
%             input('')
            k = find(orden==segmentos(s));
        else % esta en el vector orden. Buscar indice
            k = find(orden==segmentos(s));
%             fprintf('ya existe el segmento %d', segmentos(s))
%             input('')
            if numel(k) > 1 % este mas de una vez! mal
                fprintf('sim_orden_procesamiento: esto no deberia pasar nunca!!! -  T=%d - segmento %d - indice %d\n', t, segmentos(s), k')
            end
        end
%         fprintf('T=%d - segmento %d - indice %d\n', t, segmentos(s), k)

        % 2. Ver si semaforo no esta en roja. Si lo esta, no añadir siguientes
        id_semaforo = sim.grafo.Edges.id_semaforo(segmentos(s));
        if  id_semaforo > 0 % tiene semaforo
            if sim.semaforo(id_semaforo).tiempos(t) == 0 % esta en roja
%                 fprintf('semaforo del segmento %d esta en roja para t=%d \n', segmentos(s), t)
                continue
            end
        end

        % 3. Si no hay roja, entonces el ultimo es el id del vehiculo lider
        id_lider = sim.grafo.Edges.ids_vehiculos{segmentos(s)}(end);
        if id_lider == -1
            fprintf('id lider -1 para segmento %d en t=%d \n', segmentos(s), t)
        end

        % 3. Segmentos siguientes de este vehiculo:
        try
            seg_sig = sim.vehiculo(id_lider).idx_seg_siguientes(1:2);
        catch
            try
                seg_sig = sim.vehiculo(id_lider).idx_seg_siguientes(1);
            catch
                continue
            end
        end

%         fprintf('Segmentos siguientes: ')
%         disp(seg_sig)
        % 5. Si existen siguientes y el semaforo no esta en rojo, seguir:
        % 5.1. Analizar si hay vehiculos ahi para agregarlos
        i = k;
        for j=1:size(seg_sig, 2)
            % 5.2 Hay vehiculos en dicho segmento
            if size(find(sim.grafo.Edges.ids_vehiculos{seg_sig(j)} > 0), 2) > 0
                % 5.3 Hay Vehiculos -> Ver si ya esta agregado
                existe = any(orden == seg_sig(j));  
                if ~existe
                    orden = [orden(1:i) seg_sig(j) orden(i+1:end)];
%                     fprintf('Segmento %d agregado!',seg_sig(j))
%                     disp(orden)
                    i = i + 1;
                else % existe
                    % Buscar ID con su posicion en el vector orden:
                    idx_sig_j = find(orden == seg_sig(j));
                    % Mover segmento grupo de k detras de idx_seg_sig:
                    ceros = find(orden==0);
                    idx_i = ceros(find(ceros < k, 1, 'Last'));
                    idx_f = ceros(find(ceros > k, 1, 'First'));
                    % Si esta entre los mismos pares de cero que idx_sig_j,
                    % no seguir!!! (ya esta arreglado)
                    if idx_i < idx_sig_j && idx_sig_j < idx_f
                        i = idx_sig_j;
                        continue
                    end
                    
                    % Conjunto de elementos a mover:
                    mover = orden(idx_i+1: idx_f-1);
%                     fprintf('Se movera: ')
%                     disp(mover)
                    % Mover al orden correcto:
                    try
                        orden = [orden(1:idx_sig_j-1) mover orden(idx_sig_j:end)];
                        % Eliminar el [0 s 0] o [0 s s+1 0] agregado:
                        if idx_sig_j > k
                            orden(idx_i:idx_f) = [];
                        else
                            orden(idx_i+numel(mover):idx_f+numel(mover)) = [];
                        end
%                         fprintf('Orden nuevo con elemento correctamente cambiado: ')
%                         disp(orden)
                    catch exception
                        fprintf('\n\n------------------------ Error!! ----------------------\n\n')
                        msgText = getReport(exception);
                        disp(msgText)
                        % Terminar el loop (no importa si falta un segmento
                    end
                    break
                end
            else
%                 fprintf('No hay vehiculos en segmento %d\n', seg_sig(j))
            end
        end
    end
    ceros = find(orden==0);
    try
        supersegmentos = cell(numel(ceros)/2, 1);
    catch  exception
        fprintf('\n\n------------------------ Error!! ----------------------\n\n')
        msgText = getReport(exception);
        disp(msgText)
    end
    
    k=1;
    for c=1:2:size(ceros, 2)
%         supersegmentos{k} = fliplr(orden(ceros(c)+1:ceros(c+1)-1));
        supersegmentos{k} = orden(ceros(c)+1:ceros(c+1)-1);
        k=k+1;
    end
else
    supersegmentos = {};    
end
% fprintf('Orden FINAL = ')
% disp(orden)
% fprintf('\n')
% fprintf('------------------------- FIN -------------------------')
% input('')
% fprintf('\n\n\n\n\n\n\n\n\n\n\n')

end