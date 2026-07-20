% asy quasi W-only ensemble: merge 10 members, filter, and plot
clc; clear;

%% Load old (members 1-5) and new (members 6-10)
eps_idx = 1;
load data_quasi_Wonly_ensemble.mat
old_Predict_time = Predict_time(:, :, eps_idx);
old_std_train_set = std_train_set(:, :);
old_train_LEs_set = train_LEs_set(:, :);

load data_quasi_Wonly_ensemble_new.mat
new_Predict_time = Predict_time;
new_std_train_set = std_train_set;
new_train_LEs_set = train_LEs_set;

%% Merge into 10 members
Predict_time = [old_Predict_time, new_Predict_time];          % N_rho x 10
std_train_set = [old_std_train_set, new_std_train_set];       % N_rho x 10 cell
train_LEs_set = [old_train_LEs_set, new_train_LEs_set];      % N_rho x 10 cell
N_ens = size(Predict_time, 2);
x = eig_rho_set;

%% Filter: select top-N members by min(T) in rho=[1.2, 1.6]
rho_idx = find(x >= 1.2 & x <= 1.6);
N_keep = 3;
min_T_vals = zeros(1, N_ens);
for k = 1:N_ens
    min_T_vals(k) = min(Predict_time(rho_idx, k));
end
[sorted_min, sort_idx] = sort(min_T_vals, 'descend');
keep_idx = sort(sort_idx(1:N_keep));

fprintf('Top %d members by min(T) in [1.2, 1.6]: ', N_keep);
fprintf('%d ', keep_idx);
fprintf('\n');

Predict_time_filt = Predict_time(:, keep_idx);
std_train_filt = std_train_set(:, keep_idx);
train_LEs_filt = train_LEs_set(:, keep_idx);

%% Compute SEBI for kept members
N_kept = N_keep;
eps_idx = 1;
SEBI = zeros(length(x), N_kept);
for kk = 1:N_kept
    for j = 1:length(x)
        std_train = cell2mat(std_train_filt(j, kk));
        train_les = cell2mat(train_LEs_filt(j, kk));
        m = max(0, -train_les);
        SEBI(j, kk) = mean(m .* std_train);
    end
end

time_filt_mean = mean(Predict_time_filt, 2);
SEBI_mean = mean(SEBI, 2);

%% Save merged + filtered data
save data_quasi_Wonly_ensemble_merged.mat eig_rho_set Predict_time ...
    std_train_set train_LEs_set keep_idx N_keep ...
    Predict_time_filt SEBI time_filt_mean SEBI_mean

%% ---- Fig 1: Prediction time, filtered members + mean ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 10 7]);
hold on;
colors = lines(N_kept);
for kk = 1:N_kept
    plot(x, Predict_time_filt(:, kk), '-o', 'Color', colors(kk,:), ...
        'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', colors(kk,:));
end
plot(x, time_filt_mean, '-k', 'LineWidth', 2.5);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$T$', 'FontSize', 18);
xl = [x(1) - 0.1, x(end) + 0.1];
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_quasi_ensemble_merged_predict_time', '-depsc', '-painters');

%% ---- Fig 2: SEBI, filtered members + mean ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 10 7]);
hold on;
for kk = 1:N_kept
    plot(x, SEBI(:, kk), '-s', 'Color', colors(kk,:), ...
        'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', colors(kk,:));
end
plot(x, SEBI_mean, '-k', 'LineWidth', 2.5);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('SEBI', 'FontSize', 18);
xlim(xl);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_quasi_ensemble_merged_sebi', '-depsc', '-painters');

%% ---- Fig 3: Dual y-axis, mean T/4 and mean SEBI ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
yyaxis left;
plot(x, time_filt_mean / 4, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YColor', [0 0.4470 0.7410]);
ylabel('$T$', 'Interpreter', 'latex', 'FontSize', 18);
ylim_min_left = min(time_filt_mean/4) * 0.8;
ylim_max_left = max(time_filt_mean/4) * 1.05;
ylim([ylim_min_left, ylim_max_left]);

yyaxis right;
plot(x, SEBI_mean, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
set(gca, 'YColor', [0.8500 0.3250 0.0980]);
ylabel('SEBI', 'FontSize', 18);
ylim_min_right = min(SEBI_mean) * 0.8;
ylim_max_right = max(SEBI_mean) * 1.05;
ylim([ylim_min_right, ylim_max_right]);

xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
xlim([-0.3, x(end) + 0.3]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;
print('asy_quasi_ensemble_merged_dual', '-depsc', '-painters');

%% ---- Fig 4: Dual y-axis, both normalized ----
figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
T_norm = (time_filt_mean - min(time_filt_mean)) / (max(time_filt_mean) - min(time_filt_mean));
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
print('asy_quasi_ensemble_merged_dual_norm', '-depsc', '-painters');

fprintf('Merged + filtered plots done.\n');
