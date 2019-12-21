function sim = init_vehiculos( sim )
s = rng(1);

%% Funcion encargada  de inicializar los vehiculos y sus rutas iniciales.

config_autos = sim.config.autos;
%% Generar vector con numero de vehiculos por segundo, siguiendo
% distribucion poisson con parametro lambda, de acuerdo al nivel de trafico
% configurado para la simulacion.
n_nodos_i = size(sim.nodos_iniciales,2);

%% Numero de vehiculos a simular
if sim.config.autos.uno == 0
    % Simular segun poisson
    pd = makedist('Poisson', 'lambda', config_autos.lambda);
    autos_t = [0, random(pd, 1, sim.tiempo-1)];
else
    % SIMULAR SOLO 1
    autos_t = zeros(1, sim.tiempo);
    autos_t(10) = 1;
    sim.nodos_iniciales = sim.nodos_iniciales(1);
%     sim.nodos_iniciales = 312;
%     sim.nodos_finales = 31;
    sim.nodos_finales = sim.nodos_finales(end);
%     sim.nodos_finales = 220;
end

% Arreglar segundos en los que se generen mas autos que entradas:
out = (autos_t > n_nodos_i);
autos_t(out) = n_nodos_i;
% Numero de autos de la simulacion:
n_vehiculos = sum(autos_t);

%% Distribucion para factor de agresividad
pd = makedist('Normal', config_autos.agresividad(1), config_autos.agresividad(2));

%% Struct sim.auto
% Tabla sim
auto = table();
auto.id = transpose(1:n_vehiculos);
auto.activo = zeros(n_vehiculos, 1);
auto.t_inicial = zeros(n_vehiculos, 1);
auto.t_final = zeros(n_vehiculos, 1);
auto.nodo_i = zeros(n_vehiculos, 1);
auto.nodo_f = zeros(n_vehiculos, 1);

auto.largo = zeros(n_vehiculos, 1); % largo del vehiculo
auto.ancho = zeros(n_vehiculos, 1); % ancho del vehiculo
auto.agresividad = round(random(pd, n_vehiculos, 1));
if any(auto.agresividad==0)
    idx = auto.agresividad==0;
    auto.agresividad(idx) = 1;
end
auto.obj = cell(n_vehiculos, 1);

% Variables kinematics
% auto.idx_ruta = zeros(n_vehiculos, 1);
auto.idx_seg_actual = zeros(n_vehiculos, 1);
auto.idx_seg_tiempo = cell(n_vehiculos, 1);
auto.idx_seg_anteriores = cell(n_vehiculos, 1);
auto.idx_seg_siguientes = cell(n_vehiculos, 1); % condiciones de cruce

auto.accion_siguiente = zeros(n_vehiculos, 1); % Recta = 1, Der = 2, Izq = 3

auto.d_total = zeros(n_vehiculos, 1); % con respecto al segmento 
auto.d = cell(n_vehiculos, 1); % acumulado
auto.v = cell(n_vehiculos, 1);
auto.a = cell(n_vehiculos, 1);
auto.alcances = zeros(n_vehiculos, 1);

% Grafica
auto.orientacion_a = zeros(n_vehiculos, 1);
auto.orientacion_i = zeros(n_vehiculos, 1);
auto.orientacion_f = zeros(n_vehiculos, 1);
auto.x = cell(n_vehiculos, 1);
auto.y = cell(n_vehiculos, 1);

% Actualizaciones por algoritmo de ruteo
auto.ruta_nodos_i = cell(n_vehiculos, 1);
auto.peso_i = zeros(n_vehiculos, 1);

auto.ruta_f = cell(n_vehiculos, 1);
auto.peso_f = zeros(n_vehiculos, 1);
auto.rutas = cell(n_vehiculos, 1);
auto.n_actualizaciones = zeros(n_vehiculos, 1);

%% Generar vehiculos y rutas
id_auto = 1;
h = waitbar(0, 'Generando Vehiculos...');

for t=2:sim.tiempo
    waitbar(t / sim.tiempo)
    % num aleatorio
    if sim.grilla == 1 % caso particular con rutas inalcanzables
        ini = randperm(numel(sim.nodos_iniciales));
        idx_i = sim.nodos_iniciales(ini(1:autos_t(t)));
        idx_f = zeros(1, length(idx_i));
        for k=1:length(idx_i)
            while 1
                aux = sim.nodos_finales(randi([1,length(sim.nodos_finales)],1,1));
                if abs(idx_i(k)-aux) ~= 1
                    idx_f(k) = aux;
                    break
                else
                    continue
                end
            end
        end
    else
        % elegir entradas y salidas de forma aleatoria
        ini = randperm(numel(sim.nodos_iniciales));
        idx_i = sim.nodos_iniciales(ini(1:autos_t(t)));
        idx_f = sim.nodos_finales(randi( [1, length(sim.nodos_finales)], 1, length(idx_i)));
    end
    for n=1:autos_t(t)
        auto.t_inicial(id_auto) = t;

        auto.nodo_i(id_auto) = idx_i(n);
        auto.nodo_f(id_auto) = idx_f(n);
        [ruta, peso, ids_segmentos] = rutas_segmentos(sim.grafo, auto.nodo_i(id_auto), auto.nodo_f(id_auto));

        auto.ruta_nodos_i{id_auto} = ruta;
        auto.peso_i(id_auto) = peso;
        % auto.idx_ruta(id_auto) = 1;
        auto.idx_seg_actual(id_auto) = ids_segmentos(1);
        % Vector id_seg(t)
        auto.idx_seg_tiempo{id_auto} = zeros(sim.tiempo, 1);
        auto.idx_seg_siguientes{id_auto} = ids_segmentos(2:end);
        auto.accion_siguiente(id_auto) = sim.grafo.Edges.tipo_curva(auto.idx_seg_siguientes{id_auto}(1));

        auto.largo(id_auto) = randi(config_autos.largos,1,1);
        auto.ancho(id_auto) = config_autos.anchos/randi([1,3],1,1); % ancho * num aleatorio

        auto.d_total(id_auto) = 0;

        %Inicializar variables x,y,a,v,d en -1 hasta t-1
        auto.d{id_auto} = zeros(sim.tiempo, 1);
        auto.v{id_auto} = zeros(sim.tiempo, 1);
        auto.v{id_auto}(t) = config_autos.v_inicial;
        auto.a{id_auto} = zeros(sim.tiempo, 1);

        %Posicion en el mapa
        auto.orientacion_a(id_auto) = sim.grafo.Edges.rectas_vh(ids_segmentos(1));
        auto.orientacion_i(id_auto) = sim.grafo.Edges.rectas_vh(ids_segmentos(1));

        auto.x{id_auto} = zeros(sim.tiempo, 1);
        auto.x{id_auto}(t) = sim.grafo.Nodes.x(auto.nodo_i(id_auto));
        auto.y{id_auto} = zeros(sim.tiempo, 1);
        auto.y{id_auto}(t) = sim.grafo.Nodes.y(auto.nodo_i(id_auto));

        % Inicializar objeto
        if auto.orientacion_a(id_auto) == 1 % vertical => x-ancho/2 y-largo/2
            aux_po = [auto.x{id_auto}(t)-auto.ancho(id_auto)/2 auto.y{id_auto}(t)-auto.largo(id_auto)/2 auto.ancho(id_auto) auto.largo(id_auto)];
        elseif auto.orientacion_a(id_auto) == 2 % horizontal
            aux_po = [auto.x{id_auto}(t)-auto.largo(id_auto)/2 auto.y{id_auto}(t)-auto.ancho(id_auto)/2 auto.largo(id_auto) auto.ancho(id_auto)];
        end
        auto.obj{id_auto} = rectangle('Position', aux_po,...
            'FaceColor', rgb(config_autos.colores(randi(size(config_autos.colores,2)))), 'Visible', 'off');
        id_auto = id_auto + 1;
    end

end


% Exportar
% sim.vehi_tabla = auto;
sim.vehiculo = table2struct(auto);
sim.n_vehiculos = n_vehiculos;
% Cerrar cuadro de avances
close(h);
end

