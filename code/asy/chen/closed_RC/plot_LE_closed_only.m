% asy/chen: closed-loop RC max LE only
clc; clear;

load closed_RC/RC_data_closed_asy_chen.mat
closed_LE = cell2mat(maxLE_set);
closed_rho = eig_rho_range;

figure;
set(gcf, 'unit', 'centimeters', 'position', [2 10 8.9 6.5]);
hold on;

plot(closed_rho, closed_LE, '-o', 'Color', [0.4660 0.6740 0.1880], ...
    'LineWidth', 1.8, 'MarkerSize', 4, 'MarkerFaceColor', [0.4660 0.6740 0.1880]);

yline(0, '-k', 'LineWidth', 0.8);
xlabel('$\rho$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\lambda_{\max}$', 'Interpreter', 'latex', 'FontSize', 18);
xlim([-0.1, 3.1]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
box on;

print('closed_RC/asy_chen_LE_closed_only', '-depsc', '-painters');
