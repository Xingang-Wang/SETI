
clc;clear;
load data_in_chen_transient.mat
%load data_in_quasi_transient.mat
load  data_in_chen.mat 
%load data_chen_rand_in.mat
% load data_chen_a_0.7.mat
%load data_chen_a_0.7_same_hye.mat
%load data_chen_a_0.6_same_hye.mat
eig_rho_set =0:0.1:1.5;
mean_std_train = zeros(1,length(eig_rho_set));
mean_std_test = zeros(1,length(eig_rho_set));
TightPlot.ColumeNumber = 1;     % 子图行数
TightPlot.RowNumber = 1;    % 子图列数
% TightPlot.GapW = 0.2;  % 子图之间的左右间距
% TightPlot.GapH = 0.0;   % 子图之间的上下间距
% TightPlot.MarginsLower = 0.19;   % 子图与图片下方的间距
% TightPlot.MarginsUpper = 0.03;  % 子图与图片上方的间距
% TightPlot.MarginsLeft = 0.17;   % 子图与图片左方的间距
% TightPlot.MarginsRight = 0.01;  % 子图与图片右方的间距

TightPlot.GapW = 0.2;  % 子图之间的左右间距
TightPlot.GapH = 0.0;   % 子图之间的上下间距
TightPlot.MarginsLower = 0.15;   % 子图与图片下方的间距
TightPlot.MarginsUpper = 0.01;  % 子图与图片上方的间距
TightPlot.MarginsLeft = 0.13;   % 子图与图片左方的间距
TightPlot.MarginsRight = 0.03;  % 子图与图片右方的间距


p = tight_subplot(TightPlot.ColumeNumber,TightPlot.RowNumber,...
    [TightPlot.GapH TightPlot.GapW],...
    [TightPlot.MarginsLower TightPlot.MarginsUpper],...
    [TightPlot.MarginsLeft TightPlot.MarginsRight]); 


for j=1:1:length(eig_rho_set) 
   time(j) = Predict_time(j);
   Error(j) = error(j);
   mean_std_train (j) = mean(std_train_set{j});
   %result1=cell2mat(train_LEs_transient_set(j));
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
%左侧y轴
axes(p(1));
yyaxis left;
plot(x, y1, 'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 ...
   );

ylabel('$MVTLE$', 'Interpreter', 'latex');
%ylim([-0.01 0.15]);    % 设置左侧y轴范围
 

% 右侧y轴
yyaxis right;
plot(x, y2, 'LineStyle', '-', 'Marker', 'o', ...
    'LineWidth', 2, 'MarkerSize', 2 ...
    );
%ylim([11.5 14.1]);       % 设置右侧y轴范围

ylabel('$\Lambda$', 'Interpreter', 'latex');

% 公共设置
xlim([-0.1,1.6]);
xlabel('$ \rho$', 'interpreter', 'latex');
%ylabel('$sigma$', 'Interpreter', 'latex');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);
set(gcf,'unit','centimeters','position',[8 4 10 9]);


%%
