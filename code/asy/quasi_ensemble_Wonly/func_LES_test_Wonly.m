function [std_train, train_LEs, train_LEs_transient] = func_LES_test_Wonly(eig_rho, seed, win_seed)
load opt_data_quasi_dt_5_train_10000.mat
load min_rng_set_quasi_dt_5_train_10000.mat

data_num = 1;
result = getfield(opt_trials,'Fval');
param = getfield(opt_trials,'X');
[sort_result, result_num] = sort(result);
sort_param = param(result_num,:);
opt_result = sort_param(1,:);

drive_num = 200;
nonliner_num = 1;

W_in_a = opt_result(2);
a = 0.7;
reg = opt_result(4);
density = opt_result(5);

resSize = 500;
initLen = 100;
TrainLen = sum(data_len) - 1;
test_Len = 1000;
inSize = 3;
outSize = 3;

%% --- Win: fixed across ensemble ---
rng(win_seed);
Win = (2.0*rand(resSize,inSize)-1.0)*W_in_a;

%% --- W: asymmetric, ensemble-specific ---
rng(seed);
WW = zeros(resSize, resSize);
for i = 1:resSize
    for j = 1:resSize
        if rand() < density
            WW(i, j) = 2*rand() - 1;
        end
    end
end
rhoW = max(abs(eig(full(WW))));
W = WW * (eig_rho / rhoW);

%% --- Training ---
indata = train_data;
X = zeros(resSize, TrainLen);
Yt = indata(1:outSize, 2:TrainLen+1);

reservoir_train_history = zeros(TrainLen, resSize);
x = rand(resSize, 1);
for t = 1:TrainLen
    u = indata(:, t);
    x = (1-a)*x + a*tanh(Win*u + W*x);
    X(:, t) = x;
    reservoir_train_history(t, :) = x;
end

Data_len = [0, data_len];
for i = 0:data_num-1
    trainLen = sum(Data_len(1:i+1));
    X(:, trainLen+1-i*initLen:trainLen+initLen-i*initLen) = [];
    Yt(:, trainLen+1-i*initLen:trainLen+initLen-i*initLen) = [];
end
rank_perm = randperm(size(X, 2));
X = X(:, rank_perm);
Yt = Yt(:, rank_perm);
X_T = X';
Wout = Yt*X_T / (X*X_T + reg*eye(nonliner_num*resSize));

%% --- LE computation ---
reservoir_train_history(1:initLen, :) = [];
indata(:, 1:initLen) = [];
Trainlen_adj = TrainLen - initLen;

[train_LEs, train_LEs_transient] = func_calculate_train_LES(resSize, reservoir_train_history, Trainlen_adj, indata, Win, W, a, Wout);

std_train = std(train_LEs_transient, 0, 1);
