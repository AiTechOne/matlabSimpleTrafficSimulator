function [ sim] = init_config( grilla, tiempo, trafico, un_vehiculo )
%% Simulacion
sim = struct();
% Definiciones
sim.grilla = grilla;
sim.tiempo = tiempo; % segundos
sim.trafico = char(trafico);

sim.Vmax = 50/3.6; % m/s
sim.Vmax_curva = 10/3.6;
sim.Vmin = 0/3.6; % m/s

% Variables
sim.n_calles = grilla* 2;
sim.n_intersecciones = grilla^2;
sim.n_semaforos = grilla^2 * 8 + 8*grilla;
sim.n_semaforos_calle = sim.n_semaforos/sim.n_calles;
sim.n_cuadras_calle = grilla + 1;
sim.n_cuadras = sim.n_cuadras_calle * sim.n_calles;
sim.n_nodos = sim.n_cuadras * 10; % se repite en config del grafo
% sim.n_segmentos_teo = 12*sim.n_intersecciones + 8*sim.n_cuadras;

%% Grafo
grafo = struct();
grafo.n_nodos = sim.n_cuadras * 10;
% Definiciones
grafo.n_nodos_cuadra = 4; %(una via)
grafo.peso_recta = 10;
grafo.peso_der = 20;
grafo.peso_izq = 30;
% graficar nodos en calles
grafo.graficar_nodos = 0;
grafo.size_nodos = 1.2;
grafo.color_nodos = 'g';

%% Calles
calles = struct();
% Definiciones
calles.ancho_pista = 3;
calles.ancho_pista_giro = 3;
calles.ancho_solera = 0.2;
calles.ancho_vereda = 1.5;
calles.ancho_calle = calles.ancho_pista*2 + calles.ancho_pista_giro;
calles.ancho_giro_izquierda = 3*calles.ancho_pista/2 + calles.ancho_pista_giro;
calles.ancho_giro_derecha = calles.ancho_pista/2;
calles.ancho_cambio_pista = calles.ancho_pista/2 + calles.ancho_pista_giro/2;

calles.largo_cuadra = 150; % en metros
calles.color_carril = 'k';
calles.color_inter = 'k';
calles.color_vereda = rgb('WhiteSmoke');
calles.color_solera = rgb('Silver');
calles.color_bordes = [0.1 0.1 0.1];

% Porcentaje de la calle donde esta el nodo medio (apertura pista de giro)
% Debe ser mayor o igual a 0.5
calles.factor = 0.5;

calles.factor_1 = 1 - calles.factor;
calles.factor_d = calles.factor - calles.factor_1;
calles.factor_d_1 = 1 - calles.factor_d;

% Distancias rectas
calles.recta_derecha = calles.ancho_pista/sqrt(2); % sqrt(2 * (ancho_pista/2)^2) = sqrt(ancho_pista^2 / 2)
calles.recta_izquierda = sqrt((3*calles.ancho_pista/2 + calles.ancho_pista_giro)^2 + (calles.ancho_pista + calles.ancho_pista_giro/2)^2);
calles.recta_recto = calles.ancho_calle;
calles.porcentaje_cambio_pista = 0.1; 

% Angulos
calles.angulo_derecha = acos(calles.ancho_giro_derecha/calles.recta_derecha);
calles.angulo_izquierda = acos(calles.ancho_giro_izquierda/calles.recta_izquierda);

% Modelado de curvas - Geometrï¿½a:
% distancia recta
calles.dist_recta = 2*calles.ancho_pista + calles.ancho_pista_giro;
% distancia recta + distancia curva (arco 4to de circ)
calles.dist_izq = (calles.ancho_pista + calles.ancho_pista_giro)/2 ...
                  + 2*pi*(calles.ancho_pista + calles.ancho_pista_giro/2);
% distancia curva (arco 4to de circ)
calles.dist_der = pi*calles.ancho_pista;

% Largos variables? => simetricas = 0
calles.simetricas = 1;
switch calles.simetricas
    case 1
        calles.factor_min = 1;
        calles.factor_max = 1;
    case 0
        calles.factor_min = .7;
        calles.factor_max = 1.3;
end

%% Struct de calle y substruct de cuadras
% Data calle
calle = struct();
calle.nodos_vuelta = [];
calle.nodos_ida = [];
calle.orientacion = [];
calle.x_if = [];
calle.y_if = [];
calle(sim.n_calles).largo = [];

% Data Cuadra
cuadra = struct();
cuadra.id_calle = [];
cuadra.id_cuadra = [];
cuadra.nodos_vuelta = [];
cuadra.nodos_ida = [];
cuadra.x_if = [];
cuadra.y_if = [];
cuadra.largo = [];
% cuadra.Vmax = 0;
% cuadra.vel_min = 0;
cuadra.obj(sim.n_cuadras_calle) = 0;

% Mezclar
for ca=1:sim.n_calles
    calle(ca).cuadra = cuadra;
end

%% Autos 
autos = struct();
autos.largos = [3,6];  % Rango de largos en metros
autos.anchos = calles.ancho_pista_giro*.9;
autos.v_inicial = sim.Vmax_curva;

% modelar solo 1 vehiculo
autos.uno = un_vehiculo;

autos.colores = {'OrangeRed', 'GreenYellow', 'Aqua', 'DeepPink', 'Gold', 'DeepSkyBlue', 'LightBlue', 'Salmon', 'MediumSpringGreen'};
autos.trafico = char(trafico);
if strcmp(autos.trafico, 'alto')
    autos.lambda = sim.n_calles*1600/3600;
elseif strcmp(autos.trafico, 'medio')
    autos.lambda = sim.n_calles*640/3600;
elseif strcmp(autos.trafico, 'bajo')
    autos.lambda = sim.n_calles*160/3600;    
end
autos.agresividad = [2, 0.4]; % Media y desviacion de la normal
%autos.v_agresividad = [0, 5]; % media y desviacion de la normal

%% Semaforos
semaforos = struct();
% Tipos
semaforos.principal = 1;
semaforos.secundario = 2;
% Tamaño
semaforos.ancho_p = calles.ancho_pista;
semaforos.ancho_s = calles.ancho_pista_giro;
semaforos.alto = calles.ancho_pista * .2;

% Tiempos 
% Tiempo en activar la verde entre intersecciones (de una calle)
semaforos.factor_t_delta = 0.7;
semaforos.t_delta = ceil(calles.largo_cuadra/(sim.Vmax*semaforos.factor_t_delta));
% Verde 1 => semaforo principal
semaforos.t_verde_p = 2 * semaforos.t_delta;
% Verde 2 => semaforo secundario -> 30% del tiempo del principal
semaforos.t_verde_s = ceil(semaforos.t_verde_p * .3);
semaforos.t_amarilla = 3; % fijo
semaforos.t_rojo_entreverde = 1;
semaforos.t_ciclo = semaforos.t_verde_p + semaforos.t_verde_s + semaforos.t_amarilla*2 + semaforos.t_rojo_entreverde*2;

% semaforos.t_verde_p = 15;
% semaforos.t_verde_s = 8;
% semaforos.t_amarilla = 3; % fijo
% semaforos.t_rojo_entreverde = 1;
% semaforos.t_ciclo = semaforos.t_verde_p + semaforos.t_verde_s + semaforos.t_amarilla*2 + semaforos.t_rojo_entreverde;
% semaforos.t_delta = round(semaforos.t_ciclo/2);


% Simetrico implica que los tiempos de los semaforos de una misma calle son
% sincronizados para la ida y vuelta (tanto en primario como secundario);
semaforos.simetricos = 1; 

% No existe otro metodo implementado por ahora pero podria aparecer
% despues.

%% Figuras
% Calle
fig_calles = figure();
fig_calles.Name = sprintf('Simulacion Trafico Grilla %dx%d - %d Segundos - Trafico %s', grilla, grilla, tiempo, trafico);
% fig_calles.Color = [1 1 1];
fig_calles.Color = [1 1 1];
% fig_calles.Position = [-1023 1 1024 692];
user = getenv('USER');
fate = 0;
if ~isempty(user)
    fprintf('Running on %s''s PC\n', user)
    fate = strcmp(user,'fate');
end
if fate
    fig_calles.Position = [1, 64, 852, 910];
end
fig_calles.Visible = 'off';
axis_calles = gca;
axis_calles.NextPlot = 'add'; % <=> hold on; 
axis_calles.Visible = 'off'; % <=> axis tight off; 

%% Tiempos de seguridad
sim.tS = 3; % tiempo de distancia distancia segura

%% Outputs
% 1. Struct con configuraciï¿½n:
config = struct();
config.grafo = grafo;
config.calles = calles;
config.semaforos = semaforos;
config.autos = autos;

% 2. Struct de simulacion
sim.config = config; % guardar toda la config
sim.calle = calle;
sim.fig_sim = fig_calles;
% sim.fig_grafo = fig_grafo;

end