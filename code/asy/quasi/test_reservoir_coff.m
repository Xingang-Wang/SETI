clc;clear;
load data_in_chen_transient.mat
eig_rho_set = 0:0.1:2;
error = zeros(1,length(eig_rho_set));
std_train_set = cell(1,length(eig_rho_set));
train_LEs_set = cell(1,length(eig_rho_set));
std_test_set = cell(1,length(eig_rho_set));
test_LEs_set = cell(1,length(eig_rho_set));
Predict_time = zeros(1,length(eig_rho_set));

train_LEs_transient_set = cell(1,length(eig_rho_set));
test_LEs_transient_set = cell(1,length(eig_rho_set));

for i =1:length(eig_rho_set)
    eig_rho = eig_rho_set(i);
% [rmse_dynamic,T_ex] = func_dynamic_test_error(eig_rho);
% error(i) = rmse_dynamic;
% Predict_time(i) = T_ex;
[width]=func_cov_reservoir(eig_rho);
width_set(i) = width

end
figure
plot(width_set,'.-')