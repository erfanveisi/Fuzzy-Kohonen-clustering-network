function V = init(input)
%%
% Initialize vectors. There are two approaches implemented here to initialize the vectors:
%   1 = random initialization
%   2 = randomly choose c rows from the dataset, where c is the number of
%       neurons.
% NOTEEEEEE: after initialize the relational cluster centers, they have to be
% normalized such that the sum of weights in every set is 1

    K = input.dim(1);
    J = input.dim(2);
    [n d] = size(input.data);
    
    switch(input.weightsInitFun)
        case 1
            V = rand(K*J,d);
        case 2
            randIdx = randperm(n)' * ones(1,ceil((K*J)/n));
            V = input.data(randIdx(1:K*J),:);
    end
end