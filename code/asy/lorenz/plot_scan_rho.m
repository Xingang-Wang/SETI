clc;clear;
%load data_lorenz_transient.mat
%load data_in_lorenz.mat
%load data_lorenz_rand_input.mat
%load data_lorenz_test_inital.mat
%load data_lorenz_reg_10_6.mat
%load data_lorenz_reg_10_5.mat
%load data_lorenz_reg_10_3.mat
%load data_lorenz_a_0.7.mat
load data_lorenz_asy_W_a_0.7.mat
%load data_lorenz_asy_W_a_0.7_same_hye.mat
%load data_lorenz_noise_01.mat
eig_rho_set =0:0.1:1.5;
mean_std_train = zeros(1,length(eig_rho_set));
mean_std_test = zeros(1,length(eig_rho_set));
for j=1:1:length(eig_rho_set) 
time(j) = Predict_time(j);
Error(j) = error(j);
    
 result1=cell2mat(train_LEs_transient_set(j));
%  for i =1:50:500
%  figure
%  plot(result1(end-200:end,i),'.-');
%  end
std_train = cell2mat(std_train_set(j));
train_les = cell2mat(train_LEs_set(j));
sta(j) = mean(std_train.*train_les);
std_mean(j)= mean(std_train);
%figure
% plot(std_train,'.-');
% hold on;
end 

% figure
% plot(mean_train,'.-');
%figure
% plot(eig_rho_set, re_test,'.-');
% line([0,2],[0,0], 'LineStyle', '--')
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
figure
plot(eig_rho_set,time,'.-');
figure
plot(eig_rho_set,Error,'.-');
% plot(eig_rho_set,time,'.-');
% hold on;
figure
plot(eig_rho_set,sta,'.-');
figure
plot(eig_rho_set,std_mean,'.-');
% figure
% plot(eig_rho_set,sta,'.-');
% figure
% plot(eig_rho_set,std_mean,'.-');
% % figure
% hold on;
% plot(eig_rho_set,Error/4,'.-')
% xlabel('$ \rho$', 'interpreter', 'latex');
% % %ylabel('$sigma$', 'Interpreter', 'latex');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% % 

% figure
% 
% plot(eig_rho_set,mean_std_test,'.-');
% hold on;
% % hold on;
% xlim([- 0.1 1.6])
% %ylim([-0.02 0.27])
% xlabel('$ \rho$', 'interpreter', 'latex');
% %ylabel('$sigma$', 'Interpreter', 'latex');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% 
% figure
% plot(eig_rho_set,time,'.-')

% 
% 
% figure
% plot(mean_std_train,Error-0.3,'.-')
% xlabel('$\sigma $', 'interpreter', 'latex');
% ylabel('performance', 'Interpreter', 'latex');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% %xlim([ 0 0.8])
% xlabel('$ \rho$', 'interpreter', 'latex');
% %ylabel('$sigma$', 'Interpreter', 'latex');
 %set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);

% figure
% plot(eig_rho_set,Predict_time,'.-')
% 
% figure
% plot(error(2:end),'.-')
% hold on;

% figure
% plot(mean_std_train(2:14),error(2:14),'.-')
% xlabel('$\sigma $', 'interpreter', 'latex');
% ylabel('performance', 'Interpreter', 'latex');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% 
% figure
% plot(width,'.-')
% figure
% plot(mean_std_train,'.-');
