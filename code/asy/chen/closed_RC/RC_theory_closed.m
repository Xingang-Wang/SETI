% asy/chen closed-loop RC: max LE vs spectral radius
clear; clc;
load opt_data_chen_testnum_10.mat
load min_rng_set_chen_testnum_10.mat
%%

result = getfield(opt_trials, 'Fval');
param = getfield(opt_trials, 'X');
[sort_result, result_num] = sort(result);
sort_param = param(result_num, :);
opt_result = sort_param(1, :);
sort_rng = min_rng_set(result_num);
opt_rng = sort_rng(1);
rng(opt_rng);

% 参数设置
resSize = 500;
inSize = 3;
outSize = 3;
W_in_a = opt_result(2);
a = 0.7;
reg = opt_result(4);
density = opt_result(5);

initLen = 100;
trainLen = sum(data_len) - 1;
indata = train_data;

Win = (2.0*rand(resSize, inSize) - 1.0) * W_in_a;

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
closedLen = 5000;

maxLE_set = cell(n_rho, 1);
reservoir_data = cell(n_rho, 1);

for rho_idx = 1:n_rho
    eig_rho = eig_rho_range(rho_idx);
    fprintf('asy/chen closed: rho = %.1f (%d/%d)\n', eig_rho, rho_idx, n_rho);

    % Asymmetric scaling
    rhoW = max(abs(eig(full(WW))));
    W    = WW * (eig_rho / rhoW);

    %% Training
    x = zeros(resSize, 1);
    X = zeros(resSize, trainLen);
    Yt = indata(1:outSize, 2:trainLen+1);
    for t = 1:trainLen
        u = indata(:, t);
        x = (1-a)*x + a*tanh(Win*u + W*x);
        X(:, t) = x;
    end
    X(:, 1:initLen) = [];
    Yt(:, 1:initLen) = [];
    Wout = Yt * X' / (X * X' + reg * eye(resSize));

    %% Closed-loop evolution
    x = rand(resSize, 1) * 0.1;
    reservoir_history = zeros(resSize, closedLen);
    for t = 1:closedLen
        y = Wout * x;
        x = (1-a)*x + a*tanh(Win*y + W*x);
        reservoir_history(:, t) = x;
    end

    lambda_max = func_compute_max_LE_closed(Win, Wout, W, a, reservoir_history, closedLen);
    maxLE_set{rho_idx} = lambda_max;
    reservoir_data{rho_idx} = reservoir_history;
    fprintf('  max LE: %.4f\n', lambda_max);
end
save RC_data_closed_asy_chen.mat reservoir_data maxLE_set eig_rho_range
