% asy/chen: plot max LE vs spectral radius for driven/auto/closed
clc; clear;

load driven_RC/RC_data_driven_asy_chen.mat
driven_LE = cell2mat(maxLE_set);
driven_rho = eig_rho_range;

load auto_RC/RC_data_auto_asy_chen.mat
auto_LE = cell2mat(maxLE_set);
auto_rho = eig_rho_range;

load closed_RC/RC_data_closed_asy_chen.mat
closed_LE = cell2mat(maxLE_set);
closed_rho = eig_rho_range;

figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
hold on;

plot(driven_rho, driven_LE, '-o', 'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.8, 'MarkerSize', 4, 'MarkerFaceColor', [0 0.4470 0.7410]);
plot(auto_rho, auto_LE, '-s', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth', 1.8, 'MarkerSize', 4, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
plot(closed_rho, closed_LE, '-d', 'Color', [0.4660 0.6740 0.1880], ...
    'LineWidth', 1.8, 'MarkerSize', 4, 'MarkerFaceColor', [0.4660 0.6740 0.1880]);

yline(0, '-k', 'LineWidth', 0.8);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\lambda_{\max}$', 'Interpreter', 'latex', 'FontSize', 18);
%legend({'Driven', 'Autonomous', 'Closed-loop'}, 'FontSize', 10, 'Location', 'northwest');
xlim([-0.1, 3.1]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;

print('closed_RC/asy_chen_LE_vs_rho', '-depsc', '-painters');
