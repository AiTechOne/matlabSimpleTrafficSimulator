function sim = build_grafo( sim )
% Grafo
fig_grafo = figure();
% fig_grafo.Visible = 'off';
fig_grafo.Name = sprintf('Grafo Direccional para Grilla %dx%d', sim.grilla, sim.grilla);
fig_grafo.Color = [1 1 1];
% fig_grafo.Position = [10 110 1024 692];
axis_grafo = gca;
axis_grafo.NextPlot = 'add'; % <=> hold on; 
axis_grafo.Visible = 'off'; % <=> axis tight off; 
G = plot(sim.grafo, 'Layout', 'force');
G.EdgeColor = [0.3 0.3 0.3];
% plot(sim.grafo, 'Layout', 'force', 'NodeLabel', sim.grafo.Nodes.id)
% plot(grafo, 'Layout', 'force', 'NodeLabel', grafo.Nodes.nodos, 'EdgeLabel', grafo.Edges.Weight) 
hold off
sim.fig_grafo = fig_grafo;
end

