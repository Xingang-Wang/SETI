clc; clear;
load data_lorenz_asy_W_a_0.7.mat

eig_rho_set = 0:0.1:1.5;
N_rho = length(eig_rho_set);

lambda_max = 0.9056;

for j = 1:N_rho
    time(j) = Predict_time(j);
    std_train = cell2mat(std_train_set(j));
    train_les = cell2mat(train_LEs_set(j));
    m = max(0, -train_les);
    SEBI(j) = mean(m .* std_train);
end

Lambda = time * lambda_max;

% Normalized versions
Lambda_norm = (Lambda - min(Lambda)) / (max(Lambda) - min(Lambda));
SEBI_norm  = (SEBI - min(SEBI)) / (max(SEBI) - min(SEBI));

x = eig_rho_set;
xl = [x(1) - 0.08, x(end) + 0.08];

%% ---- Fig 1: Dual y-axis, NOT normalized ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
yyaxis left;
plot(x, Lambda, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YColor', [0 0.4470 0.7410]);
ylabel('$\Lambda$', 'Interpreter', 'latex', 'FontSize', 18);
pad_L = 0.12 * (max(Lambda) - min(Lambda));
ylim([min(Lambda) - 0.05*pad_L, max(Lambda) + pad_L]);

yyaxis right;
plot(x, SEBI, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
set(gca, 'YColor', [0.8500 0.3250 0.0980]);
ylabel('SEBI', 'FontSize', 18);
pad_S = 0.12 * (max(SEBI) - min(SEBI));
ylim([min(SEBI) - 0.05*pad_S, max(SEBI) + pad_S]);

xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
print('asy_lorenz_fig1_dual_raw', '-depsc', '-painters');

%% ---- Fig 2: Dual y-axis, BOTH normalized ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
yyaxis left;
plot(x, Lambda_norm, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YColor', [0 0.4470 0.7410]);
ylabel('$\Lambda$', 'Interpreter', 'latex', 'FontSize', 18);
ylim([-0.05, 1.12]);

yyaxis right;
plot(x, SEBI_norm, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
set(gca, 'YColor', [0.8500 0.3250 0.0980]);
ylabel('SEBI', 'FontSize', 18);
ylim([-0.05, 1.12]);

xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
print('asy_lorenz_fig2_dual_norm', '-depsc', '-painters');

%% ---- Fig 3: Prediction time (Lambda) alone ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
plot(x, Lambda, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 6, 'MarkerFaceColor', [0 0.4470 0.7410]);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\Lambda$', 'Interpreter', 'latex', 'FontSize', 18);
xlim(xl);
pad = 0.12 * (max(Lambda) - min(Lambda));
ylim([min(Lambda) - 0.3*pad, max(Lambda) + pad]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_lorenz_fig3_lambda', '-depsc', '-painters');

%% ---- Fig 4: SEBI alone ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
plot(x, SEBI, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 6, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('SEBI', 'FontSize', 18);
xlim(xl);
pad = 0.12 * (max(SEBI) - min(SEBI));
ylim([min(SEBI) - 0.3*pad, max(SEBI) + pad]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_lorenz_fig4_sebi', '-depsc', '-painters');
