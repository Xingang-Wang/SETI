function [a_fit,b_fit] = func_LES_fit(std_train)

% 假设你已经有了x和y的数据
x = 1:500;  % 这是一个示例数据，您应替换为实际数据
y = std_train; % 在这里填入y的数据，可以是您图像对应的数据

[~, min_idx] = min(y);  % 找到最小值及其索引

% 2. 保留最低点后的数据
x_fit = x(min_idx:end);
y_fit = y(min_idx:end);

figure
plot(y_fit,'.-');

% 3. 对剩余数据进行指数拟合
% 使用fittype创建一个指数拟合模型
ft = fittype('a*exp(b*x) + c', 'independent', 'x', 'dependent', 'y');
% 对数据进行拟合
fit_result = fit(x_fit(:), y_fit(:), ft);

% 输出拟合结果
disp('拟合系数：');
disp(['a = ', num2str(fit_result.a)]);
disp(['b = ', num2str(fit_result.b)]);
disp(['c = ', num2str(fit_result.c)]);

% 可视化拟合结果
figure;
plot(x, y, 'b.', 'MarkerSize', 10); % 原始数据
hold on;
plot(x_fit, feval(fit_result, x_fit), 'r-', 'LineWidth', 2); % 拟合曲线
xlabel('方向索引');
ylabel('标准差');
title('带偏移的指数拟合结果');
legend('原始数据', '拟合曲线');
grid on;