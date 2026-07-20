
function [train_LEs,train_LEs_transient] = func_calculate_train_LES(resSize,reservoir_train_history,TrainLen,train_data,Win, W,a,Wout)

%%
h=reservoir_train_history';
N=resSize;
nLE=N;
tau=1-a;
dt=1;
%%
nStepTransient = 100;  % steps during initial transient
nStep = TrainLen;        % total number of steps
nstepONS = 1;      % steps between orthonormalizations
nStepTransientONS = 0; % steps during transient of ONS
nONS = ceil((nStep-nStepTransient)/nstepONS)-1; % number of ONS steps
%%
[Q, ~] = qr(randn(N,nLE),0);% initialize orthonormal system
diagElmR = 1:(nLE+1):nLE^2; % indices of diagonal elements or R
LS = zeros(1,nLE);      % initialize Lyapunov spectrum
t = 0;                  % set time to 0
Ddiag = eye(N)*tau;  % diagonal elements of Jacobian
LSall = zeros(nONS,nLE);             % initialize array to store convergence of Lyapunov spectrum
normdhAll = zeros(1,nONS);
printCondQ = true;
pAll = zeros(nONS,1);
lsidx = 0;
%%
cumulative_log_R = zeros(1, nLE); % 累积 log(abs(R))
FTLE_cumulative = [];            % 保存累积 FTLE
time_cumulative = [];            % 保存对应的累计时间


FTLE_transient = [];      % 存储瞬态FTLE
time_points = [];         % 时间点
window_T = nstepONS * dt; % 时间窗口长度
%%
for n = 2:nStep
   
   

        z(:,n-1) =  W * h(:,n-1) + Win * train_data(:,n-1);
        hsechdt = sech(z(:,n-1)).^2*(1-tau); % derivative of tanh(h)*dt

        D = Ddiag +bsxfun(@times, hsechdt,W); % Jacobian
        Q = D*Q; % evolve orthonormal system using Jacobian
         if n-1 > nStepTransient
        if mod(n-1,nstepONS) == 0
            
            
            [Q, R] = qr(Q,0); % performe QR-decomposition
            D = diag(sign(diag(R)));% if you want to make sure that Q is unique
            Q = Q*D; % otherwise these 3 lines can be deleted/commented out
            %R = D*R;
            if nLE == 1
                Q4 = Q.*Q.*Q.*Q;
            else
                
                Q1 = Q(:,1);
                Q4 = Q1.*Q1.*Q1.*Q1;
            end
             current_FTLE = log(abs(diag(R))) / window_T;  % 关键修正!

            % 记录瞬态动力学
            FTLE_transient(end+1, :) = current_FTLE;
            % 更新累积 log(abs(R))
            cumulative_log_R = cumulative_log_R + log(abs(R(diagElmR)));

            % 当前累计时间
            current_time = (lsidx + 1) * nstepONS * dt;

            % 计算累积 FTLE
            current_FTLE = cumulative_log_R / current_time;

            % 保存累积 FTLE 和对应时间
            FTLE_cumulative = [FTLE_cumulative; current_FTLE];
           % time_cumulative = [time_cumulative; current_time];
           lsidx = lsidx+1;
        end
       
     end
 end
train_LEs = FTLE_cumulative;
train_LEs_transient = FTLE_transient;
