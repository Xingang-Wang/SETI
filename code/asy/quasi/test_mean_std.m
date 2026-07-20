
clc;clear;
load data_rho_01.mat 
mean_01 = train_LEs(end,:);
std_01 = std_train;
result_01 = sum(mean_01.*std_01);
pos_01 = mean(mean_01(1:250));


load data_rho_03.mat 
mean_03 = train_LEs(end,:);
std_03 = std_train;
result_03 = sum(mean_03.*std_03);
pos_03 = mean(mean_03(1:250));


load data_rho_04.mat 
mean_04 = train_LEs(end,:);
std_04 = std_train;
result_04 = sum(mean_04.*std_04);
pos_04 = mean(mean_04(1:250));


load data_rho_06.mat 
mean_06 = train_LEs(end,:);
std_06 = std_train;
result_06 = sum(mean_06.*std_06);
pos_06 = mean(mean_06(1:250));



load data_rho_08.mat 
mean_08 = train_LEs(end,:);
std_08 = std_train;
result_08 = sum(mean_08.*std_08);
pos_08 = mean(mean_08(1:250));



load data_rho_1.mat 
mean_1 = train_LEs(end,:);
std_1 = std_train;
result_1 = sum(mean_1.*std_1);
pos_1 = mean(mean_1(1:250));




load data_rho_15.mat 
mean_15 = train_LEs(end,:);
std_15 = std_train;
result_15 = sum(mean_15.*std_15);
pos_15 = mean(mean_15(1:250));

load data_rho_2.mat 
mean_2 = train_LEs(end,:);
std_2 = std_train;
result_2 = sum(mean_2.*std_2);
pos_2 = mean(mean_2(1:250));