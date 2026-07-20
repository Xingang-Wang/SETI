function N_precise = func_calculate_precise_prediction_periods_quasi(y_true, y_pred, win_len, corr_thresh, tau)
% 计算准周期系统的精准预测时间
% 使用滑动窗口多维相关系数检测相位漂移
%
% 输入:
%   y_true      - 真实轨迹 (3 x n)，已截取 drive 后的自由演化段
%   y_pred      - 预测轨迹 (3 x n)，同上
%   win_len     - 滑动窗口长度
%   corr_thresh - 相关性阈值
%   tau         - 连续低于阈值的容忍步数
%
% 输出:
%   N_precise   - 精准预测持续的时间步数

n = size(y_true, 2);
N_precise = 0;
N_below = 0;

for t = win_len:n
    win_true = y_true(:, t-win_len+1:t);  % 3 x win_len
    win_pred = y_pred(:, t-win_len+1:t);  % 3 x win_len

    % 将 3 维展平为一维向量，计算整体 Pearson 相关
    flat_true = win_true(:);
    flat_pred = win_pred(:);
    m_true = mean(flat_true);
    m_pred = mean(flat_pred);
    r = (flat_pred - m_pred)' * (flat_true - m_true) / ...
        (std(flat_pred) * std(flat_true) * (length(flat_true) - 1));

    if r >= corr_thresh
        N_below = 0;
        N_precise = N_precise + 1;
    else
        N_below = N_below + 1;
        if N_below > tau
            break;
        end
    end
end
end
