clc;clear;

load data_std_rho_03.mat std_test std_train
mean_rho_03 = mean(std_test(251:end));
load data_std_rho_05.mat std_test std_train
mean_rho_05 = mean(std_test(251:end));
load data_std.mat std_test std_train
mean_rho_067 = mean(std_test(251:end));
load data_std_rho_08.mat std_test std_train
mean_rho_08 = mean(std_test(251:end));
load data_std_rho_09.mat std_test std_train
mean_rho_09 = mean(std_test(251:end));
load data_std_rho_15.mat std_test std_train
mean_rho_15 = mean(std_test(251:end));
load data_std_rho_2.mat std_test std_train
mean_rho_2 = mean(std_test(251:end));

rho_all= [0.3,0.5,0.67,0.8,0.9,1.5,2];
% mean_std_all= [mean_rho_03,mean_rho_05,mean_rho_067,mean_rho_08,mean_rho_09,...
%     mean_rho_15,mean_rho_2];

mean_std_all= [mean_rho_03.^2,mean_rho_05.^2,mean_rho_067.^2,mean_rho_08.^2,mean_rho_09.^2,...
    mean_rho_15.^2,mean_rho_2.^2];

error_all = [ 0.1437,0.1025,0.0829,0.0762,0.0815,0.1834,0.5079];
figure
plot(rho_all,mean_std_all,'.-');
hold on
%figure

plot(rho_all,error_all,'.-');

figure
plot(mean_std_all,error_all,'.-')

figure
plot(error_all,mean_std_all,'.-')


load data_std_in_1.mat std_test std_train
mean_in_1 = mean(std_train(251:end));

load data_std_in_05.mat std_test std_train
mean_in_05 = mean(std_train(251:end));