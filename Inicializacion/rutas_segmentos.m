function [ ruta, peso, ids_segmentos ] = rutas_segmentos( grafo, nodo_i, nodo_f )
% Función auxiliar que calcula la ruta, peso de la ruta, segmentos
% siguientes y sus ids respectivos de sim.grafo.Edges

% Calcular ruta con Dijkstra

[ruta, peso] = shortestpath(grafo, nodo_i, nodo_f, 'Method', 'positive');

largo = size(ruta,2) - 1;
ids_segmentos = zeros(1, largo);
for k=1:largo
    %     grafo.Edges.EndNodes(:,1) == ruta(k);
    %     grafo.Edges.EndNodes(:,2) == ruta(k + 1)
    ids_segmentos(k) = find(grafo.Edges.EndNodes(:,1) == ruta(k) & ...
        grafo.Edges.EndNodes(:,2) == ruta(k + 1));
end


end

