function [interseccion] = build_inter( coord_inter, config)
% Generar la grafica de la interseccion como objeto para ser llamado
% en determinadas coordenadas (centro del cuadrado)

coord_x = coord_inter(1);
coord_y = coord_inter(2);
ancho = config.ancho_calle;
Pi = [0 0 ancho ancho];
                     
% Mover
x2 = Pi(1) + Pi(3);
y2 = Pi(2) + Pi(4);
r2 = sqrt(x2^2+y2^2);
phi = atan2(y2,x2);
x2 = r2*cos(phi);
y2 = r2*sin(phi);
Pf = [coord_x-Pi(3)/2 coord_y-Pi(4)/2 x2 y2];

interseccion = rectangle('Position', Pf, 'FaceColor', config.color_inter);
end

