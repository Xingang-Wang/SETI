function states = func_generate_reservoir_states(eig_rho, T_transient)
%

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
%%
indata=train_data;
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
x = zeros(resSize,1);
for t = 1:TrainLen
    u = indata(:,t);
    x = (1-a)*x + a*tanh( Win*u + W*x );
    %X(:,t) = [1;x;x.^2;];
    X(:,t) = x;
    reservoir_train_history(t,:)=x;
end

states =reservoir_train_history(T_transient:end,:)';