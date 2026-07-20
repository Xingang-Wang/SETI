
clc;clear;

load data_std_rho_05.mat std_test std_train
% 假设你已经有了x和y的数据
x = 0.01:0.01:5;  % 这是一个示例数据，您应替换为实际数据
y = std_test; % 在这里填入y的数据，可以是您图像对应的数据

[~, min_idx] = min(y);  % 找到最小值及其索引

% 2. 保留最低点后的数据
xdata = x(min_idx:end);
ydata = y(min_idx:end);

figure
plot(ydata,'.-');
% 步骤2: 定义指数模型函数
model = @(p, x) p(1)*exp(p(2)*x) + p(3);

% 步骤3: 设置初始参数猜测 [a, b, c]
initialGuess = [0.001, 3, 0.0001];  % 根据数据特性调整初始值

% 步骤4: 使用lsqcurvefit进行非线性拟合
options = optimset('Display', 'iter', 'TolFun', 1e-6);  % 显示迭代过程
[params, resnorm, residual, exitflag, output, lambda, jacobian] = lsqcurvefit(...
    model, initialGuess, xdata, ydata, [], [], options);

% 提取拟合参数
a_fit = params(1);
b_fit = params(2);
c_fit = params(3);

% 步骤5: 计算拟合值
y_pred = model(params, xdata);  % 在原始数据点处的预测值

% 步骤6: 计算各种误差指标
% 残差 (实际值 - 预测值)
residuals = ydata - y_pred;

% 均方根误差 (RMSE)
rmse = sqrt(mean(residuals.^2));

% 平均绝对误差 (MAE)
mae = mean(abs(residuals));

% 决定系数 (R²)
ss_res = sum(residuals.^2);
ss_tot = sum((ydata - mean(ydata)).^2);
r_squared = 1 - (ss_res / ss_tot);

% 调整后的决定系数 (Adjusted R²)
n = length(ydata);  % 样本数量
k = 3;  % 参数数量 (a, b, c)
adj_r_squared = 1 - (1 - r_squared) * (n - 1) / (n - k - 1);

% 计算参数的标准误差和置信区间
% 使用雅可比矩阵计算协方差矩阵
covariance = resnorm/(n-k) * inv(jacobian'*jacobian);
std_errors = sqrt(diag(covariance));  % 参数的标准误差

% 计算95%置信区间 (t分布)
t_value = tinv(0.975, n-k);  % 95%置信水平下的t值
ci = [params' - t_value*std_errors, params' + t_value*std_errors];

% 步骤7: 绘制结果
figure;

% 子图1: 拟合曲线和原始数据
subplot(2, 2, 1);
plot(xdata, ydata, 'bo', 'DisplayName', '原始数据', 'MarkerSize', 8);
hold on;
x_fit = linspace(min(xdata), max(xdata), 100);
y_fit = model(params, x_fit);
plot(x_fit, y_fit, 'r-', 'LineWidth', 2, 'DisplayName', '拟合曲线');
xlabel('x');
ylabel('y');
title(sprintf('拟合结果: %.4f * exp(%.4f * x) + %.4f', a_fit, b_fit, c_fit));
legend('show');
grid on;

% 子图2: 残差图
subplot(2, 2, 2);
plot(xdata, residuals, 'ro', 'MarkerSize', 8);
hold on;
plot([min(xdata), max(xdata)], [0, 0], 'k--');  % 零参考线
xlabel('x');
ylabel('残差');
title('残差分析');
grid on;

% 子图3: 残差直方图
subplot(2, 2, 3);
histogram(residuals, 10);
xlabel('残差值');
ylabel('频数');
title('残差分布');

% 子图4: Q-Q图 (检验残差正态性)
subplot(2, 2, 4);
normplot(residuals);
title('Q-Q图 (正态性检验)');

% % 步骤8: 显示拟合结果和误差指标
% fprintf('\n=== 指数函数拟合结果 ===\n');
% fprintf('拟合方程: y = %.4f * exp(%.4f * x) + %.4f\n', a_fit, b_fit, c_fit);
% fprintf('\n参数估计:\n');
% fprintf('  参数a: %.4f ± %.4f (95%% CI: [%.4f, %.4f])\n', a_fit, std_errors(1), ci(1,1), ci(1,2));
% fprintf('  参数b: %.4f ± %.4f (95%% CI: [%.4f, %.4f])\n', b_fit, std_errors(2), ci(2,1), ci(2,2));
% fprintf('  参数c: %.4f ± %.4f (95%% CI: [%.4f, %.4f])\n', c_fit, std_errors(3), ci(3,1), ci(3,2));
% 
% fprintf('\n拟合优度统计:\n');
% fprintf('  均方根误差 (RMSE): %.4f\n', rmse);
% fprintf('  平均绝对误差 (MAE): %.4f\n', mae);
% fprintf('  残差平方和 (SSE): %.4f\n', resnorm);
% fprintf('  决定系数 (R²): %.4f\n', r_squared);
% fprintf('  调整后决定系数: %.4f\n', adj_r_squared);
% 
% fprintf('\n其他信息:\n');
% fprintf('  迭代次数: %d\n', output.iterations);
% fprintf('  函数评估次数: %d\n', output.funcCount);
% fprintf('  退出标志: %d (1=收敛，其他值请查阅文档)\n', exitflag);