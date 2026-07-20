
clc;clear;
load opt_data_quasi_dt_5_train_10000.mat 
load min_rng_set_quasi_dt_5_train_10000.mat 
data_num =1;
test_length = 20000;
%data_len = 8000;
test_num=1;
testdata = func_testdata_loz(test_num,test_length);
%load  testdata.mat testdata
% data_len=5000;
% data_num = 1;
%[train_data,testdata,data_num,data_len]= func_other_dataset();
%test_num = 10;
%%
result = getfield ( opt_trials,'Fval');
 param= getfield ( opt_trials,'X');
 [sort_result,result_num]=sort(result);
 sort_param=param(result_num,:);
 opt_result=sort_param(1,:);
 sort_rng=min_rng_set(result_num);
 opt_rng=sort_rng(1);
 rng(opt_rng);
rng(35);
drive_num=200;
nonliner_num=1;
numCopies = 1;  % 需要复制的次数


%testnum=1;
%%
eig_rho =0.2;
W_in_a =opt_result(2);
a=0.7;
%a = opt_result(3);
reg = opt_result(4);
%reg=1e-3;
density =opt_result(5);
%density = 0.6;

resSize =500; % size of the reservoir nodes;  
initLen = 100;
TrainLen=sum(data_len)-1;
test_Len = test_length;
testLen=test_length;
inSize = 3; 
outSize = 3;
%%
reservoir_train_history = zeros(TrainLen,resSize);
reservoir_test_history = zeros(test_Len,resSize); 
%%
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
%%
x = zeros(resSize,1);
for t = 1:TrainLen
    u = indata(:,t);
    x = (1-a)*x + a*tanh( Win*u + W*x );
    %X(:,t) = [1;x;x.^2;];
    X(:,t) = x;
    %reservoir_train_history(t,:)=x;
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
%%
RC_data=[];
rmse=0;
rmse_dynamic=0;    

Y1= zeros(outSize,testLen);
for i=0:test_num-1
     %rng(5);
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
    %reservoir_test_history(t,:)=x1;
end
rmse_dynamic=rmse_dynamic+mean(abs(Y1(3,drive_num+1:testLen)-testdata(3*i+3,drive_num+1:testLen)))+...
    mean(abs(Y1(2,drive_num+1:testLen)-testdata(3*i+2,drive_num+1:testLen)))+...
    mean(abs(Y1(1,drive_num+1:testLen)-testdata(3*i+1,drive_num+1:testLen)));
j=j+1;
t1=0.05:0.05:0.05*10;
t2=0.05*11:0.05:0.05*testLen;
t3=0.05:0.05:0.05*testLen;
% save loz_lamda_2.495_sigma_0.5_zeros.mat reservoir_test_history reservoir_train_history...
%     Win W a drive_num Wout TrainLen test_Len train_data
%%
figure
plot(testdata(3*i+1,1:test_Len),'.-');
hold on;
ylim([0 1]);
plot(Y1(1,1:test_Len),'.-');
end
rmse_dynamic=rmse_dynamic/test_num;
