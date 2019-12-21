orden = [0 1  2  3  0  0  5  6  7  0  0  7  8  9  11 42 0 0 9 10 43 0 0 5  19 30 0 0]
k = find(orden == 2)
ceros = find(orden==0);
idx_i = ceros(find(ceros < k, 1, 'Last'));
idx_f = ceros(find(ceros > k, 1, 'First'));

orden(idx_i: idx_f)
% ceros