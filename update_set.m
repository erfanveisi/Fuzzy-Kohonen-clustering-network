function V = update_set(varargin)
    
    %evaluate the paramters
    for i=1:2:length(varargin)
        eval([genvarname(varargin{i}) ' = varargin{i+1};']);
    end
 
    %update the new set
    switch(alg)
                  
        case 'Fuzzy'
            %% Fuzzy SOM update
            V = zeros(size(h,1),size(x,2));
            S = (h.^m)*(U.^m*x);
            A = (h.^m)*(U.^m*~isnan(x));
            nonzero = find(A > 0);
            V(nonzero) = S(nonzero)./A(nonzero);      

    end
end
