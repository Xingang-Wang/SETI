clc;clear;
testnum = 10;
%function [train_data,testdata,data_num,data_len]= func_dataset_loz_noise(testnum)
data_num=1;
data_len=ones(1,data_num)*5000;
%testnum=1;
mod_num=20;
transient=40002;
rng(1);

%% 参数设置
measurement_noise_level = 0.0; % 测量噪音水平，可根据需要调整

%% 生成Lorenz数据（无噪音的基础数据）
disp('生成Lorenz数据...');
F=@(t,Y)[10*Y(2)-10*Y(1);...
         -Y(1).*Y(3)+28*Y(1)-Y(2);...
         Y(1).*Y(2)-8*Y(3)/3;...
         ];
         
opt = odeset('RelTol', 10.0^(-7), 'AbsTol', 10.0^(-7));     
y0=rand(3,1);
[t,Y] = ode45(F, [0:0.001:2000], y0, opt);
data_lorenz_clean = Y(transient:end,:);

%% 计算统一的归一化参数（使用无噪音数据）
max_loz_unified = zeros(3,1);
min_loz_unified = zeros(3,1);
for i = 1:3
    max_loz_unified(i) = max(data_lorenz_clean(:,i));
    min_loz_unified(i) = min(data_lorenz_clean(:,i));
end

fprintf('统一归一化参数:\n');
for i = 1:3
    fprintf('维度 %d: min=%.4f, max=%.4f\n', i, min_loz_unified(i), max_loz_unified(i));
end

%% 归一化无噪音数据（用于testdata）
normalized_loz_clean = data_lorenz_clean';

% 归一化无噪音数据
data_loz_clean = [];
for i = 1:3
    normalized_loz_clean(i,:) = (data_lorenz_clean(:,i)' - min_loz_unified(i)) / (max_loz_unified(i)-min_loz_unified(i));
    xf1 = normalized_loz_clean(i,:);
    x_pos = 1:size(xf1,2);
    xf1 = xf1(mod(x_pos,mod_num)==0);
    data_loz_clean = [data_loz_clean; xf1];
end

%% 添加测量噪音到归一化前的数据（用于train_data）
disp('添加测量噪音...');
rng(2); % 设置不同的随机种子，确保噪音的随机性

% 在归一化前添加测量噪音
data_lorenz_noisy = data_lorenz_clean + measurement_noise_level * randn(size(data_lorenz_clean));

%% 归一化带测量噪音的数据（使用相同的归一化参数）
normalized_loz_noisy = data_lorenz_noisy';

% 归一化带噪音数据
data_loz_noisy = [];
for i = 1:3
    normalized_loz_noisy(i,:) = (data_lorenz_noisy(:,i)' - min_loz_unified(i)) / (max_loz_unified(i)-min_loz_unified(i));
    xf1 = normalized_loz_noisy(i,:);
    x_pos = 1:size(xf1,2);
    xf1 = xf1(mod(x_pos,mod_num)==0);
    data_loz_noisy = [data_loz_noisy; xf1];
end

%% 分配数据
% train_data: 带测量噪音的数据
train_data = data_loz_noisy(:,1:data_len);

% testdata: 无噪音的数据
testdata = zeros(3*testnum,1001);
for i = 0:testnum-1
    testdata(3*i+1:3*i+3,:) = data_loz_clean(:,data_len+1+i*1000:data_len+1+(i+1)*1000);
end
save lorenz_noise_0.mat train_data testdata