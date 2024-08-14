function [p,opt] =PIR_DP(N,K,D,eps,delta)


% clear
% clc
% %% Define the pararmeter
% 
% K = 6;   % Total number of messages
% N = 3;   % Total number of servers
% D = 2;   % Total number of demands
% eps = 1;  % parameter of differential privacy, exponent.
% delta = 0;  % parameter of differential privcay, addend.


all_demands = nchoosek(1:K,D);  % All possible D-tuple demands


%% Get the search_space based on the preveious allerton paper
% search_space includes: 1st column: each row of  N queries; 
% 2nd column: demands; 3rd column: downloadcost 

search_space = {};
for i =1:nchoosek(K,D)
    W = all_demands(i,:);
    table = query_table(N,K,W);
    search_space = [search_space;table];
end

table_len = size(table,1);  % The length of each query table
space_len = size(search_space,1); % The length of the whole search space

%% Setup the constraints for the LP 
% Get all possible queries as prototype

all_queries = [];
for i = 1:K
    ituple_queries_ind = nchoosek(1:K,i);
    for j = 1:nchoosek(K,i)
        query = zeros(1,K);
        query(1,ituple_queries_ind(j,:)) = 1;
        all_queries = [all_queries;query];
    end
end


% Get the positions of each prototype in search space
% query_collect store the indices for each prototype of queries

query_collect = {};
query_count = 1;
for i = 1:length(all_queries)
    inds = [];
    query = all_queries(i,:);
    query_collect{query_count,1} = query;
    for j = 1:space_len
        row_queries = search_space{j,:};
        for n = 1:N
            if isequal(row_queries(n,:),query)
               inds = [inds,j];
            end
        end
    
    end
    query_collect{query_count,2} = inds;
    query_count = query_count + 1;
end

% Get the privacy constraints for each query
% First, find the relation of each query between every two query tables
% that have only one different element of demands. 

A = [];
for i = 1:length(all_queries)      
    query = all_queries(i,:);
    all_positions = query_collect{i,2};  
    %positions = unique(all_positions);
    for j = 1:nchoosek(K,D)-1
        for m = j+1:nchoosek(K,D)
            demands_1 = all_demands(j,:);
            demands_2 = all_demands(m,:);
            if ~checkOneElementDifference(demands_1,demands_2)
                continue;
            else
                rv1 = [];
                rv2 = [];
                for v = 1:length(all_positions)
                    
                    tmp = search_space{all_positions(1,v),2};
                    if isequal(tmp,demands_1)
                        rv1 = [rv1,all_positions(1,v)];
                    elseif isequal(tmp,demands_2)   
                            rv2 = [rv2,all_positions(1,v)];
                    else
                        continue;
                    end     
                end
               tmp = zeros(1,space_len);
               u_rv1 = unique(rv1);
               u_rv2 = unique(rv2);
               for l1 = 1:length(rv1)
                   tmp(1,rv1(1,l1)) = tmp(1,rv1(1,l1)) + 1;
               end
              
                for l2 = 1:length(rv2)
                    tmp(1,rv2(1,l2)) = tmp(1,rv2(1,l2)) + 1; 
                end
                tmp1 = tmp;
                tmp1(1,u_rv2) = -1*tmp1(1,u_rv2)*exp(eps);
                A = [A;tmp1];
                tmp(1,u_rv1) = -1*tmp(u_rv1)*exp(eps);
                A = [A;tmp];
              
             end

        end
    end
end
   

b = -1*delta*ones(size(A,1),1);

% Create the constraints for each query table which is the sum of
% porbabilities is equal to 1
Aeq =[];
beq = ones(nchoosek(K,D),1);
for i = 1:nchoosek(K,D)
    tmp = zeros(1,space_len);
    tmp(1,(i-1)*table_len+1:i*table_len) = 1;
    Aeq =[Aeq;tmp];
end


A = sparse(A);
Aeq = sparse(Aeq);
b = sparse(b);
beq = sparse(beq);


% Constraints for each variable 
lb = zeros(space_len,1);
ub = ones(space_len,1);

% LP function
dc = cell2mat(search_space(:,3));

% A = sparse(A);
% Aeq = sparse(Aeq);

% LP
[p,opt] = linprog(dc,A,b,Aeq,beq,lb,ub);  

% optimal expected downloadcost for each table
opt = opt/nchoosek(K,D);

%% Display the optimal scheme

table = {}; 
for i = 1:length(p)
    display_table(search_space{i,1},p(i,1),N,K);
    
end
end




























