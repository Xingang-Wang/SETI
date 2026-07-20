function [B, rho_matrix] = get_functional_network_time_avg(reservoir_states)
% 计算功能网络的MATLAB函数（时间平均版本）
% 输入参数:
%   reservoir_states: 2D数组 (time_steps × N_units)，单一初始条件下的储备池状态记录
%   time_range: 用于计算平均值的时间范围，例如 [T_start, T_end]
%   rho_c: 相关性阈值
% 输出参数:
%   B: 二进制相关矩阵 (邻接矩阵)
%   rho_matrix: 完整的相关系数矩阵
%   functional_network: 功能网络图对象

% 获取储备池单元数量和时间步数
[N_time, N_units] = size(reservoir_states);

rho_c = 0.98;
% 提取时间范围
T_start = N_time -500;
T_end = N_time;
if T_end > N_time
    T_end = N_time;
    warning('T_end超出了数据范围，已自动调整为最大值: %d', T_end);
end

time_points = T_start:T_end;
L = length(time_points); % 时间点数量

fprintf('使用时间范围 %d-%d (%d个时间点)进行计算...\n', T_start, T_end, L);

% 初始化相关系数矩阵
rho_matrix = zeros(N_units, N_units);

% 计算所有单元对之间的相关系数（时间平均）
fprintf('计算单元间相关系数（时间平均）...\n');
for i = 1:N_units
    for j = (i+1):N_units  % 只计算上三角部分，矩阵是对称的
        cos_values = zeros(L, 1);
        
        % 对时间范围内的每个时间点计算cos[ri(t) - rj(t)]
        for t_idx = 1:L
            t = time_points(t_idx);
            ri_t = reservoir_states(t, i);
            rj_t = reservoir_states(t, j);
            cos_values(t_idx) = cos(ri_t - rj_t);
        end
        
        % 计算时间平均值
        rho_ij = mean(cos_values);
        rho_matrix(i, j) = rho_ij;
        rho_matrix(j, i) = rho_ij;  % 对称矩阵
    end
    
    % 对角线元素设为1 (单元与自身的完全相关)
    rho_matrix(i, i) = 1;
    
    % 显示进度
    if mod(i, 10) == 0
        fprintf('已完成 %d/%d 个单元...\n', i, N_units);
    end
end

% 创建二进制相关矩阵 B
fprintf('创建二进制相关矩阵...\n');
B = zeros(N_units, N_units);
B(rho_matrix > rho_c) = 1;

% 将对角线设为0 (通常不考虑自连接)
for i = 1:N_units
    B(i, i) = 0;
end