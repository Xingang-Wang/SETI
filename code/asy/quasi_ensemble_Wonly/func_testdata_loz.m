%clc;clear;
function [testdata]= func_testdata_loz(testnum,test_length)
data_num=1;
data_len=ones(1,data_num)*5000;
%testnum=10;
%mod_num=20;
mod_num=5;
transient=40002;
rng(1);
%% quasi 
F=@(t,Y)[2*pi*Y(2);...
        2*pi*Y(2).*(Y(1).*Y(1)-0.5*Y(1).^4)-4*pi^2*Y(1);...
         0.9-Y(1).*Y(1);...
         ]; 
% %% Lorenz
% F=@(t,Y)[10*Y(2)-10*Y(1);...
%          -Y(1).*Y(3)+28*Y(1)-Y(2);...
%          Y(1).*Y(2)-8*Y(3)/3;...
%          ];
         
opt = odeset( 'RelTol', 10.0^(-7), 'AbsTol' , 10.0^(-7));     
y0=rand(3,1);
[t,Y] = ode45(F, [0:0.001:2000], y0, opt);
data_lorenz=Y(transient:end,:);
max_loz=zeros(3,1);
min_loz=zeros(3,1);
for i=1:3
max_loz(i) = max(data_lorenz(:,i));
min_loz(i) = min(data_lorenz(:,i));
end
normalized_loz=data_lorenz';
% 归一化
data_loz=[];
for i=1:3
normalized_loz(i,:) = (data_lorenz(:,i)' - min_loz(i)) / (max_loz(i)-min_loz(i));
xf1=normalized_loz(i,:);
x_pos=1:size(xf1,2);
xf1=xf1(mod(x_pos,mod_num)==0);
data_loz=[data_loz;xf1];
end
%%
testdata=zeros(3*testnum,test_length+1);
train_data = data_loz(:,1:data_len);
%testdata=data_loz(:,data_len+1:end);
for i=0:testnum-1
    testdata(3*i+1:3*i+3,:)=data_loz(:,data_len+1+i*test_length:data_len+1+(i+1)*test_length);
end
