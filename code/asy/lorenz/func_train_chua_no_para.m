function [rmse,rmse_dynamic]  = func_train_chua_no_para(hyperpara_set,train_data,rng_num,testdata,data_num,data_len,test_num)
%%
rng(rng_num);
drive_num=200;

%%
eig_rho =hyperpara_set(1);
W_in_a = hyperpara_set(2);
a = hyperpara_set(3);
reg = hyperpara_set(4);
density =hyperpara_set(5);
%%
resSize =500; % size of the reservoir nodes;  
initLen = 100;
TrainLen=sum(data_len)-1;
test_Len = 1000;
testLen=1000;
inSize = 3; 
outSize = 3;
nonliner_num=1;
%%
  indata=train_data;
  X = zeros(nonliner_num*resSize,TrainLen);
  %X = zeros(resSize,TrainLen);
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
rhoW = eigs(WW,1);
W = WW .* (eig_rho /rhoW); 
x = zeros(resSize,1);
for t = 1:TrainLen
    u = indata(:,t);
    x = (1-a)*x + a*tanh( Win*u + W*x );
   % X(:,t) = [1;x;x.^2;];
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
rmse_dynamic=0;  
rng(4);
    for i=0:test_num-1
    x1=2*rand(resSize,1)-1;
    Y1(:,1)=rand(3,1);
for t = 1:test_Len-1 

    x1 = (1-a)*x1 + a*tanh( Win*u + W*x1 );
    %y = Wout*[1;x1;x1.^2;];
    y = Wout*x1;
    Y1(:,t+1) = y;
     if t<drive_num
     u(1,1)=testdata(3*i+1,1+t);
     u(2,1)=testdata(3*i+2,1+t);
     u(3,1)=testdata(3*i+3,1+t);
    else
    u = y;   
     end  
   
end

rmse_dynamic=rmse_dynamic+mean(abs(Y1(3,drive_num+1:testLen)-testdata(3*i+3,drive_num+1:testLen)))+...
    mean(abs(Y1(2,drive_num+1:testLen)-testdata(3*i+2,drive_num+1:testLen)))+...
    mean(abs(Y1(1,drive_num+1:testLen)-testdata(3*i+1,drive_num+1:testLen)));
    end

rmse=rmse_dynamic/test_num;
if isnan(rmse) || rmse>10
    rmse=10;
end
