function [table] = query_table(N,K,W)


all_messages = 1:K;
D = length(W);
all_sides = setdiff(all_messages,W);


demands_part = {};
d_count = 1;
for n = 1:D
    l_n = lcm(nchoosek(D,n),D)/D;
    m_n = D*l_n/nchoosek(D,n);
    D_n = nchoosek(W,n);
    all_D = repmat(D_n,m_n,1);
    for i = 1:l_n
        row = [];
        random_indices = randperm(size(all_D,1),D);
        temp = all_D(random_indices,:);
        while(size(unique(temp),1) < D)
            if n == D
                break;
            end
            random_indices = randperm(size(all_D,1),D);
            temp = all_D(random_indices,:);
        end
        all_D(random_indices,:) = [];
        for j = 1:size(temp,1)
            one_query = zeros(1,K);
            one_query(1,temp(j,:)) = 1;
            row = [row;one_query];
        end
        row = [zeros(1,K); row];
        demands_part{d_count,1} = row;
        d_count = d_count + 1;
    end
        
end

d_count = d_count - 1;
table = {};
count = 1;
for n = 1:d_count
    table{count,1} = demands_part{n,1};
    table{count,2} = W;
    table{count,3} = D;
    count = count + 1;
end


for i = 1:K-D
    sides_i = nchoosek(all_sides,i);
    for j = 1:nchoosek(K-D,i)
            side = sides_i(j,:);
            temp = zeros(N,K);
            temp(:,side) = 1;
            side_rows = temp;
            for n = 1:d_count
               d_row = demands_part{n,1};
               query = d_row + side_rows;
               table{count,1} = query;
               table{count,2} = W;
               table{count,3} = N;
               count = count +1;
            end

    end


end
end