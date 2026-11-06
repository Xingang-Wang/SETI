function [T_ex] = func_dynamic_test_error(eig_rho, seed)
load opt_data_quasi_dt_5_train_10000.mat
load min_rng_set_quasi_dt_5_train_10000.mat

testnum=1;
test_length = 10000;

testdata = func_testdata_loz(testnum,test_length);
data_len=5000;
data_num = 1;
%%
result = getfield ( opt_trials,'Fval');
 param= getfield ( opt_trials,'X');
 [sort_result,result_num]=sort(result);
 sort_param=param(result_num,:);
 opt_result=sort_param(1,:);
 sort_rng=min_rng_set(result_num);
 opt_rng=sort_rng(1);
 rng(seed);
drive_num=200;
nonliner_num=1;
numCopies = 1;

%%
W_in_a =opt_result(2);
a=0.7;
reg = opt_result(4);
density =opt_result(5);
T_ex = 0;
resSize =500;
initLen = 100;
TrainLen=sum(data_len)-1;
test_Len = test_length;
testLen= test_length;
inSize = 3;
outSize = 3;
%%
reservoir_train_history = zeros(TrainLen,resSize);
reservoir_test_history = zeros(test_Len,resSize);
%%
indata=train_data;
  X = zeros(resSize,TrainLen);
  Yt = indata(1:outSize,2:TrainLen+1);
%%
Win = (2.0*rand(resSize,inSize)-1.0)*W_in_a;
WW = zeros(resSize, resSize);
for i = 1:resSize
    for j = 1:resSize
        if rand() < density
            WW(i, j) = 2*rand() - 1;
        end
    end
end
rhoW = max(abs(eig(full(WW))));
W    = WW * (eig_rho / rhoW);
%%
x = zeros(resSize,1);
for t = 1:TrainLen
    u = indata(:,t);
    x = (1-a)*x + a*tanh( Win*u + W*x );
    X(:,t) = x;
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
Wout = Yt*X_T / (X*X_T + reg*eye(nonliner_num*resSize));
%%

Y1= zeros(outSize,testLen);
for i=0:testnum-1
    x1=zeros(resSize,1);
     u(1,1)=testdata(3*(i+1)-2,1);
     u(2,1)=testdata(3*(i+1)-1,1);
     u(3,1)=testdata(3*(i+1),1);

for t = 1:test_Len-1
    x1 = (1-a)*x1 + a*tanh( Win*u + W*x1 );
    y = Wout*x1;
    Y1(:,t+1) = y;
     if t<drive_num
    u(1,1)=testdata(3*(i+1)-2,1+t);
    u(2,1)=testdata(3*(i+1)-1,1+t);
    u(3,1)=testdata(3*(i+1),1+t);
    else
    u = y;
     end
end
% quasi: 轨道误差法，降低阈值更严格
y_true = testdata(3*i+1,drive_num+1:testLen);
y_pred = Y1(1,drive_num+1:testLen);
epsilon_percent = 0.05;
window_length = 50;
bad_fraction = 0.80;
exact_time = func_calculate_precise_prediction_periods( ...
    y_true, y_pred, epsilon_percent, window_length, bad_fraction);
T_ex = T_ex + exact_time * 0.02;
end
T_ex = T_ex / testnum;
