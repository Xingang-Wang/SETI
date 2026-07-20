clc;clear;

N_ensemble = 10;
base_seed = 42;

eig_rho_set = 0:0.1:3;
N_rho = length(eig_rho_set);

Predict_time = zeros(N_rho, N_ensemble);
Predict_time_mean = zeros(1, N_rho);

std_train_set = cell(N_rho, N_ensemble);
train_LEs_set = cell(N_rho, N_ensemble);
train_LEs_transient_set = cell(N_rho, N_ensemble);

for i = 1:N_rho
    eig_rho = eig_rho_set(i);
    for k = 1:N_ensemble
        seed = base_seed + k;
        fprintf('rho=%.1f, ensemble %d/%d\n', eig_rho, k, N_ensemble);

        T_ex = func_dynamic_test_error(eig_rho, seed);
        Predict_time(i, k) = T_ex;

        [std_test, std_train, train_LEs, train_LEs_transient, ~, ~] = func_LES_test(eig_rho, seed);
        std_train_set{i, k} = std_train;
        train_LEs_set{i, k} = train_LEs(end, :);
        train_LEs_transient_set{i, k} = train_LEs_transient;
    end
    Predict_time_mean(i) = mean(Predict_time(i, :));
end

save data_in_quasi_W_asy_ensemble.mat eig_rho_set Predict_time Predict_time_mean ...
    std_train_set train_LEs_set train_LEs_transient_set base_seed N_ensemble

figure;
plot(eig_rho_set, Predict_time, '.-', 'Color', [0.7 0.7 0.7]);
hold on;
plot(eig_rho_set, Predict_time_mean, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('\rho');
ylabel('Prediction time');
legend('Individual', 'Ensemble mean');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
print('scan_rho_ensemble', '-dpng', '-r300');
