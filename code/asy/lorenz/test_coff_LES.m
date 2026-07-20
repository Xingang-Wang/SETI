clc;clear;

load data_lorenz_transient.mat 
eig_rho_set =0:0.1:2;
mean_std_train = zeros(1,length(eig_rho_set));
mean_std_test = zeros(1,length(eig_rho_set));
for j=1:length(eig_rho_set) 
   %  figure
   %  plot(train_LEs_transient_set{j})
    result=cell2mat(train_LEs_transient_set(j));
     corr = zeros(500-1, 2); % [序列对编号, 相关系数, p值]
    
     for i = 1:500-1
        ts1 = result(:, i);
        ts2 = result(:, i+1);
        temp =  corrcoef(ts1, ts2, 'Rows', 'complete');
         corr(i, :) = [i, temp(1,2)];
     end
     
     covariance_matrix = cov(result) ;  % 除以T以匹配文章定义
    
    % 2. 提取非对角元素（神经元对之间的协方差）
    off_diagonal_mask = ~eye(500);
    cross_covariances = covariance_matrix(off_diagonal_mask);
    
    % 3. 提取对角元素（方差）
    variances = diag(covariance_matrix);
    
    % 4. 计算相关性分布的关键统计量
    stats = struct();
    
    % 平均值（关键指标：衡量总体相关性水平）
    stats.mean_covariance = mean(cross_covariances);
    
    % 标准差（关键指标：衡量相关性分布的宽度）
    stats.std_covariance = std(cross_covariances)

    width(j) = stats.std_covariance;
    
    % 归一化宽度 Δ（文章中的关键参数）
    stats.normalized_width = stats.std_covariance / mean(variances);
    normalized_widthnormalized_widthnormalized_width
    % figure
    %  histogram(cross_covariances, 50, 'Normalization', 'probability', ...
    %           'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'black');
      
    result_les = cell2mat(train_LEs_set(j));
    mean_std_train (j) = mean(std_train_set{j});
    mean_std_test (j) = mean(std_test_set{j});
    mean_train(j) = mean(train_LEs_set{j});
end