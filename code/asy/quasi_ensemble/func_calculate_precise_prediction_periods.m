function N_precise = func_calculate_precise_prediction_periods( ...
    y_true, y_pred, epsilon_percent, window_length, bad_fraction)
% Return the onset of sustained forecast loss using a window-density rule.
%
% A sample is labelled bad when
%   abs(y_pred-y_true) > epsilon_percent * abs(y_true).
% The divider is placed at the beginning of the first window containing at
% least bad_fraction bad samples.  Isolated crossings and brief returns below
% tolerance therefore do not by themselves define the prediction horizon.
%
% The paper-trajectory setting is window_length=50, bad_fraction=0.80.

    if nargin < 5
        bad_fraction = 0.80;
    end

    y_true = y_true(:);
    y_pred = y_pred(:);
    if numel(y_true) ~= numel(y_pred)
        error('y_true and y_pred must have the same number of samples.');
    end
    if window_length < 1 || window_length ~= floor(window_length)
        error('window_length must be a positive integer.');
    end
    if bad_fraction <= 0 || bad_fraction > 1
        error('bad_fraction must lie in (0,1].');
    end
    if epsilon_percent <= 0
        error('epsilon_percent must be positive.');
    end

    n = numel(y_true);
    N_precise = n;
    if n < window_length
        return;
    end

    tolerance = epsilon_percent .* max(abs(y_true), eps);
    bad = ~isfinite(y_pred) | ~isfinite(y_true) ...
        | abs(y_pred - y_true) > tolerance;
    cumulative_bad = [0; cumsum(double(bad))];
    bad_per_window = cumulative_bad(window_length+1:end) ...
        - cumulative_bad(1:end-window_length);
    min_bad = ceil(bad_fraction * window_length);
    first_window = find(bad_per_window >= min_bad, 1, 'first');

    if ~isempty(first_window)
        % Convert MATLAB's one-based window index to elapsed free-run steps.
        N_precise = first_window - 1;
    end
end
