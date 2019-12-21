function [ sim ] = sim_semaforos( t, sim, graficar )
% Cambia de color semaforos y agrega

if graficar == 1 % graficar:
    if t == 1
        for s=1:sim.n_semaforos
            if sim.semaforo(s).tiempos(t) == 1 % verde                
                % Cambiar semaforo a color verde
                set(sim.semaforo(s).obj, 'FaceColor', 'g')
            elseif sim.semaforo(s).tiempos(t) == 2 % amarillo
                set(sim.semaforo(s).obj, 'FaceColor', 'y')
            elseif sim.semaforo(s).tiempos(t) == 0 % rojo
                set(sim.semaforo(s).obj, 'FaceColor', 'r')
            end
        end
    else
        for s=1:sim.n_semaforos
            if sim.semaforo(s).tiempos(t) == 1 % verde
                    if sim.semaforo(s).tiempos(t-1) == 0
                        % Cambiar semaforo a color verde
                        set(sim.semaforo(s).obj, 'FaceColor', 'g')
                    end
            elseif sim.semaforo(s).tiempos(t) == 2 % amarillo
                if sim.semaforo(s).tiempos(t-1) == 1
                    set(sim.semaforo(s).obj, 'FaceColor', 'y')
                end
            elseif sim.semaforo(s).tiempos(t) == 0 % rojo
                if sim.semaforo(s).tiempos(t-1) == 2
                    set(sim.semaforo(s).obj, 'FaceColor', 'r')
                end
            end
        end
    end
else % sin grafica
    if t == 1
        for s=1:sim.n_semaforos
            if sim.semaforo(s).tiempos(t) == 1 % verde
                % Quitar el -1 del final
%                 sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
                sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento} = ...
                    sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}(sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}~=-1);
%                 sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
%                 input('sacandolo')
            elseif sim.semaforo(s).tiempos(t) == 2 % amarillo
                %set(sim.semaforo(s).obj, 'FaceColor', 'y')
            elseif sim.semaforo(s).tiempos(t) == 0 % rojo
                %set(sim.semaforo(s).obj, 'FaceColor', 'r')
%                 sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
                sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento} = [sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento} -1];
%                 sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
%                 input('agregando')
            end
        end
    else
%         fprintf('tiempo %d\n', t)
        for s=1:sim.n_semaforos
            if sim.semaforo(s).tiempos(t) == 1 % verde
                % Si en el tiempo anterior el semaforo estaba en rojo,
                % entonces quitar el vehiculo del frente
                if sim.semaforo(s).tiempos(t-1) == 0
                    % Quitar el -1 del final
%                     sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
                    sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento} = ...
                        sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}(sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}~=-1);
%                     sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
%                     input('quitando')
                end
            elseif sim.semaforo(s).tiempos(t) == 0 % rojo
                % Si en el tiempo anterior el semaforo estaba en amarillo,
                % entonces agregar vehiculo al frente.
                if sim.semaforo(s).tiempos(t-1) == 2
%                     sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
                    sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento} = [sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento} -1];
%                     sim.grafo.Edges.ids_vehiculos{sim.semaforo(s).id_segmento}
%                     input('agregando')
                end
            end
        end
    end
    
end

end

