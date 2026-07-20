function lambda_max = func_compute_max_lyapunov_exponent(W, a, reservoir_history, TrainLen)
    % 计算自治系统的最大李雅普诺夫指数
    % 输入:
    %   W - 权重矩阵
    %   a - 参数
    %   reservoir_history - 系统状态历史
    %   TrainLen - 训练长度
    
    %N = size(W, 1);  % 系统维度
    N = 500;
    % 参数设置
    nStepTransient = 0;     % 初始 transient 步数
    
    % 初始化扰动向量
    delta0 = 0.01;    % 随机初始扰动
    delta = delta0 * ones(N, 1);

   transient_period =1000;
    
    lyap_exp = 0;   % 累积李指数
    count = 0;                 % 有效步数计数
    
    % 主计算循环
    for n = (nStepTransient + 1):(TrainLen-1)
        % 获取当前状态
        x_current = reservoir_history(:, n);
        
        % 计算雅可比矩阵（自洽系统）
        z = W * x_current;
        hsech = sech(z).^2;
        J = (1 - a) * eye(N) + a * diag(hsech) * W;
        
        % 扰动演化（离散系统，不需要指数映射）
        delta = J * delta;
        
        % 计算扰动范数
       
    
     if n> transient_period
            % 标准化扰动向量并累积李亚普诺夫指数
            d = norm(delta);
            delta = delta / d;
            lyap_exp = lyap_exp + log(d);
            count = count+1;
     end
     
    end

   
    lambda_max = lyap_exp / count;
end