nodos_label = cell(1,sim.n_nodos);
for i=1:sim.n_nodos
    nodos_label{i} = '';
end
segs_label = cell(1,sim.n_segmentos) ;
for i=1:sim.n_segmentos
    segs_label{i} = strcat('S=', num2str(i));
end
grafo_destacado2 = figure();
grafo_destacado2.Color = [1 1 1];
hold on
axis_seg = gca;
axis_seg.Visible = 'off'; % <=> axis tight off; 
G = plot(sim.grafo, 'Layout', 'force');

% G = plot(sim.grafo, 'Layout', 'force', 'NodeLabel', sim.grafo.Nodes.id, 'EdgeLabel', sim.grafo.Edges.id);
% G.EdgeLabel = segs_label;
% % G.NodeLabel = nodos_label;
% G.EdgeColor = [0.85 0.33 0.1];
% G.NodeColor = [0.8 0.8 0.8];
% G.ArrowSize = 10;
hold off