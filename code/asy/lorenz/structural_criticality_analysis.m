
    % 结构临界态分析：基于相关矩阵特征值分布
    % 适用于tanh激活函数的连续动力学储备池
    
    clear; close all; clc;
    
    %% 参数设置
    rho_values = 0.0:0.5:3;  % 谱半径扫描范围
   % num_neurons = 100;         % 储备池神经元数量
    T_transient = 1000;        % 瞬态剔除时间
   % T_measure = 5000;          % 测量时间
    
    % 存储结果
    results = struct();
    results.rho = rho_values;
    results.eigenvalue_std = zeros(size(rho_values));
    results.participation_ratio = zeros(size(rho_values));
    results.spectral_entropy = zeros(size(rho_values));
    
    %% 主循环：扫描不同谱半径
    for rho_idx = 1:length(rho_values)
        rho = rho_values(rho_idx);
        fprintf('分析谱半径 ρ = %.2f\n', rho);
        
        % 1. 生成或加载储备池状态数据
        % 假设您已经有状态数据，这里用示例数据代替
        states = func_generate_reservoir_states(rho, T_transient);
        
        % 2. 相关矩阵特征值分析
        [eig_std, pr, entropy] = analyze_correlation_matrix(states);
        
        % 存储结果
        results.eigenvalue_std(rho_idx) = eig_std;
        results.participation_ratio(rho_idx) = pr;
        results.spectral_entropy(rho_idx) = entropy;
    end
    
    %% 结果可视化
    plot_structural_criticality(results);
    
    %% 临界态判定
    identify_critical_point(results);




function [eigenvalue_std, participation_ratio, spectral_entropy] = analyze_correlation_matrix(states)
    % 分析相关矩阵的特征值分布
    
    [N, T] = size(states);
    
    % 1. 计算相关矩阵
    C = corr(states');
    
    % 确保矩阵对称（数值精度问题）
    C = (C + C') / 2;
    
    % 2. 计算特征值
    eigenvalues = eig(C);
    eigenvalues = sort(eigenvalues, 'descend');
    
    % 3. 去除零或负的特征值（数值误差）
    eigenvalues = eigenvalues(eigenvalues > 1e-10);
    
    % 4. 计算各种临界性指标
    
    % 指标1: 特征值的标准差（归一化）
    eigenvalue_std = std(eigenvalues) / mean(eigenvalues);
    
    % 指标2: 参与率 (Participation Ratio)
    % 反映特征值分布的集中程度，临界态下PR较大
    participation_ratio = (sum(eigenvalues))^2 / sum(eigenvalues.^2);
    
    % 指标3: 谱熵 (Spectral Entropy)
    % 临界态下熵最大（分布最平坦）
    p = eigenvalues / sum(eigenvalues);  % 概率分布
    spectral_entropy = -sum(p .* log(p + eps));  % 加eps避免log(0)
    spectral_entropy = spectral_entropy / log(length(eigenvalues));  % 归一化到[0,1]
    
    fprintf('  特征值变异系数: %.4f\n', eigenvalue_std);
    fprintf('  参与率: %.4f\n', participation_ratio);
    fprintf('  谱熵: %.4f\n', spectral_entropy);
end

function plot_structural_criticality(results)
    % 绘制结构临界性分析结果
    
    figure('Position', [100, 100, 1200, 800]);
    
    % 子图1: 特征值变异系数
    subplot(2, 2, 1);
    plot(results.rho, results.eigenvalue_std, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('谱半径 ρ');
    ylabel('特征值变异系数');
    title('(a) 特征值分布宽度');
    grid on;
    
    % 子图2: 参与率
    subplot(2, 2, 2);
    plot(results.rho, results.participation_ratio, 'r-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('谱半径 ρ');
    ylabel('参与率');
    title('(b) 参与率（越大越临界）');
    grid on;
    
    % 子图3: 谱熵
    subplot(2, 2, 3);
    plot(results.rho, results.spectral_entropy, 'g-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('谱半径 ρ');
    ylabel('归一化谱熵');
    title('(c) 谱熵（越大越临界）');
    grid on;
    
    % 子图4: 综合指标
    subplot(2, 2, 4);
    % 综合指标：参与率和谱熵的乘积（两者都应在临界态最大）
    composite_index = results.participation_ratio .* results.spectral_entropy;
    plot(results.rho, composite_index, 'm-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('谱半径 ρ');
    ylabel('综合临界性指标');
    title('(d) 综合临界性指标');
    grid on;
    
    sgtitle('储备池结构临界性分析');
end

function identify_critical_point(results)
    % 识别结构临界点
    
    % 计算综合指标
    composite_index = results.participation_ratio .* results.spectral_entropy;
    
    % 找到最大值对应的ρ
    [max_value, max_idx] = max(composite_index);
    critical_rho = results.rho(max_idx);
    
    fprintf('\n=== 结构临界态分析结果 ===\n');
    fprintf('综合临界性指标最大值: %.4f\n', max_value);
    fprintf('对应的谱半径 ρ_critical = %.2f\n', critical_rho);
    fprintf('此时的特征值变异系数: %.4f\n', results.eigenvalue_std(max_idx));
    fprintf('此时的参与率: %.4f\n', results.participation_ratio(max_idx));
    fprintf('此时的谱熵: %.4f\n', results.spectral_entropy(max_idx));
    
    % 判断临界性
    if results.participation_ratio(max_idx) > 0.3 && results.spectral_entropy(max_idx) > 0.8
        fprintf('结论: 系统在 ρ = %.2f 附近表现出明显的结构临界特性\n', critical_rho);
    else
        fprintf('结论: 系统未观察到明显的结构临界特性\n');
    end
end