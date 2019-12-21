function prueba_gps( sim )
funcion = ['[x,y]=GPS_G',num2str(sim.grilla), '_T', num2str(sim.tiempo), '_', sim.trafico, '(s,i);'];
auto = rectangle('Position', [0,0,2,2], 'FaceColor', 'c');
disp(funcion)
for s=1:sim.n_segmentos
    for i=0:sim.grafo.Edges.largo(s)/6:sim.grafo.Edges.largo(s)
        eval(funcion);
        set(auto, 'Position', [x-1.25,y-1.25,2.5,2.5])
        pause(.3)
    end
end

end

