clc;clear;
load reservoir_data_rng99.mat
data1 = reservoir_train_history;
load reservoir_data_rng2.mat
data2 = reservoir_train_history;
figure
plot(data1(1:1000,1:5),'.-');
hold on;
plot(data2(1:1000,1:5),'.-');

