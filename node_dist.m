function D = node_dist(alg,w,R)
%%
% Compute the pairwise distances among neurons. If we are using object SOM
% then we will use Euclidean distance in d space. 
% n = #patterns, d = #dimensions

    switch(alg)
     
        case {'Fuzzy'}
            D = squareform(pdist(w,'euclidean'));
    end 
end