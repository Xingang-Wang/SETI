% Deterministic checks for the sustained-loss window-density criterion.
lorenz_dir = fullfile(fileparts(mfilename('fullpath')), 'lorenz');
addpath(lorenz_dir);
cleanup_path = onCleanup(@() rmpath(lorenz_dir)); %#ok<NASGU>

n = 100;
y_true = ones(n, 1);

% An isolated violation must not end the forecast.
y_pred = y_true;
y_pred(20) = 2;
assert(func_calculate_precise_prediction_periods( ...
    y_true, y_pred, 0.2, 50, 0.80) == n);

% Forty violations in samples 21:60 first fill a qualifying window 11:60.
% The returned zero-based divider is therefore 10 elapsed steps.
y_pred = y_true;
y_pred(21:60) = 2;
assert(func_calculate_precise_prediction_periods( ...
    y_true, y_pred, 0.2, 50, 0.80) == 10);

% The optional fifth argument defaults to the paper value theta=0.80.
assert(func_calculate_precise_prediction_periods( ...
    y_true, y_pred, 0.2, 50) == 10);

% Thirty-nine violations are below the 40/50 density threshold.
y_pred = y_true;
y_pred(21:59) = 2;
assert(func_calculate_precise_prediction_periods( ...
    y_true, y_pred, 0.2, 50, 0.80) == n);

% Non-finite predictions count as violations.
y_pred = y_true;
y_pred(1:40) = NaN;
assert(func_calculate_precise_prediction_periods( ...
    y_true, y_pred, 0.2, 50, 0.80) == 0);

disp('test_prediction_period_density: all checks passed');
