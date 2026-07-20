
function [B, rho_matrix] = func_function_matrix(eig_rho)
load opt_data_testnum_10.mat 
load min_rng_set_testnum_10.mat 
%%

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
%eig_rho =0.5;
%W_in_a =1.2;

%a = opt_result(3);
a =0.3;
reg = opt_result(4);
%reg = 0.01;
density =opt_result(5);
%density = 0.9;

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
noise_matrix = rand(3,5000);  % 100x100矩阵
%%
indata = noise_matrix;
  %X = zeros(nonliner_num*resSize+1,TrainLen);
  X = zeros(resSize,TrainLen);
  Yt = indata(1:outSize,2:TrainLen+1);% run the reservoir with the data and collect X
%%
Win = (2.0*rand(resSize,inSize)-1.0)*W_in_a;
WW = zeros(resSize,resSize);
for i=1:resSize
    for j=i:resSize
            if (rand()<density)
             WW(i,j)=(2.0*rand()-1.0);
             WW(j,i)=WW(i,j);
            end
    end
end
rhoW = eigs(WW,1);
W = WW .* (eig_rho /rhoW);
  rng(2);
  x=zeros(resSize,1);
%x = zeros(resSize,1);
for t = 1:TrainLen
    u = indata(:,t);
    x = (1-a)*x + a*tanh( Win*u + W*x );
    %X(:,t) = [1;x;x.^2;];
    X(:,t) = x;
    reservoir_train_history(t,:)=x;
end

Data_len=[0,data_len];
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

[B, rho_matrix] = get_functional_network_time_avg(reservoir_train_history);

