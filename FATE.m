%% Trabajo de Titulo Felipe Tejada Primavera 2017
% Mail: felipe.tejada@ug.uchile.cl

%% Eliminar y agregar directorios
clc
clear
% Eliminar todas las imagenes que queden guardadas en memoria
handles=findall(0,'type','figure');
for i=1:size(handles)
    close(handles(i))
end
close all

% Agrega y revisa directorios necesarios
try
    addpath('Inicializacion')
catch exception
    disp('La carpeta Inicializacion y sus archivos no estan presentes! Programa abortado por falta de dependencias')
    exit()
end
try
    addpath('Funciones_Sim')
catch exception
    disp('La carpeta Funciones_Sim y sus archivos no estan presentes! Programa abortado por falta de dependencias')
    exit()
end
try
    addpath('Escenarios')
catch exception
    mkdir('Escenarios')
    mkdir('Escenarios', 'Old')
    addpath(genpath('Escenarios'))
end

%% Simulacion
%% 1. Inputs
grilla = 1; % nXn > 0
tiempo = 200; % Simulacion en segundos > 100
trafico = 'alto'; % opciones: bajo, medio y alto

graficar = 1; % si se muestra o no graficamente el movimiento de los vehiculos
uno = 0; % simular solo un vehiculo

%% 2. Importar escenario (si existe), sobreescribir existente o generar uno
% nuevo
dir_actual = pwd;
dir_nombre = sprintf('%s/Escenarios/G%d_T%d_%s.mat', dir_actual, grilla, tiempo, trafico);
nombre_mat = sprintf('Escenarios/G%d_T%d_%s.mat', grilla, tiempo, trafico);
nombre_gps = sprintf('Escenarios/GPS_G%d_T%d_%s.m', grilla, tiempo, trafico);
try
    load(dir_nombre);
    str = 'El escenario existe!. Deseas sobreescribirlo con uno nuevo? [so]/[act]: ';
    nuevo = input(str, 's');
    while 1
        if strcmpi(nuevo, 'so')||strcmpi(nuevo, '')
            clear sim
 
            aux = char(datetime('now', 'Format', 'dmyHHmm'));
            nombre_mat2 = strcat(nombre_mat(1:end-4), '_', aux, '.mat');
            nombre_gps2 = strcat(nombre_gps(1:end-2), '_', aux, '.m');
            movefile(nombre_mat, nombre_mat2)
            movefile(nombre_gps, nombre_gps2)

            fprintf('\n OK! Anterior respaldado. Generando uno nuevo...\n')
            sim = constructor(grilla, tiempo, trafico, uno);
            clearvars -EXCEPT sim nombre_mat nombre_gps graficar
            simular = 1;
            break
            
        elseif strcmpi(nuevo, 'act')
            clearvars -EXCEPT sim nombre_mat nombre_gps graficar
            fprintf('\n OK! Se simulara sobre el programa actual\n')
            simular = 1;
            break
            
        else 
            str = 'Opcion invalida. Vuelve a intentarlo[so]/[act]: ';
            nuevo = input(str, 's');
        end
    end
catch exception
    str = 'No existe el escenario especificado. Deseas generarlo ahora? [s]/[n]: ';
    nuevo = input(str, 's');
    while 1
        if strcmpi(nuevo, 's')||strcmpi(nuevo, '')
            sim = constructor(grilla, tiempo, trafico, uno);
            clearvars -EXCEPT sim nombre_mat nombre_gps graficar
            simular = 1;
            break
        elseif strcmpi(nuevo, 'n')
            disp('Programa finalizado. Hasta pronto!')
            simular = 0;
            break
        else 
            str = 'Opcion invalida. Vuelve a intentarlo[s]/[n]: ';
            nuevo = input(str, 's');
        end
    end
end

%% 3. Simular

% Opciones extras para analizar casos:
% simular = 0;
% sim.grafo.Edges.Weight(10) = sim.grafo.Edges.Weight(10)+1;
% % sim.grafo.Edges.Weight(172) = inf;
% % sim.grafo.Edges.Weight(770) = inf;
% 
% [ ruta, peso, ids_segmentos ] = rutas_segmentos( sim.grafo, sim.vehiculo(1).nodo_i, sim.vehiculo(1).nodo_f );
% sim.vehiculo(1).ruta_nodos_i = ruta;
% sim.vehiculo(1).peso_i = peso;
% sim.vehiculo(1).idx_seg_actual = ids_segmentos(1);
% sim.vehiculo(1).idx_seg_siguientes = ids_segmentos(2:end);
% sim.vehiculo(1).accion_siguiente = sim.grafo.Edges.tipo_curva(sim.vehiculo(1).idx_seg_siguientes(1));

if simular
    try
        fprintf('\n\n---------------------- Iniciando Simulacion -----------------------\n\n')
        % Simulacion
        h = waitbar(0, 'Simulando...');
        activos = zeros(1, sim.n_vehiculos);
        % Activar los semaforos 
        [ sim ] = sim_semaforos(1, sim, 0);
        for t=2:sim.tiempo
            waitbar(t / sim.tiempo)
            % 1. Semaforos
            [ sim ] = sim_semaforos( t, sim, 0);
            % 2. Activar y posicionar todos los vehiculos sim_activador( t, vehiculo, grafo, activos, grafica)
            [ sim.vehiculo, sim.grafo, activos ] = sim_activador( t, sim.vehiculo, sim.grafo, 0);
            % 3. Seleccionar los segmentos a procesar
            [ supersegmentos ] = sim_orden_procesamiento( t, sim, activos );
            % 4. Aplicar kinematics
            [ sim ] = sim_kinematics(t, sim, supersegmentos);
        end        
        close(h)
    catch exception
        fprintf('\n\n------------------------ Error!! ----------------------\n\n')
        msgText = getReport(exception);
        disp(msgText)
    end
    fprintf('\n\n---------------------- Simulacion Finalizada -----------------------\n\n')

    
    % Ahora solo se graficara lo ya emulado
    try
        if graficar
            fprintf('\n\n---------------------- Iniciando Grafica -----------------------\n\n')
            x = [sim.vehiculo.x];
            y = [sim.vehiculo.y];
            pos = plot(zeros(sim.n_vehiculos),zeros(sim.n_vehiculos),'sb');
            % Activar los semaforos 
            [ sim ] = sim_semaforos(1, sim, graficar);
            for t=2:sim.tiempo
                % 1. Iniciar grafico
                figure(sim.fig_sim)
                % 1.2 Opcional: iniciar grafo
                % % sim = build_grafo( sim );
                % 2. Mostrar el Tiempo de la simulacion arriba:
                delete(findall(gcf,'Tag','reloj'))
                annotation('textbox', [.2 .2 .4 .6] , 'String',strcat('Tiempo: ', num2str(t)), 'FitBoxToText', 'on', 'Tag' , 'reloj');
                % 3. Semaforos
                [ sim ] = sim_semaforos(t, sim, graficar);
                
                % 4. Activar los obj de los vehiculos para ver la grafica
                [ sim.vehiculo, sim.grafo, activos ] = sim_activador( t, sim.vehiculo, sim.grafo,  1);
                % 5. Actualizar grafica de los vehiculos vehiculos
                sim_graficar_vehiculos(t, sim.vehiculo, activos);
                
                %4.5- Metodo simplificado:
                %set(pos, 'XData', x(t,:), 'YData', y(t,:))
                
                % 6. Tiempo refresco
                pause(.5)
            end
            % Finalizada
            delete(findall(gcf,'Tag','reloj'))
            annotation('textbox', [.2 .2 .4 .6] , 'String',strcat('Finalizado! (T=', num2str(t), ' segundos)'), 'FitBoxToText', 'on', 'Tag' , 'reloj');
            fprintf('\n\n---------------------- Grafica Finalizada -----------------------\n\n')
        end
    catch exception
        fprintf('\n\n------------------------ Error!! ----------------------\n\n')
        msgText = getReport(exception);
        disp(msgText)
    end
end

try
    clear activos simular supersegmentos t h
    if graficar
        clear x y pos
    end
catch
    fprintf('    Simulacion incompleta\n\n')
end

% Final
try
    if sim.config.autos.uno == 1
        estadisticas_auto( sim )
        % Exportar grafica
        % print('grafo_2', '-dpng', '-r400')
    end
catch exception
    fprintf('\n\n------------------------ Error!! ----------------------\n\n')
    msgText = getReport(exception);
    disp(msgText)
end
