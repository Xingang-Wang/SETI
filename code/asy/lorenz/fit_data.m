clc;clear;

load data_std
% 假设你已经有了x和y的数据
x = 0.01:0.01:5;  % 这是一个示例数据，您应替换为实际数据
y = std_train; % 在这里填入y的数据，可以是您图像对应的数据

[~, min_idx] = min(y);  % 找到最小值及其索引

% 2. 保留最低点后的数据
xdata = x(min_idx:end);
ydata = y(min_idx:end);

figure
plot(ydata,'.-');

model = @(p, x) p(1)*exp(p(2)*x) + p(3);

% 步骤3: 设置初始参数猜测 [a, b, c]
initialGuess = [0.0001, 0.1, 0];  % 根据数据特性调整初始值

% 步骤4: 使用lsqcurvefit进行非线性拟合
options = optimset('Display', 'iter', 'TolFun', 1e-6);  % 显示迭代过程
[params, resnorm, residual, exitflag] = lsqcurvefit(model, initialGuess, xdata, ydata, [], [], options);

% 提取拟合参数
a_fit = params(1);
b_fit = params(2);
c_fit = params(3);

% 步骤5: 计算拟合值并绘图
x_fit = linspace(min(xdata), max(xdata), 100);  % 生成更密的点用于平滑曲线
y_fit = a_fit * exp(b_fit * x_fit) + c_fit;

% 绘制原始数据和拟合曲线
figure;
plot(xdata, ydata, 'bo', 'DisplayName', '原始数据');  % 原始数据点
hold on;
plot(x_fit, y_fit, 'r-', 'DisplayName', '拟合曲线');  % 拟合曲线
xlabel('x');
ylabel('y');
legend('show');
title(sprintf('拟合结果: %.4f * exp(%.4f * x) + %.4f', a_fit, b_fit, c_fit));
grid on;

% 显示拟合参数
fprintf('拟合参数: a = %.4f, b = %.4f, c = %.4f\n', a_fit, b_fit, c_fit);