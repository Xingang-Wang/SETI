
%clc;clear;
%%
function  [std_test, std_train, train_LEs, train_LEs_transient, test_LEs, test_LEs_transient]=func_LES_test(eig_rho)
% load opt_data_quasi_trainlen_5000.mat 
% load min_rng_set_quasi_trainlen_5000.mat 
load opt_data_quasi_dt_5_train_10000.mat 
load min_rng_set_quasi_dt_5_train_10000.mat 

%%
data_num=1;
 result = getfield ( opt_trials,'Fval');
 param= getfield ( opt_trials,'X');
 [sort_result,result_num]=sort(result);
 sort_param=param(result_num,:);
 opt_result=sort_param(1,:);
 sort_rng=min_rng_set(result_num);
 opt_rng=sort_rng(1);
 rng(opt_rng);
%%
drive_num=200;
nonliner_num=1;
%testnum=size(testdata,1)/4;
%%
%eig_rho =opt_result(1);
W_in_a =opt_result(2);
a=0.7;
%a = opt_result(3);
reg = opt_result(4);
%reg=1e-3;
density =opt_result(5);
%density = 0.1;

resSize =500; % size of the reservoir nodes;  
initLen = 100;
TrainLen=sum(data_len)-1;
test_Len = 1000;
testLen=1000;
inSize = 3; 
outSize = 3;
%%
reservoir_train_history = zeros(TrainLen,resSize);
reservoir_test_history = zeros(test_Len,resSize); 
%%
%train_data = zeros(3,5000);

% load  train_data_qua.mat 
% train_data = data_qua;
%train_data = zeros(3,5000);
% load  train_data_qua.mat data_qua
% train_data = data_qua(:,1:5000);
indata=train_data;

  %X = zeros(nonliner_num*resSize+1,TrainLen);
  X = zeros(resSize,TrainLen);
  Yt = indata(1:outSize,2:TrainLen+1);% run the reservoir with the data and collect X
%%
Win = (2.0*rand(resSize,inSize)-1.0)*W_in_a;
% WW = zeros(resSize,resSize);
% for i=1:resSize
%     for j=i:resSize
%             if (rand()<density)
%              WW(i,j)=(2.0*rand()-1.0);
%              WW(j,i)=WW(i,j);
%             end
%     end
% end
% rhoW = eigs(WW,1);
% W = WW .* (eig_rho /rhoW); 
%%
WW = zeros(resSize, resSize);
for i = 1:resSize
    for j = 1:resSize
        if rand() < density
            WW(i, j) = 2*rand() - 1;
        end
    end
end
%%
% rhoW = eigs(WW,1);
% W = WW .* (eig_rho /rhoW); 
rhoW = max(abs(eig(full(WW))));
W    = WW * (eig_rho / rhoW);

x = rand(resSize,1);
for t = 1:TrainLen
    u = indata(:,t);
    x = (1-a)*x + a*tanh( Win*u + W*x );
    %X(:,t) = [1;x;x.^2;];
    X(:,t) = x;
    reservoir_train_history(t,:)=x;
end

Data_len=[0,5000];
for i=0:data_num-1
   trainLen=sum(Data_len(1:i+1));
   X(:,trainLen+1-i*initLen:trainLen+initLen-i*initLen)=[];
   Yt(:,trainLen+1-i*initLen:trainLen+initLen-i*initLen)=[];
end
rank=randperm( size(X,2) ); 
X=X(:, rank); 
Yt=Yt(:, rank); 
X_T = X';
%Wout = Yt*X_T / (X*X_T + reg*eye(nonliner_num*resSize+1));
Wout = Yt*X_T / (X*X_T + reg*eye(nonliner_num*resSize));
% %%
y_train = Wout*X;
error_train = mean(abs(y_train(1,:)-Yt(1,:)))+ mean(abs(y_train(2,:)-Yt(2,:)))+ mean(abs(y_train(3,:)-Yt(3,:)));

Y1= zeros(outSize,testLen);

    %rng(2);
    x1=zeros(resSize,1);
    %x1=rand(resSize,1);
     u(1,1)=testdata(3*(i+1)-2,1);
     u(2,1)=testdata(3*(i+1)-1,1);
     u(3,1)=testdata(3*(i+1),1);
   
for t = 1:test_Len-1 
    x1 = (1-a)*x1 + a*tanh( Win*u + W*x1 );
  
    %y = Wout*[1;x1;x1.^2;];
    y = Wout*x1;
    Y1(:,t+1) = y;
     if t<drive_num
    u(1,1)=testdata(3*(i+1)-2,1+t);
    u(2,1)=testdata(3*(i+1)-1,1+t);
    u(3,1)=testdata(3*(i+1),1+t);
    else
    u = y;   
     end  
    reservoir_test_history(t,:)=x1;
end
reservoir_train_history(1:initLen,:) = [];
train_data(:,1:initLen)=[];
reservoir_test_history(1:drive_num,:) = [];
TrainLen = TrainLen-initLen;
test_Len =  test_Len-drive_num;
% figure
% plot( reservoir_train_history(1:end,1:3),'.-');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% xlim([ -10 1010])
% figure
% plot(indata(1,end-1000:end),'.-');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% xlim([ -10 1010])



[train_LEs,train_LEs_transient] = func_calculate_train_LES(resSize,reservoir_train_history,TrainLen,train_data,Win, W,a,Wout);
% 
% figure
% plot(train_LEs_transient(end-1000:end,:),'.-');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% xlim([ -10 1010])
% figure
% for i= 0:5:30
%     plot(train_LEs_transient(end-1000:end,end-i),'.-');
%     hold on;
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% xlim([ -10 1010])
% end

% [test_LEs,test_LEs_transient] = func_calculate_test_LES(resSize,reservoir_test_history,test_Len,Win, W,a,Wout);
% 
% std_test = func_plot_test(test_LEs_transient,test_LEs);
std_train = func_plot_train(train_LEs_transient,train_LEs);
test_LEs = 0;
test_LEs_transient = 0;
std_test = 0;
%save data_rho_05.mat std_test std_train train_LEs train_LEs_transient test_LEs test_LEs_transient

% [a_fit_train,b_fit_train] = func_LES_fit(std_train);
% [a_fit_test,b_fit_test] = func_LES_fit(std_test);
% save loz_lamda_2.495_sigma_0.5_zeros.mat reservoir_test_history reservoir_train_history...
%     Win W a drive_num Wout TrainLen test_Len train_data
% save LES_opt_trainlen_5000_resize_500.mat testdata train_LEs test_LEs
% figure
% plot(Y1(1,drive_num+1:1000),'.-');
% hold on;
% plot(testdata(1,drive_num+1:1000),'.-');
% 
% figure
% plot(test_LEs);
% ylim([-10 1]);
% 
% figure
% plot(train_LEs(end-300:end,:));
% ylim([-10 1]);
