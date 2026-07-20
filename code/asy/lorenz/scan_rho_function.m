clc;clear;

eig_rho_set = 0:0.1:2;
error = zeros(1,length(eig_rho_set));
function_set = cell(1,length(eig_rho_set));
B_set = cell(1,length(eig_rho_set));
for i =1:length(eig_rho_set)
    eig_rho = eig_rho_set(i);
    [B, rho_matrix] = func_function_matrix(eig_rho);
    B_set{i} = B;
    function_set{i} = rho_matrix;
end
save save_function.mat B_set  function_set
for i=1:21
    C = cell2mat(B_set(i));
    sum_set(i) = sum(C,'all');
    
end
figure
plot(sum_set,'.-');