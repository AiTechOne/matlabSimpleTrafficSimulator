function [ vehiculo, grafo, activos ] = sim_activador( t, vehiculo, grafo, grafica)

% Buscar los vehiculos que se activan en este tiempo y cambiar su estado a
% activado + visibilidad de su obj
aux = [vehiculo.t_inicial] == t;
idx = find(aux);
for j=1:size(idx, 2)
    if ~grafica
        % 1. Corroborar que no existe ya:
        if sum(grafo.Edges.ids_vehiculos{vehiculo(idx(j)).idx_seg_actual} == vehiculo(idx(j)).id) == 0
            vehiculo(idx(j)).activo = 1;
            grafo.Edges.ids_vehiculos{vehiculo(idx(j)).idx_seg_actual} = [vehiculo(idx(j)).id grafo.Edges.ids_vehiculos{vehiculo(idx(j)).idx_seg_actual}];
        else
            % Esto nunca deberia pasar !
            fprintf('INICIO - No existe!! T=%d - idx_vehiculo=%d - idx_segmento=%d\n', t, vehiculo(idx(j)).id, vehiculo(idx(j)).idx_seg_actual)
        end
    else
        vehiculo(idx(j)).obj.Visible = 'on';
    end
end

% Retornar los autos que estan activados
activos = [vehiculo.activo] == 1;

end

