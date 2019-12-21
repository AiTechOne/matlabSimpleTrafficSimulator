function obj = build_cuadra( coord_streets, config, dir)

xf = coord_streets(1);
yf = coord_streets(2);
largo_cuadra_k = coord_streets(3);

switch dir
    case 'vertical'
        ancho_total = (config.ancho_pista + config.ancho_solera + config.ancho_vereda)*2 + config.ancho_pista_giro;
        xi = -ancho_total;
        xf = xf + ancho_total/2;

        %% Objetos:
        coor_ver_1 = [xf-abs(xi), yf, config.ancho_vereda, largo_cuadra_k];
        vereda_1 = rectangle('Position', coor_ver_1, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_vereda);
        xi = xi + config.ancho_vereda;

        coor_sol_1 = [xf-abs(xi), yf, config.ancho_solera, largo_cuadra_k];
        solera_1 = rectangle('Position', coor_sol_1, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        xi = xi + config.ancho_solera;

        coor_car_1 = [xf-abs(xi), yf, config.ancho_pista, largo_cuadra_k];
        carril_1 = rectangle('Position', coor_car_1, 'FaceColor', config.color_carril);
        xi = xi + config.ancho_pista;

        % carril del medio solo negro
        coor_car_giro = [xf-abs(xi), yf, config.ancho_pista_giro, largo_cuadra_k];
        carril_giro = rectangle('Position', coor_car_giro, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_carril);
        % coordenadas para division
        coor_bandejon = coor_car_giro + [0, largo_cuadra_k*(config.factor_1), 0, -largo_cuadra_k*(config.factor_d_1)];
        bandejon_lim_izq = coor_car_giro + [0, largo_cuadra_k*(config.factor), -config.ancho_pista_giro*.9,  -largo_cuadra_k*(config.factor)];
        bandejon_lim_der = coor_car_giro + [config.ancho_pista_giro*.9, 0, -config.ancho_pista_giro*.9, -largo_cuadra_k*(config.factor)];
        coor_lin_1 = [xf-abs(xi), yf, xf-abs(xi), yf + largo_cuadra_k*(config.factor_1)];
        coor_lin_2 = [xf-abs(xi)+config.ancho_pista_giro, yf + largo_cuadra_k*(config.factor),...
                      xf-abs(xi)+config.ancho_pista_giro, yf + largo_cuadra_k];
        xi = xi + config.ancho_pista_giro;

        coor_car_2 = [xf-abs(xi), yf, config.ancho_pista, largo_cuadra_k];
        carril_2 = rectangle('Position', coor_car_2, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_carril);
        xi = xi + config.ancho_pista;

        coor_sol_2 = [xf-abs(xi), yf, config.ancho_solera, largo_cuadra_k];
        solera_2 = rectangle('Position', coor_sol_2, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        xi = xi + config.ancho_solera;

        coor_ver_2 = [xf-abs(xi), yf, config.ancho_vereda, largo_cuadra_k];
        vereda_2 = rectangle('Position', coor_ver_2, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_vereda);
        
        % Bandejon central
        bandejon = rectangle('Position', coor_bandejon, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_bordes);
        % Limite izq-sup y der-inf
        bandejon_izq = rectangle('Position', bandejon_lim_izq, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        bandejon_der = rectangle('Position', bandejon_lim_der, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        % Lineas divisoras de pistas
        lin_1 = line('Color', 'y', 'LineStyle', '-.', ...
                    'XData', [coor_lin_1(1) coor_lin_1(3)],...
                    'YData', [coor_lin_1(2) coor_lin_1(4)]);
        lin_2 = line('Color', 'y', 'LineStyle', '-.', ...
                    'XData', [coor_lin_2(1) coor_lin_2(3)],...
                    'YData', [coor_lin_2(2) coor_lin_2(4)]);
        obj = [vereda_1, solera_1, carril_1, carril_giro, carril_2, solera_2, vereda_2, bandejon, bandejon_izq, bandejon_der, lin_1, lin_2];

    case 'horizontal'
        ancho_parcial = (config.ancho_pista_giro/2 + config.ancho_pista + config.ancho_solera);
        yf = yf + ancho_parcial;

        %% Objetos:
        coor_ver_1 = [xf, yf, largo_cuadra_k-config.ancho_solera, config.ancho_vereda];
        vereda_1 = rectangle('Position', coor_ver_1, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_vereda);
        yf = yf - config.ancho_solera;

        coor_sol_1 = [xf, yf, largo_cuadra_k-config.ancho_solera, config.ancho_solera];
        solera_1 = rectangle('Position', coor_sol_1, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        yf = yf - config.ancho_pista;

        coor_car_1 = [xf, yf, largo_cuadra_k, config.ancho_pista];
        carril_1 = rectangle('Position', coor_car_1, 'FaceColor', config.color_carril);
        yf = yf - config.ancho_pista_giro;

        coor_car_giro = [xf, yf, largo_cuadra_k, config.ancho_pista_giro];
        carril_giro = rectangle('Position', coor_car_giro, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_carril);
        % coordenadas para division
        coor_bandejon = coor_car_giro + [largo_cuadra_k*(config.factor_1), 0, -largo_cuadra_k*(config.factor_d_1), 0];
        bandejon_lim_izq = coor_car_giro + [0, 0, -largo_cuadra_k*(config.factor), -config.ancho_pista_giro*.9];
        bandejon_lim_der = coor_car_giro + [largo_cuadra_k*(config.factor), config.ancho_pista_giro*.9,...
                                            -largo_cuadra_k*(config.factor), -config.ancho_pista_giro*.9];
        coor_lin_1 = [bandejon_lim_izq(1), bandejon_lim_izq(2) + config.ancho_pista_giro,...
                      bandejon_lim_izq(1) + largo_cuadra_k*(config.factor_1), bandejon_lim_izq(2) + config.ancho_pista_giro ];
        coor_lin_2 = [bandejon_lim_der(1), coor_car_giro(2),...
                      bandejon_lim_der(1) + largo_cuadra_k*(config.factor_1), coor_car_giro(2)];
                      %bandejon_lim_der(1) + largo_cuadra_k*(config.factor), coor_car_giro(2)];
        yf = yf - config.ancho_pista;

        coor_car_2 = [xf, yf, largo_cuadra_k, config.ancho_pista];
        carril_2 = rectangle('Position', coor_car_2, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_carril);
        yf = yf - config.ancho_solera;

        coor_sol_2 = [xf, yf, largo_cuadra_k-config.ancho_solera, config.ancho_solera];
        solera_2 = rectangle('Position', coor_sol_2, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        yf = yf - config.ancho_vereda;

        coor_ver_2 = [xf, yf, largo_cuadra_k-config.ancho_solera, config.ancho_vereda];
        vereda_2 = rectangle('Position', coor_ver_2, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_vereda);
        
        % Bandejon central
        bandejon = rectangle('Position', coor_bandejon, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_bordes);
        % Limite izq-sup y der-inf
        bandejon_izq = rectangle('Position', bandejon_lim_izq, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        bandejon_der = rectangle('Position', bandejon_lim_der, 'EdgeColor', config.color_bordes, 'FaceColor', config.color_solera);
        % Lineas divisoras de pistas
        lin_1 = line('Color', 'y', 'LineStyle', '-.', ...
                    'XData', [coor_lin_1(1) coor_lin_1(3)],...
                    'YData', [coor_lin_1(2) coor_lin_1(4)]);
        lin_2 = line('Color', 'y', 'LineStyle', '-.', ...
                    'XData', [coor_lin_2(1) coor_lin_2(3)],...
                    'YData', [coor_lin_2(2) coor_lin_2(4)]);
        obj = [vereda_1, solera_1, carril_1, carril_giro, carril_2, solera_2, vereda_2, bandejon, bandejon_izq, bandejon_der, lin_1, lin_2];
        
end

