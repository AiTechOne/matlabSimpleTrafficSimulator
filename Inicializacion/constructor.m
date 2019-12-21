function sim = constructor(grilla, tiempo, trafico, uno)

%% Inputs
% grilla -> nXn calles
% tiempo -> Simulacion en segundos
% trafico -> opciones: bajo, medio y alto
try
    fprintf('\n\n-------------------------- Iniciando --------------------------\n\n')
    dir_actual = pwd;
    %% 1. Inicializar configuracion
    tic
    fprintf('Importando configuracion...\n')
    sim = init_config( grilla, tiempo, trafico, uno );
    etapa = toc;
    fprintf('    Terminado en %0.5f segundos\n', etapa)

    %% 2. Inicializar Grafo
    tic
    fprintf('Construyendo Grafo...\n')
    sim = init_grafo( sim );
    % sim = build_grafo( sim );
    etapa = toc;
    fprintf('    Terminado en %0.5f segundos\n', etapa)

    %% 3. Generar coordenadas calle y conectar con Grafo
    tic
    fprintf('Generando Infraestructura...\n ')
    sim = init_calles( sim );
    etapa = toc;
    fprintf('   Calles iniciadas en %0.5f segundos\n', etapa)

    % 3.2 Generar data para los segmentos (edges del grafo)
    tic
    sim = init_segmentos( sim );
    etapa = toc;
    fprintf('    Segmentos actualizados en %0.5f segundos\n', etapa)

    %% 4. Inicializar Semaforos
    tic
    sim = init_semaforos( sim );
    etapa = toc;
    fprintf('    Semaforos iniciados en %0.5f segundos\n', etapa)
    % sim = build_grafo(sim);
%     figure(sim.fig_sim)
%     print('example', '-dpng', '-r500')
     %% 5. Inicializar Autos
    tic
    fprintf('Generando Vehiculos...\n ')
    sim = init_vehiculos( sim );
    etapa = toc;
    fprintf('    %d Vehiculos generados en %0.5f segundos\n', sim.n_vehiculos, etapa)

    %% 6. Generar funcion "gps"
    tic
    fprintf('Generando funcion GPS...\n ')
    sim = init_gps( sim, dir_actual, grilla, tiempo, trafico);
    etapa = toc;
    fprintf('    Terminado en %0.5f segundos\n', etapa)


    %% 7. Exportar escenario a archivo
    % Opcional -> reordenar struct por orden alfabetico
    sim = orderfields(sim);
    nombre_mat = sprintf('%s/Escenarios/G%d_T%d_%s.mat', dir_actual, grilla, tiempo, trafico);
    nombre_gps = sprintf('%s/Escenarios/G%d_T%d_%s.mat', dir_actual, grilla, tiempo, trafico);
    save(nombre_mat, 'sim')
    fprintf('\nEscenario exportado en:\n    %s', nombre_mat)
    fprintf('\nGPS escenario exportado en:\n    %s', nombre_gps)

    fprintf('\n\n------------------- Construccion Finalizada -------------------\n\n')

catch exception
    fprintf('\n\n------------------------ Error!! ----------------------\n\n')
    msgText = getReport(exception);
    disp(msgText)
end
end
