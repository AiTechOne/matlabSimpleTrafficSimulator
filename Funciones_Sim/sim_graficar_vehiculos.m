function  vehiculo = sim_graficar_vehiculos(t, vehiculo, activos)

idx = find(activos);

for j=1:size(idx, 2)
    if vehiculo(idx(j)).orientacion_a == 1 % vertical => x-ancho/2 y-largo/2
        aux_po = [vehiculo(idx(j)).x(t) - vehiculo(idx(j)).ancho/2 ...
                  vehiculo(idx(j)).y(t) - vehiculo(idx(j)).largo/2 ...
                  vehiculo(idx(j)).ancho ...
                  vehiculo(idx(j)).largo];
    elseif vehiculo(idx(j)).orientacion_a == 2 % horizontal
        aux_po = [vehiculo(idx(j)).x(t) - vehiculo(idx(j)).largo/2 ...
                  vehiculo(idx(j)).y(t) - vehiculo(idx(j)).ancho/2 ...
                  vehiculo(idx(j)).largo ...
                  vehiculo(idx(j)).ancho];
    else
        aux_po = [vehiculo(idx(j)).x(t) - vehiculo(idx(j)).largo/2 ...
                  vehiculo(idx(j)).y(t) - vehiculo(idx(j)).ancho/2 ...
                  vehiculo(idx(j)).largo ...
                  vehiculo(idx(j)).ancho];
    end
    try
        set(vehiculo(idx(j)).obj, 'Position', aux_po, 'EdgeColor', 'b')
    catch exception
        j
        vehiculo(idx(j))
        aux_po
        fprintf('\n\n------------------------ Error!! ----------------------\n\n')
        msgText = getReport(exception);
        disp(msgText)
    end
        
end

end

