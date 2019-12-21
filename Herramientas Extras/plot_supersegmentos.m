close all

fig_orden = figure();
% subplot(2,1,1)
fig_orden.Position = [200 211 942 254];
hold on
box on
% grid on
l_min = 0;
orden = {[1,6], 3, [5 8 15], 9, [12, 16], 17 28 29 33 [40, 37] 39 42};
max_s = 1;
orden_final = [];
for j=1:size(orden, 2)
    l = size(orden{j},2);
    if max_s < l
        max_s = l;
    end
    if -l+2 < l_min
        l_min = -l+2;
    end
    % Circulos
    plot(repmat(j, 1, l), [1:-1:-l+2], 'o', 'MarkerSize', 22)
    for k=l:-1:1
        orden_final = [orden_final orden{j}(k)];
        % Numeros de los segmentos
        a=text(j, k-l+1, strcat('S ',num2str(orden{j}(k))));
        a.HorizontalAlignment = 'center';
        a.FontSize = 11;
    end
end

ax = gca;
ax.YLim = [l_min-0.5 1.5];
ax.XLim = [0 j+1];
ax.XTick = 1:1:j;
ax.YTick = l_min:1:1;
ylabel('Prioridad')
xlabel('SuperSegmentos(t=57)')
% 
% subplot(2,1,2)
% plot(1:j,1 , '-.o', 'MarkerSize', 18)
% ax2 = gca;
% ax2.XTick = 1:1:j;
% orden_final;