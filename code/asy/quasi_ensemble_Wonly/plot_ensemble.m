% asy quasi W-only ensemble: Prediction time & SEBI vs spectral radius
clc; clear;
load data_quasi_Wonly_ensemble.mat

N_ens = size(Predict_time, 2);
x = eig_rho_set;
xl = [x(1) - 0.1, x(end) + 0.1];

% Use epsilon index 1 (0.05)
eps_idx = 1;

% Compute SEBI for each ensemble member at each rho
for k = 1:N_ens
    for j = 1:length(x)
        std_train = cell2mat(std_train_set(j, k, eps_idx));
        train_les = cell2mat(train_LEs_set(j, k, eps_idx));
        m = max(0, -train_les);
        SEBI(j, k) = mean(m .* std_train);
    end
end

time_mean = Predict_time_mean(:, eps_idx);

%% Colors for ensemble members
colors = lines(N_ens);

%% ---- Fig 1: Prediction time, all members + mean ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 10 7]);
hold on;
for k = 1:N_ens
    plot(x, Predict_time(:, k, eps_idx), '-o', 'Color', colors(k,:), ...
        'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', colors(k,:));
end
plot(x, time_mean, '-k', 'LineWidth', 2.5);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$T$', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_quasi_ensemble_predict_time', '-depsc', '-painters');

%% ---- Fig 2: SEBI, all members + mean ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 10 7]);
hold on;
for k = 1:N_ens
    plot(x, SEBI(:, k), '-s', 'Color', colors(k,:), ...
        'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', colors(k,:));
end
SEBI_mean = mean(SEBI, 2);
plot(x, SEBI_mean, '-k', 'LineWidth', 2.5);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('SEBI', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_quasi_ensemble_sebi', '-depsc', '-painters');

%% ---- Fig 3: Dual y-axis, mean T and mean SEBI ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
yyaxis left;
plot(x, time_mean, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YColor', [0 0.4470 0.7410]);
ylabel('$T$', 'FontSize', 18);

yyaxis right;
plot(x, SEBI_mean, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
set(gca, 'YColor', [0.8500 0.3250 0.0980]);
ylabel('SEBI', 'FontSize', 18);

xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
print('asy_quasi_ensemble_dual', '-depsc', '-painters');

%% ---- Fig 4: Dual y-axis, both normalized ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
T_norm = (time_mean - min(time_mean)) / (max(time_mean) - min(time_mean));
S_norm = (SEBI_mean - min(SEBI_mean)) / (max(SEBI_mean) - min(SEBI_mean));

yyaxis left;
plot(x, T_norm, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YColor', [0 0.4470 0.7410]);
ylabel('$T$', 'FontSize', 18);
ylim([-0.05, 1.12]);

yyaxis right;
plot(x, S_norm, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
set(gca, 'YColor', [0.8500 0.3250 0.0980]);
ylabel('SEBI', 'FontSize', 18);
ylim([-0.05, 1.12]);

xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
print('asy_quasi_ensemble_dual_norm', '-depsc', '-painters');
