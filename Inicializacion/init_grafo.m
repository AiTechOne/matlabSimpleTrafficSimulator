function [sim] = init_grafo( sim )
% Funcion que genera un objeto de tipo digraph 
% (grafo direccionado) en funcion de una sim.grilla
% (n_calles verticales u horizontales)
conf_grafo = sim.config.grafo;
%% Variables de configuracion
p_rec = conf_grafo.peso_recta;
p_der = conf_grafo.peso_der;
p_izq = conf_grafo.peso_izq;

%% Calles (cuadra a cuadra)
calles =   [2 4  5  5 6 6  7  9];
d_calles = [4 2 -4 -2 2 4 -2 -4];
p_calles = [p_rec; inf; p_rec; p_rec; p_rec; p_rec; inf; p_rec];
p_calles = repmat(p_calles,sim.n_cuadras,1);
l_calles = length(calles);
% Inicializar vectores y vars auxiliares
ni_calles = zeros(6*sim.n_cuadras, 1);
nf_calles = zeros(3*sim.n_cuadras, 1);
k = 1;
aux_calles = calles;
% Recorrer
for i=1:sim.n_cuadras
    ni_calles(k:k+l_calles-1) = aux_calles;
    nf_calles(k:k+l_calles-1) = aux_calles + d_calles;
    aux_calles = aux_calles + 10;
    k = k + l_calles;
end

%% Intersecciones
% verticales
d_rec_v = 22 + (sim.grilla-1)*20;
d_der_v = 12 + (sim.grilla-1)*10;
d_izq_v = 11 + (sim.grilla-1)*10;
% horizontales
d_rec_h = 2;
d_der_h = -(11 + (sim.grilla-1)*10);
d_izq_h = 14 + (sim.grilla-1)*10;

inter = [8 10 10 ...
    10+(10*sim.grilla)-2 10+(10*sim.grilla) 10+(10*sim.grilla)...
    10+(10*sim.grilla)+3 10+(10*sim.grilla)+1 10+(10*sim.grilla)+1 ...
    13+(20*sim.grilla) 11+(20*sim.grilla) 11+(20*sim.grilla)];
d_inter = [d_izq_v d_der_v d_rec_v...
    d_izq_h d_der_h d_rec_h...
    -d_izq_h -d_der_h -d_rec_h...
    -d_izq_v -d_der_v -d_rec_v];
p_inter = [p_izq; p_der; p_rec];
p_inter = repmat(p_inter, 4*sim.n_intersecciones, 1);

ni_inter = zeros(12*sim.n_intersecciones, 1);
nf_inter = zeros(12*sim.n_intersecciones, 1);
k = 1;
aux_inter = inter;

for i=1:sim.n_intersecciones
    ni_inter(k:k+11) = aux_inter;
    nf_inter(k:k+11) = aux_inter + d_inter;
    if (mod(i,sim.grilla) == 0) % Si sube a la inter de arriba
        aux_inter = aux_inter + (20+sim.grilla*10);
    else % si va a la interseccion de la derecha
        aux_inter = aux_inter + 10;
    end
    k = k+12;
end

%% Grafo
origen = [ni_calles;ni_inter];
destino = [nf_calles;nf_inter];
pesos = [p_calles;p_inter];
G = digraph(origen, destino, pesos);
sim.n_segmentos = size(G.Edges,1);

%% Procesar Nodos

% Nodos Iniciales y Finales
iniciales = zeros(conf_grafo.n_nodos,1);
finales = zeros(conf_grafo.n_nodos,1);
if_ver = zeros(conf_grafo.n_nodos,1);
if_hor = zeros(conf_grafo.n_nodos,1);
id_calle = zeros(conf_grafo.n_nodos,1);
dir_carril = zeros(conf_grafo.n_nodos,1);

aux_calle = 1;
aux = 2;
% Vertical
d_if_v = 20*sim.grilla^2 + 10*sim.grilla + 8; 
for k=1:2:sim.n_calles
    % vuelta (impares)
    % Iniciales = terminados en 9
    iniciales(aux + d_if_v - 1) = 1;
    if_ver(aux + d_if_v - 1) = 1;
    % Finales = terminados en 1 o 3
    % -> 1
    finales(aux - 1) = 1;
    if_ver(aux - 1) = 1;
    % -> 3
    finales(aux + 1) = 1;
    if_ver(aux + 1) = 1;
    % Buscar nodos de la misma calle para asignar id
    aux_nodos = shortestpath(G, aux + d_if_v - 1, aux - 1);
    id_calle(aux_nodos) = aux_calle;
    dir_carril(aux_nodos) = -1;

    % ida (pares)
    % Iniciales = terminados en 2
    iniciales(aux) = 1;
    if_ver(aux) = 1;
    % Finales = terminados en 8 o 10
    % -> 10
    finales(aux + d_if_v) = 1;    
    if_ver(aux + d_if_v) = 1;
    % -> 8
    finales(aux + d_if_v - 2) = 1;
    if_ver(aux + d_if_v - 2) = 1;
    % Buscar nodos de la misma calle
    aux_nodos = shortestpath(G, aux, aux + d_if_v);
    id_calle(aux_nodos) = aux_calle;
    dir_carril(aux_nodos) = 1;
    % Aumentar aux e id de calle
    aux = aux + 10;
    aux_calle = aux_calle + 1;
end
% Horizontal
d_if_h = 18 + (sim.grilla-1)*10;
for k=1:2:sim.n_calles
    % vuelta (impar)
    % Iniciales = terminados en 9
    iniciales(aux + d_if_h - 1) = 1;
    if_hor(aux + d_if_h - 1) = 1;
    % Finales = terminados en 1 o 3
    % -> 1
    finales(aux - 1) = 1;
    if_hor(aux - 1) = 1;
    % -> 3
    finales(aux + 1) = 1;
    if_hor(aux + 1) = 1;
    
    % Buscar nodos de la misma calle
    aux_nodos = shortestpath(G, aux + d_if_h - 1, aux - 1);
    id_calle(aux_nodos) = aux_calle;
    dir_carril(aux_nodos) = -1;
    
    % ida (pares)
    % Iniciales = terminados en 2
    iniciales(aux) = 1;
    if_ver(aux) = 1;
    % Finales = terminados en 8 o 10
    % -> 10
    finales(aux + d_if_h) = 1;    
    if_ver(aux + d_if_h) = 1;
    % -> 8
    finales(aux + d_if_h - 2) = 1;
    if_ver(aux + d_if_h - 2) = 1;
    % Buscar nodos de la misma calle
    aux_nodos = shortestpath(G, aux, aux + d_if_h);
    id_calle(aux_nodos) = aux_calle;
    dir_carril(aux_nodos) = 1;  
    % Aumentar aux e id de calle
    aux = aux + (30 + (sim.grilla-1)*20);
    aux_calle = aux_calle + 1;
end

% Arreglo para sumar los nodos de las pistas de giro:
aux = [1 6];
for k=1:sim.n_cuadras
   id = id_calle(aux(1));
   dirc = dir_carril(aux(1));
   id_calle(aux(1)+2) = id;
   dir_carril(aux(1)+2) = dirc;
   
   id = id_calle(aux(2));
   dirc = dir_carril(aux(2));
   id_calle(aux(2)+2) = id;
   dir_carril(aux(2)+2) = dirc;
   
   aux = aux + 10;
end

%% Exportar data
% Anexar a tablas del grafo:
G.Nodes.id = (1:1:conf_grafo.n_nodos)';
G.Nodes.id_calle = id_calle;
G.Nodes.dir_carril = dir_carril;
% G.Nodes.iniciales = iniciales;
% G.Nodes.finales = finales;
% G.Nodes.if_ver = if_ver;
% G.Nodes.if_hor = if_hor;

% Guardar en struct sim
sim.nodos_iniciales = find(iniciales==1)';
sim.nodos_finales = find(finales==1)';

% Añadir grafo a struct sim:
sim.grafo = G;
end

