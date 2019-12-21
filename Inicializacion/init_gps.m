function [ sim ] = init_gps( sim, dir_actual, grilla, tiempo, trafico)

nombre_gps = sprintf('%s/Escenarios/GPS_G%d_T%d_%s.m', dir_actual, grilla, tiempo, trafico);
mfw = fopen(nombre_gps, 'w', 'n', 'UTF-8');
fprintf(mfw, 'function [x,y] = GPS_G%d_T%d_%s(idx_segmento, dref)\n\n', grilla, tiempo, trafico);

for s=1:sim.n_segmentos
    % apertura
    if sim.grafo.Edges.Weight(s) ~= Inf
        if s == 1
            fprintf(mfw, 'if idx_segmento == %d\n', s);
        else
            fprintf(mfw, 'elseif idx_segmento == %d\n', s);
        end
        % Caso 1: cambio de pistas (mas complejo)
        if sim.grafo.Edges.tipo_curva(s) == 13 || sim.grafo.Edges.tipo_curva(s) == 23
            if sim.grafo.Edges.tipo_curva(s) == 13
                aux_lim = abs(sim.config.calles.ancho_cambio_pista/sim.grafo.Edges.factores_xy(s,1));
                aux_delta = abs(aux_lim*sim.grafo.Edges.factores_xy(s,2));
            else
                aux_lim = abs(sim.config.calles.ancho_cambio_pista/sim.grafo.Edges.factores_xy(s,2));
                aux_delta = abs(aux_lim*sim.grafo.Edges.factores_xy(s,1));
            end
            fprintf(mfw, '    if dref < %12.12f\n', aux_lim);
            fprintf(mfw, '        x = %12.12f + %12.12f*dref;\n', sim.grafo.Edges.xy_i(s,1), sim.grafo.Edges.factores_xy(s,1));
            fprintf(mfw, '        y = %12.12f + %12.12f*dref;\n', sim.grafo.Edges.xy_i(s,2), sim.grafo.Edges.factores_xy(s,2));
            fprintf(mfw, '    else\n');
            if sim.grafo.Edges.rectas_vh(s) == 1 % vertical => suma en y
                fprintf(mfw, '        x = %12.12f;\n', sim.grafo.Edges.xy_f(s,1));
                fprintf(mfw, '        y = %12.12f + (dref-%12.12f)*%d;\n', sim.grafo.Edges.xy_i(s,2)+sim.grafo.Edges.direccion(s)*aux_delta, aux_lim, sim.grafo.Edges.direccion(s));
            elseif sim.grafo.Edges.rectas_vh(s) == 2 % horizntal => suma en x
                fprintf(mfw, '        x = %12.12f + (dref-%12.12f)*%d;\n', sim.grafo.Edges.xy_i(s,1)+sim.grafo.Edges.direccion(s)*aux_delta, aux_lim, sim.grafo.Edges.direccion(s));
                fprintf(mfw, '        y = %12.12f;\n', sim.grafo.Edges.xy_f(s,2));
            end
            fprintf(mfw, '    end\n');
        % Caso 2: curva derecha o izquierda
        elseif sim.grafo.Edges.tipo_curva(s) == 2 || sim.grafo.Edges.tipo_curva(s) == 3
            fprintf(mfw, '    x = %12.12f + %12.12f*dref;\n', sim.grafo.Edges.xy_i(s,1), sim.grafo.Edges.factores_xy(s,1));
            fprintf(mfw, '    y = %12.12f + %12.12f*dref;\n', sim.grafo.Edges.xy_i(s,2), sim.grafo.Edges.factores_xy(s,2));
        % Caso 3: rectas
        elseif sim.grafo.Edges.tipo_curva(s) == 1
            if sim.grafo.Edges.rectas_vh(s) == 1 % vertical => suma en y
                fprintf(mfw, '        x = %12.12f;\n', sim.grafo.Edges.xy_i(s,1));
                fprintf(mfw, '        y = %12.12f + dref*%d;\n', sim.grafo.Edges.xy_i(s,2), sim.grafo.Edges.factores_xy(s,2));
            elseif sim.grafo.Edges.rectas_vh(s) == 2 % horizntal => suma en x
                fprintf(mfw, '        x = %12.12f + dref*%d;\n', sim.grafo.Edges.xy_i(s,1), sim.grafo.Edges.factores_xy(s,1));
                fprintf(mfw, '        y = %12.12f;\n', sim.grafo.Edges.xy_i(s,2));
            end
        end
    end
end
fprintf(mfw, 'else\n');
fprintf(mfw, '    x = 0;\n');
fprintf(mfw, '    y = 0;\n');
% Cerrar ciclos
fprintf(mfw, 'end\n');
fprintf(mfw, 'end');
% Cerrar archivos
fclose(mfw);

end
