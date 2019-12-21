clear
close all
clc

Vi = 13.889;
vf = 3;
dx = 50;


V = [Vi];
a = [0];
X = [0];
Ds = [dx];
figura=figure(); hold on; grid on; box on;
figura.Position = [-645 222 560 420];
plot(1, V(1), '-.*')
c=1;
for t=2:30
    tau = (V(t-1)+vf)/(2*(Ds(t-1)));
%     tau = 1- (V(t-1)/(dx));
   	V(t) = (V(t-1)-vf)*exp(-tau*c) + vf;
%     if X(t-1)/dx <=1
%         factor = -(1 - X(t-1)/dx);
%     else
%         factor = 0;
%     end
%     V2 = vf*exp(factor);
%     V(t) = (V(t-1))*exp(-tau*c) + V2;
    a(t) = V(t)-V(t-1);
    X(t) = X(t-1)+V(t-1)+0.5*a(t-1);
    Ds(t) = dx-X(t);
%     [c, V(t-1)/Ds(t-1), tau, V(t), a(t), X(t), Ds(t)];
%     input('')
%     plot(t, V2, '-.*')
end
a
plot([1:t], V, '-.*b')
plot([1:t], X, '-.o')
% plot([1:t], a, '-..r')