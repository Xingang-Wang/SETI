 % 设置默认阈值系数
 function [std_test]= func_plot_test(test_LEs_transient,test_LEs)
    multiplier = 1.5;
    
    % 步骤1: 计算每个方向的标准差
    %std_devs = std(train_LEs_transient, 0, 1);  % 沿时间维度计算标准差
   std_devs = std(test_LEs_transient, 0, 1);  % 沿时间维度计算标准差
    % 步骤2: 计算标准差的中位数
    median_std = median(std_devs);
    
    % 步骤3: 设定波动阈值
    fluctuation_threshold = multiplier * median_std;
    %fluctuation_threshold = 0.0894;
    % 步骤4: 统计波动大的方向数目
    is_fluctuating = std_devs > fluctuation_threshold;
    num_fluctuating = sum(is_fluctuating);
    
    % 可选: 可视化结果
    figure;
    plot(std_devs, 'o-', 'LineWidth', 1);
    hold on;
    yline(fluctuation_threshold, 'r--', 'LineWidth', 2, 'Label', 'Threshold');
    title('各方向FTLE标准差');
    xlabel('方向索引');
    ylabel('标准差');
    grid on;
    ylim([ 0 1.1])
    std_test = std_devs;
    %%
%data = train_LEs(end,:);
data = test_LEs(end,:);
x = 1:length(data);

% 创建图形
figure;
hold on;

% 填充正数区域（浅绿色）
pos_idx = data >= 0;
fill([x(pos_idx), fliplr(x(pos_idx))], [data(pos_idx), zeros(1, sum(pos_idx))], ...
    [0.85, 1.0, 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

% 填充负数区域（浅粉色）
neg_idx = data < 0;
fill([x(neg_idx), fliplr(x(neg_idx))], [data(neg_idx), zeros(1, sum(neg_idx))], ...
    [1.0, 0.85, 0.90], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

% 绘制数据点（蓝色圆点）
plot(x, data, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b');

% 绘制数据线（蓝色实线）
plot(x, data, 'b-', 'LineWidth', 1.5);

% 绘制零基准线（黑色虚线）
plot([x(1), x(end)], [0, 0], 'k--', 'LineWidth', 1.2);

% 添加标签和标题
xlabel('数据点索引');
ylabel('数据值');
title('一维数据分布图（以0为界限）');
grid on;
box on;

% 添加图例
legend('正数区域', '负数区域', '数据点', '零基准线', 'Location', 'best');

% 设置坐标轴范围
xlim([1, length(data)]);
y_range = max(abs(data)) * 1.2;
ylim([-10, 1]);

% 美化图形
set(gca, 'FontSize', 12, 'FontWeight', 'bold');
set(gcf, 'Color', 'w'); % 白色背景