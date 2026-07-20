% function [train_LEs, train_LEs_transient, lorenz_data, time_vals] = func_calculate_lorenz_les(TrainLen, dt_lorenz, initial_conditions)
% 计算Lorenz系统的有限时间李指数
% 输入参数:
%   TrainLen: 时间序列长度
%   dt_lorenz: Lorenz系统积分步长
%   initial_conditions: 初始条件 [x0; y0; z0]
clc;clear;
%%
    initial_conditions = [0.1; 0.4; 1]; % 默认初始条件

    dt_lorenz = 0.02; % 默认积分步长

    TrainLen = 10000; % 默认长度


N = 3;  % Lorenz系统是3维
nLE = N;

% 生成Lorenz系统数据
[lorenz_data, time_vals] = generate_lorenz_data(TrainLen, dt_lorenz, initial_conditions);

%%
% 参数设置
nStepTransient = 1000;  % 初始瞬态步数，让系统进入吸引子
nStep = TrainLen;       % 总步数
nstepONS = 2;          % 正交归一化间隔步数 - 增加以提高稳定性
nONS = ceil((nStep - nStepTransient) / nstepONS); % ONS步数

%%
% 初始化正交系统
[Q, ~] = qr(randn(N, nLE), 0);
diagElmR = 1:(nLE + 1):nLE^2; % R矩阵对角线元素的索引

% Lorenz系统参数
sigma = 10;
rho = 28;
beta = 8/3;

%%
% 初始化变量
cumulative_log_R = zeros(1, nLE); % 累积 log(abs(R))
FTLE_cumulative = [];             % 保存累积FTLE
FTLE_transient = [];              % 存储瞬态FTLE
lsidx = 0;

% 主循环 - 计算李指数
for n = 2:nStep
    % 跳过初始瞬态
    if n > nStepTransient
        % 获取当前Lorenz系统状态
        Y = lorenz_data(:, n);  % 三维状态向量 [x; y; z]
        x = Y(1);
        y = Y(2);
        z = Y(3);
        
        % 计算Lorenz系统的Jacobian矩阵
        J = [-sigma, sigma, 0;
             rho - z, -1, -x;
             y, x, -beta];
        
        % 使用RK4方法演化切空间（更稳定）
        k1 = J * Q;
        k2 = J * (Q + 0.5 * dt_lorenz * k1);
        k3 = J * (Q + 0.5 * dt_lorenz * k2);
        k4 = J * (Q + dt_lorenz * k3);
        
        Q = Q + (dt_lorenz / 6) * (k1 + 2*k2 + 2*k3 + k4);
        
        % 定期进行正交归一化
        if mod(n - nStepTransient, nstepONS) == 0
            [Q, R] = qr(Q, 0);
            
            % 确保Q的唯一性（避免反射）
            for i = 1:size(R,1)
                if R(i,i) < 0
                    Q(:,i) = -Q(:,i);
                    R(i,:) = -R(i,:);
                end
            end
            
            % 计算当前有限时间李指数
            current_FTLE = log(abs(diag(R))) / (nstepONS * dt_lorenz);
            
            % 记录瞬态动力学
            FTLE_transient(end + 1, :) = current_FTLE;
            
            % 更新累积 log(abs(R))
            cumulative_log_R = cumulative_log_R + log(abs(R(diagElmR)));
            
            % 当前累计时间
            current_time = (lsidx + 1) * nstepONS * dt_lorenz;
            
            % 计算累积FTLE
            current_cumulative_FTLE = cumulative_log_R / current_time;
            
            % 保存累积FTLE
            FTLE_cumulative = [FTLE_cumulative; current_cumulative_FTLE];
            
            lsidx = lsidx + 1;
        end
    end
end

train_LEs = FTLE_cumulative;
train_LEs_transient = FTLE_transient;

% 显示最终的李指数值
fprintf('最终李指数值:\n');
fprintf('λ1 = %.6f\n', train_LEs(end, 1));
fprintf('λ2 = %.6f\n', train_LEs(end, 2));
fprintf('λ3 = %.6f\n', train_LEs(end, 3));
fprintf('李指数和 = %.6f (应该接近系统散度 %.6f)\n', ...
        sum(train_LEs(end, :)), -(sigma + 1 + beta));

figure
plot(train_LEs_transient(end-200:end,1),'.-');
hold on;
plot(train_LEs_transient(end-200:end,2),'.-');
hold on;
plot(train_LEs_transient(end-200:end,3),'.-');

figure
plot(lorenz_data(1,end-400:end),'.-');
hold on;
plot(lorenz_data(2,end-400:end),'.-');
hold on;
plot(lorenz_data(3,end-400:end),'.-');

function [lorenz_data, time_vals] = generate_lorenz_data(TrainLen, dt, initial_conditions)
% 生成Lorenz系统数据
% 使用四阶Runge-Kutta方法

% Lorenz系统参数
sigma = 10;
rho = 28;
beta = 8/3;

% 初始化
x = zeros(1, TrainLen);
y = zeros(1, TrainLen);
z = zeros(1, TrainLen);
time_vals = zeros(1, TrainLen);

% 设置初始条件
x(1) = initial_conditions(1);
y(1) = initial_conditions(2);
z(1) = initial_conditions(3);

% Lorenz系统方程
lorenz_eq = @(t, Y) [sigma * (Y(2) - Y(1));
                     Y(1) * (rho - Y(3)) - Y(2);
                     Y(1) * Y(2) - beta * Y(3)];

% 使用RK4方法积分
for i = 1:TrainLen-1
    t = (i-1) * dt;
    Y = [x(i); y(i); z(i)];
    
    k1 = lorenz_eq(t, Y);
    k2 = lorenz_eq(t + 0.5*dt, Y + 0.5*dt*k1);
    k3 = lorenz_eq(t + 0.5*dt, Y + 0.5*dt*k2);
    k4 = lorenz_eq(t + dt, Y + dt*k3);
    
    Y_next = Y + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4);
    
    x(i+1) = Y_next(1);
    y(i+1) = Y_next(2);
    z(i+1) = Y_next(3);
    time_vals(i+1) = t + dt;
end

lorenz_data = [x; y; z];

end