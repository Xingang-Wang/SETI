%clc;clear;
function [train_data,testdata,data_num,data_len]= func_dataset_loz(testnum)
data_num=1;
data_len=ones(1,data_num)*10000;
%testnum=10;
mod_num=5;
transient=40002;
rng(1);
%% quasi;
F=@(t,Y)[2*pi*Y(2);...
        2*pi*Y(2).*(Y(1).*Y(1)-0.5*Y(1).^4)-4*pi^2*Y(1);...
         0.9-Y(1).*Y(1);...
         ];   
        
opt = odeset( 'RelTol', 10.0^(-7), 'AbsTol' , 10.0^(-7));     
y0=rand(3,1);
[t,Y] = ode45(F, [0:0.001:2000], y0, opt);
data_chen=Y(transient:end,:);
max_chen=zeros(3,1);
min_chen=zeros(3,1);
for i=1:3
max_chen(i) = max(data_chen(:,i));
min_chen(i) = min(data_chen(:,i));
end
normalized_chen=data_chen';
% 归一化
data_Chen=[];
for i=1:3
normalized_chen(i,:) = (data_chen(:,i)' - min_chen(i)) / (max_chen(i)-min_chen(i));
xf1=normalized_chen(i,:);
x_pos=1:size(xf1,2);
xf1=xf1(mod(x_pos,mod_num)==0);
data_Chen=[data_Chen;xf1];
end
%%
testdata=zeros(3*testnum,1001);
transient=50002;
train_data = data_Chen(:,1:data_len);
figure
plot(train_data(1,:),'.-');
%testdata=data_loz(:,data_len+1:end);
data_chen=Y(transient:end,:);
for i=0:testnum-1
    testdata(3*i+1:3*i+3,:)=data_Chen(:,data_len+1+i*1000:data_len+1+(i+1)*1000);
end

% plot3(train_data(1,:),train_data(2,:),train_data(3,:));