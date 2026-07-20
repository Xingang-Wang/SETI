clc;clear;

eig_rho_set =0:0.1:3;
std_train_set = cell(1,length(eig_rho_set));
train_LEs_set = cell(1,length(eig_rho_set));
std_test_set = cell(1,length(eig_rho_set));
test_LEs_set = cell(1,length(eig_rho_set));
Predict_time = zeros(1,length(eig_rho_set));
train_LEs_transient_set =  cell(1,length(eig_rho_set));
test_LEs_transient_set =  cell(1,length(eig_rho_set));


for i =1:length(eig_rho_set)
 eig_rho = eig_rho_set(i);
T_ex = func_dynamic_test_error(eig_rho);
Predict_time(i) = T_ex;
[std_test, std_train, train_LEs, train_LEs_transient, test_LEs, test_LEs_transient]=func_LES_test(eig_rho);
train_LEs_transient_set{i} = train_LEs_transient;
test_LEs_transient_set{i} = test_LEs_transient;
std_train_set{i} = std_train;
train_LEs_set{i} = train_LEs(end,:);
std_test_set{i} = std_test;
test_LEs_set{i} =  test_LEs(end,:);
end
save data_in_quasi_W_asy.mat std_train_set train_LEs_set std_test_set test_LEs_set Predict_time train_LEs_transient_set test_LEs_transient_set
figure
plot(eig_rho_set, Predict_time,'.-')