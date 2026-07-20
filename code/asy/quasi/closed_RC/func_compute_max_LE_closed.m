function lambda_max = func_compute_max_LE_closed(Win, Wout, W, a, reservoir_history, TrainLen)
    % 计算闭环RC的最大李雅普诺夫指数
    % 闭环演化: x_new = (1-a)*x + a*tanh(Win*Wout*x + W*x)
    % Jacobian: J = (1-a)*I + a*diag(sech(z).^2) * (Win*Wout + W)
    N = 500;
    nStepTransient = 0;
    delta0 = 0.01;
    delta = delta0 * ones(N, 1);
    transient_period = 1000;
    lyap_exp = 0;
    count = 0;

    % Precompute Win*Wout
    WinWout = Win * Wout;

    for n = (nStepTransient + 1):(TrainLen-1)
        x_current = reservoir_history(:, n);

        % 闭环 Jacobian: z = Win*Wout*x + W*x
        z = W * x_current + WinWout * x_current;
        hsech = sech(z).^2;
        J = (1 - a) * eye(N) + a * diag(hsech) * (W + WinWout);

        delta = J * delta;

        if n > transient_period
            d = norm(delta);
            delta = delta / d;
            lyap_exp = lyap_exp + log(d);
            count = count + 1;
        end
    end

    lambda_max = lyap_exp / count;
end
