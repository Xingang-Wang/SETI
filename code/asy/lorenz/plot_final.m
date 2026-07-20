clc;clear;
%load data_lorenz_transient.mat
load data_in_lorenz.mat
%load data_lorenz_rand_input.mat
%load data_lorenz_test_inital.mat
%load data_lorenz_reg_10_6.mat
%load data_lorenz_reg_10_5.mat
%load data_lorenz_reg_10_3.mat
load data_lorenz_a_0.7.mat
%load data_lorenz_a_0.3.mat
%load data_lorenz_noise_01.mat
eig_rho_set =0:0.1:1.5;
mean_std_train = zeros(1,length(eig_rho_set));
mean_std_test = zeros(1,length(eig_rho_set));
TightPlot.ColumeNumber = 1;     % 子图行数
TightPlot.RowNumber = 1;    % 子图列数
TightPlot.GapW = 0.2;  % 子图之间的左右间距
TightPlot.GapH = 0.0;   % 子图之间的上下间距
TightPlot.MarginsLower = 0.19;   % 子图与图片下方的间距
TightPlot.MarginsUpper = 0.03;  % 子图与图片上方的间距
TightPlot.MarginsLeft = 0.17;   % 子图与图片左方的间距
TightPlot.MarginsRight = 0.01;  % 子图与图片右方的间距

% TightPlot.GapW = 0.2;  % 子图之间的左右间距
% TightPlot.GapH = 0.0;   % 子图之间的上下间距
% TightPlot.MarginsLower = 0.15;   % 子图与图片下方的间距
% TightPlot.MarginsUpper = 0.01;  % 子图与图片上方的间距
% TightPlot.MarginsLeft = 0.13;   % 子图与图片左方的间距
% TightPlot.MarginsRight = 0.03;  % 子图与图片右方的间距


p = tight_subplot(TightPlot.ColumeNumber,TightPlot.RowNumber,...
    [TightPlot.GapH TightPlot.GapW],...
    [TightPlot.MarginsLower TightPlot.MarginsUpper],...
    [TightPlot.MarginsLeft TightPlot.MarginsRight]); 


for j=1:1:length(eig_rho_set) 
   time(j) = Predict_time(j);
   Error(j) = error(j);
   mean_std_train (j) = mean(std_train_set{j});
   result1=cell2mat(train_LEs_transient_set(j));
   %x = 0*0.04:0.04:200*0.04;
 
   %figure
%    axes(p(1));
%    for i=1:500
%        if mod(i,10) == 0
%        plot(x,result1(end-200:end,i), 'LineStyle', '-', 'Marker', 'o', ...
%        'LineWidth', 1.5, 'MarkerSize', 1.5);
%        hold on;
%        end
%    end
%    xlabel('$t$', 'Interpreter', 'latex');
%    ylabel('$\lambda_{i}$', 'Interpreter', 'latex');
%    xlim([ -5*0.04 205*0.04])
%    ylim([-8.2 0]);
%    set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
%    set(gcf,'unit','centimeters','position',[8 4 10 9]);
%    result=cell2mat(std_train_set(j));
%    figure
%    plot(result, 'LineStyle', '-', 'Marker', 'o', ...
%        'LineWidth', 1, 'MarkerSize', 1);
    % save std_train_set_15.mat result
end

y1 = mean_std_train;
y2 = time*0.95/5;
%y2 =Error;

x = eig_rho_set;
figure
% 左侧y轴
% %axes(p(1));
% yyaxis left;
% plot(x, y1, 'LineStyle', '-', 'Marker', 'o', ...
%     'LineWidth', 2, 'MarkerSize', 2 ...
%    );
% 
% ylabel('$MVTLE$', 'Interpreter', 'latex');
% ylim([-0.01 0.15]);    % 设置左侧y轴范围
%  
% 
% % 右侧y轴
% yyaxis right;
% plot(x, y2, 'LineStyle', '-', 'Marker', 'o', ...
%     'LineWidth', 2, 'MarkerSize', 2 ...
%     );
% ylim([11.5 14.1]);       % 设置右侧y轴范围
% 
% ylabel('$\Lambda$', 'Interpreter', 'latex');
% 
% % 公共设置
% xlim([-0.1,1.6]);
% xlabel('$ \rho$', 'interpreter', 'latex');
% %ylabel('$sigma$', 'Interpreter', 'latex');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
% set(gcf,'unit','centimeters','position',[8 4 10 9]);
a_values=[0.4, 0.8, 1.4];  % The bifurcation parameter value 
                                % corresponding to each vertical line
posi=[0.02, 0.05, 0.02, 0.05];  % The location of each sampling point
% Draw multiple vertical lines and label them
for i=1:length(a_values)
    xline(a_values(i), '--b', 'LineWidth', 2); % Use a dashed blue line 
                                              % with a line width of 2
%     % Add annotations with x values
%     text(a_values(i), posi(i), ['a = ' num2str(a_values(i))], 'VerticalAlignment',...
%         'bottom', 'HorizontalAlignment', 'right', 'FontSize', 15, 'Color', 'red');
end
%%
load std_train_set_5.mat 
std_5 = result;
load std_train_set_9.mat 
std_9 = result;
load std_train_set_14.mat 
std_14 = result;
load std_train_set_15.mat 
std_15 = result;
%figure
axes(p(1));
plot(std_5,'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 );
hold on;
plot(std_9,'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 );
hold on;
plot(std_15,'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 );
ylabel('$error$', 'Interpreter', 'latex');
ylim([0 200]);       % 设置右侧y轴范围

% 公共设置
xlabel('$ n$', 'interpreter', 'latex');
ylabel('$\sigma_i$', 'Interpreter', 'latex');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
xlim([ -5 505]);
ylim([-0.03 1.1]);
 set(gcf,'unit','centimeters','position',[8 4 10 9]);
