clc
clear
%% Parameters
N = 3;
D = N - 1;
K = 5;
epsilon = log(3);

% Initialize vectors
L = zeros(1, D);
m = zeros(1, D);
K_vals = zeros(1, K-D+1);

% Calculate K values (binomial coefficients)
for i = 0:K-D
    K_vals(1, i+1) = nchoosek(K-D, i); 
end

% Calculate L and m values
for j = 1:D
    x = lcm(nchoosek(D, j), D);
    L(1, j) = x / D;
    m(1, j) = x / nchoosek(D, j);
end

% Sum of L values (block number)
blockno = sum(L);

% Initialize matrix M
M = zeros(D, D);

% Populate matrix M
for i = 1:D
    for j = 1:D
        if i == 1
            M(i, j) = L(1, j);
        elseif j == i-1
            M(i, j) = m(1, j) / m(1, i);
        end
    end
end

% Calculate matrix G
G = L*(eye(D, D) + exp(epsilon)*M)^(K-D);

% Calculate matrix F
F = L * exp((K-D)*epsilon)  * M^(K-D);


lb = zeros(1,blockno);
ub = ones(1,blockno);

[p,save] = linprog(-1*F,[],[],G,1,lb,ub);

DC = N + save;