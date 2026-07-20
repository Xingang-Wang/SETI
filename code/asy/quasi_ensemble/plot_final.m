clc;clear;
clc;clear;
% load data_in_quasi_transient.mat
% load data_in_quasi_transient_Win_1.mat
% load  data_in_quasi_transient_a_0.3.mat
% load data_in_quasi_dt_5_a_0_7.mat
%load data_in_quasi_dt_5_a.mat 
%load data_in_quasi_dt_5_a_rho_0_4.mat
%load data_in_quasi_dt_5_a_0_7_rho_5.mat
%load data_in_quasi_dt_5_a_0_3_rho_5.mat
%load data_in_quasi_same_hye.mat
%load data_in_quasi_same_hye_testnum_30.mat
load data_in_quasi_testnum_50.mat
eig_rho_set =0:0.1:3;
mean_std_train = zeros(1,length(eig_rho_set));
mean_std_test = zeros(1,length(eig_rho_set));
for j=1:1:length(eig_rho_set) 
   time(j) = Predict_time(j);
   Error(j) = error(j);
   mean_std_train (j) = mean(std_train_set{j});
end
y1 = Predict_time;
y2 = mean_std_train;
x = eig_rho_set;
figure
% 左侧y轴
yyaxis left;
plot(x, y1, 'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 ...
   );
ylabel('$error$', 'Interpreter', 'latex');
ylabel('$sigma$', 'Interpreter', 'latex');
%ylim([-1.5 1.5]);    % 设置左侧y轴范围
 

% 右侧y轴
yyaxis right;
plot(x, y2, 'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 ...
    );
ylabel('$error$', 'Interpreter', 'latex');
%ylim([0 200]);       % 设置右侧y轴范围

% 公共设置
xlabel('$ \rho$', 'interpreter', 'latex');
%ylabel('$sigma$', 'Interpreter', 'latex');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
