% asy/quasi autonomous-RC: max LE vs spectral radius
clear; clc;
load opt_data_quasi_dt_5_train_10000.mat
load min_rng_set_quasi_dt_5_train_10000.mat
%%

result = getfield(opt_trials, 'Fval');
param = getfield(opt_trials, 'X');
[sort_result, result_num] = sort(result);
sort_param = param(result_num, :);
opt_result = sort_param(1, :);
sort_rng = min_rng_set(result_num);
opt_rng = sort_rng(1);
rng(opt_rng);

resSize = 500;
inSize = 3;
W_in_a = opt_result(2);
a = 0.7;
reg = opt_result(4);
density = opt_result(5);

TrainLen = 5000;

Win = (2.0 * rand(resSize, inSize) - 1.0) * W_in_a;

% Asymmetric W (asy)
WW = zeros(resSize, resSize);
for i = 1:resSize
    for j = 1:resSize
        if rand() < density
            WW(i, j) = 2*rand() - 1;
        end
    end
end

eig_rho_range = 0:0.1:3.0;
n_rho = length(eig_rho_range);

maxLE_set = cell(n_rho, 1);
reservoir_data = cell(n_rho, 1);

for rho_idx = 1:n_rho
    eig_rho = eig_rho_range(rho_idx);
    fprintf('asy/quasi auto: rho = %.1f (%d/%d)\n', eig_rho, rho_idx, n_rho);

    rhoW = max(abs(eig(full(WW))));
    W = WW * (eig_rho / rhoW);

    x = rand(resSize, 1);
    reservoir_history = zeros(resSize, TrainLen);
    for t = 1:TrainLen
        x = (1 - a) * x + a * tanh(W * x);
        reservoir_history(:, t) = x;
    end

    lambda_max = func_compute_max_lyapunov_exponent(W, a, reservoir_history, TrainLen);
    maxLE_set{rho_idx} = lambda_max;
    reservoir_data{rho_idx} = reservoir_history;
    fprintf('  max LE: %.4f\n', lambda_max);
end
save RC_data_auto_asy_quasi.mat reservoir_data maxLE_set eig_rho_range
