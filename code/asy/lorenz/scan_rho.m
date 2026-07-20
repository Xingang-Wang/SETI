clc;clear;

eig_rho_set = 0:0.1:1.5;
%eig_rho_set =1.0;
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
[rmse_dynamic,T_ex] = func_dynamic_test_error(eig_rho);
error(i) = rmse_dynamic;
Predict_time(i) = T_ex;
[std_test, std_train, train_LEs, train_LEs_transient, test_LEs, test_LEs_transient]=func_LES_test(eig_rho);
%width_set = width(i)
std_train_set{i} = std_train;
train_LEs_set{i} = train_LEs(end,:)
std_test_set{i} = std_test; 
test_LEs_set{i} =  test_LEs(end,:);
train_LEs_transient_set{i} = train_LEs_transient;
a=mean(train_LEs(end,:).*std_train)
b= mean(std_train)
%test_LEs_transient_set{i} = test_LEs_transient;
end
%save data_lorenz_reg_10_5.mat error Predict_time
save data_lorenz_asy_W_a_0.7.mat train_LEs_transient_set std_train_set train_LEs_set error Predict_time
% save data_lorenz_noise_01.mat std_train_set train_LEs_set std_test_set  test_LEs_set ...
%     train_LEs_transient_set test_LEs_transient_set error Predict_time
% for j=1:length(eig_rho_set) 
%     plot(train_LEs_set{i})
%     hold on 
%     plot(test_LEs_set{i})
% end
