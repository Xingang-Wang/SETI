%% quasi
clc;clear;
mod_num=5;
transient=40002;
F=@(t,Y)[2*pi*Y(2);...
        2*pi*Y(2).*(Y(1).*Y(1)-0.5*Y(1).^4)-4*pi^2*Y(1);...
         0.9-Y(1).*Y(1);...
         ];   
opt = odeset( 'RelTol', 10.0^(-7), 'AbsTol' , 10.0^(-7));     
y0=rand(3,1);
[t,Y] = ode45(F, [0:0.001:2000], y0, opt);
data_quasi=Y(transient:end,:);
max_quasi=zeros(3,1);
min_quasi=zeros(3,1);
for i=1:3
max_quasi(i) = max(data_quasi(:,i));
min_quasi(i) = min(data_quasi(:,i));
end
normalized_quasi=data_quasi';
% 归一化
data_qua=[];
for i=1:3
normalized_quasi(i,:) = (data_quasi(:,i)' - min_quasi(i)) / (max_quasi(i)-min_quasi(i));
xf1=normalized_quasi(i,:);
x_pos=1:size(xf1,2);
xf1=xf1(mod(x_pos,mod_num)==0);
data_qua=[data_qua;xf1];
end
figure
plot(data_qua(1,end-1000:end),'.-');
save train_data_qua.mat data_qua