function sim = sim_aceleraciones(t, k, id_seg, frenado_seco, sim)
id_sem = sim.grafo.Edges.id_semaforo(id_seg);
if id_sem > 0
    luz_semaforo = sim.semaforo(id_sem).tiempos(t);
else
    luz_semaforo = 1;
end
Lsegmento = sim.grafo.Edges.largo(id_seg);
Dx = Lsegmento - sim.vehiculo(k).d(t);

%% Condiciones segun luz del semaforo
if luz_semaforo == 0
    % roja
    Vi = sim.vehiculo(k).v(t);
    if frenado_seco == 1
        if Dx < 1
            sim.vehiculo(k).a(t) = -Vi;
        else
            sim.vehiculo(k).a(t) = -Vi*.5;
        end
        return
    else
        c=1.5;
        Vi = sim.vehiculo(k).v(t);
        Vf = 0;
        tau = c*(Vi + Vf) / (2*Dx);
        V = (Vi - Vf) * exp(-tau) + Vf;
        % Imponer aceleracion que cumple V
        sim.vehiculo(k).a(t) = V-Vi;
%         fprintf('ROJA: %0.4f\n', sim.vehiculo(k).a(t))
        return
    end
    
elseif luz_semaforo == 2 
    %% amarilla    
    % 1. Analizar cuanto tiempo en amarilla queda
    s_restantes = 0;
    for j=sim.config.semaforos.t_amarilla:-1:1
        if t <= sim.tiempo - j
            s_restantes = sum(sim.semaforo(id_sem).tiempos(t+1:t+j))/2;
            break
        end
    end
    if t <= sim.tiempo - sim.config.semaforos.t_amarilla - 1
        s_restantes = sum(sim.semaforo(id_sem).tiempos(t+1:t+sim.config.semaforos.t_amarilla-1))/2;
    elseif t <= sim.tiempo - sim.config.semaforos.t_amarilla - 2
        s_restantes = sum(sim.semaforo(id_sem).tiempos(t+1:t+sim.config.semaforos.t_amarilla-2))/2;
    end
    
    % 2. Proyectar cuanto más puedo avanzar en tiempo de amarilla
    alcance_vt = sim.vehiculo(k).v(t) * s_restantes;
    alcance_max = sim.Vmax * s_restantes;
    
    % Condiciones:
    % 1. Alvance manteniendo Vt
    if Dx > sim.vehiculo(k).d(t) + alcance_vt
        % 1.1 Manteniendo la velocidad no alcanca a superarlo.
        % 2. Alcance maximo
        if Dx < sim.vehiculo(k).d(t) + alcance_max
            % 2.1 Si puede cruzar a Vmax. Ver factibilidad alcanzar Vmax:
            Dv = sim.Vmax - sim.vehiculo(k).v(t);
            if Dv < 4/2 
                % 2.1.1 Max aceleracion = 4 => 0.5*a + vi = vmax
                sim.vehiculo(k).a(t) = Dv*2 ;
            else
                % 2.1.2 Frenar de todas formas
                c=2;
                Vi = sim.vehiculo(k).v(t);
                Vf = 0;
                tau = c*(Vi + Vf) / (2*Dx);
                V = (Vi - Vf) * exp(-tau) + Vf;
                % Imponer aceleracion que cumple V
                sim.vehiculo(k).a(t) = V-Vi;
            end
        else
            % 2.2 No hay caso => Frenar
            c=2;
            Vi = sim.vehiculo(k).v(t);
            Vf = 0;
            tau = c*(Vi + Vf) / (2*Dx);
            V = (Vi - Vf) * exp(-tau) + Vf;
            % Imponer aceleracion que cumple V
            sim.vehiculo(k).a(t) = V-Vi;
        end
    else
        %1.2 manteniendon velocidad cruza => aceleracion normal
        sim.vehiculo(k).a(t) = sim.vehiculo(k).a(t-1) + (sim.grafo.Edges.Vmax(id_seg) - sim.vehiculo(k).v(t-1)) / sim.grafo.Edges.Vmax(id_seg);
    end
else
    %% semaforo en verde: Condiciones segun accion siguiente
    accion_siguiente = sim.vehiculo(k).accion_siguiente;
    if accion_siguiente == 2 || accion_siguiente == 3 %doblar derecha o izquierda
        c = 2;
        Vf = sim.grafo.Edges.Vmax(sim.vehiculo(k).idx_seg_siguientes(1));
        Vi = sim.vehiculo(k).v(t);
        tau = c*(Vi + Vf) / (2*Dx);
        V = (Vi - Vf) * exp(-tau) + Vf;
        % Imponer aceleracion que cumple V
        sim.vehiculo(k).a(t) = V-Vi;
        
    else % seguir recto o cambio de pista
        tau = 1-sim.vehiculo(k).v(t-1)/sim.grafo.Edges.Vmax(id_seg);
        factor = sim.vehiculo(k).agresividad * 1.7;
        ve = sim.vehiculo(k).v(t-1)*exp(tau/factor) + tau;
        sim.vehiculo(k).a(t) = ve - sim.vehiculo(k).v(t-1);
%         if sim.vehiculo(k).a(t-1) < 0
%             sim.vehiculo(k).a(t) = (sim.grafo.Edges.Vmax(id_seg) - sim.vehiculo(k).v(t-1)) / (sim.vehiculo(k).agresividad*sim.grafo.Edges.Vmax(id_seg));
%         else
%             sim.vehiculo(k).a(t) = sim.vehiculo(k).a(t-1) + (sim.grafo.Edges.Vmax(id_seg) - sim.vehiculo(k).v(t-1)) / (sim.vehiculo(k).agresividad*sim.grafo.Edges.Vmax(id_seg));     
%         end

%         Vf = sim.grafo.Edges.Vmax(sim.vehiculo(k).idx_seg_actual);
%         Vi = sim.vehiculo(k).v(t);
%         tau = 1/8;
%         V =  Vf *(1- 1/exp(tau)) + Vi;
%         % Imponer aceleracion que cumple V
%         sim.vehiculo(k).a(t) = V-Vi;
    end
end
end
