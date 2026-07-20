% asy quasi W-only ensemble: 5 NEW members (members 6-10)
clc; clear;

N_ensemble = 5;
base_seed = 52;   % new seeds: 53-57
win_seed = 100;

eig_rho_set = 0:0.2:3;
N_rho = length(eig_rho_set);

Predict_time = zeros(N_rho, N_ensemble);
std_train_set = cell(N_rho, N_ensemble);
train_LEs_set = cell(N_rho, N_ensemble);
train_LEs_transient_set = cell(N_rho, N_ensemble);

for i = 1:N_rho
    eig_rho = eig_rho_set(i);
    for k = 1:N_ensemble
        seed = base_seed + k;
        fprintf('rho=%.1f, ensemble %d/%d (seed=%d)\n', eig_rho, k, N_ensemble, seed);

        T_ex = func_dynamic_test_error_Wonly(eig_rho, seed, win_seed);
        Predict_time(i, k) = T_ex;

        [std_train, train_LEs, train_LEs_transient] = func_LES_test_Wonly(eig_rho, seed, win_seed);
        std_train_set{i, k} = std_train;
        train_LEs_set{i, k} = train_LEs(end, :);
        train_LEs_transient_set{i, k} = train_LEs_transient;
    end
    fprintf('rho=%.1f done. Mean T_ex=%.2f\n', eig_rho, mean(Predict_time(i, :)));
end

Predict_time_mean = mean(Predict_time, 2);

save data_quasi_Wonly_ensemble_new.mat eig_rho_set Predict_time Predict_time_mean ...
    std_train_set train_LEs_set train_LEs_transient_set ...
    base_seed N_ensemble win_seed

fprintf('New ensemble (members 6-10) done.\n');
