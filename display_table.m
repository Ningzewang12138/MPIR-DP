function display_table(A,b,N,K)
    if b > 10^(-4)
        fprintf('%s  ', rats(b));
        for i = 1:N
        empty = isequal(A(i,:),zeros(1,K));
        if empty == 1
            fprintf('( )');
            continue;
        end
        if empty ~= 1
            d = find(A(i,:));
            fprintf('(');
            disp([num2str(d)]);
            fprintf('%c',8);
            fprintf(')')
            fprintf('  ');
        end
        end
    fprintf('\n');
    else 
        return
    end
end
