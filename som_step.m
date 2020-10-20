function [V U bmu Dcn cost] = som_step(input, V, iter, nodeDist)
%%
% Perform one step for the Fuzzy SOM algorithm. Here we will compute
% and update the following:

%   1. update distance between the vector sets and the patterns
%   2. vectors set
%   3. the best matching units 
%   4. update the fuzzy partitions 
%   5. update the neighborhood function 

    x = input.data;
    [n ~] = size(x);
    trainLen = input.maxIter;
    munits = prod(input.dim);
    bmu = zeros(1,n);
    Dcn = zeros(munits,n);
    r = input.radius(1) * (input.radius(2)/input.radius(1))^(iter/trainLen);
    
    if isfield(input,'fuzzifier')
        m = input.fuzzifier(1) * (input.fuzzifier(2)/input.fuzzifier(1))^((iter-1)/trainLen);
    end
    
    switch(input.alg)
       
        case 'Fuzzy'
            %% Fuzzy batch SOM case            
            for i=1:n
                d = V - (x(i,:)'*ones(1,munits))';  
                Dcn(:,i) = sqrt(sum(d.^2,2));       
            end
            
            % update the neighbhorhood function
            h = exp(-nodeDist/(2*r^2));
            
            %hd is more like the topographic distance, it is the distance
            %weighted by the neighborhood function
            hd = (h.^m)*Dcn;
            
            tmp = zeros(size(hd));
            
            %ignore zero elements, they will cause problems
            nonzero = find(hd > 0);
            tmp(nonzero) = hd(nonzero).^(-1/(m-1));
            
            %again, we might run into zero elements here. those elements
            %gets propgrated from hd. So we need to handle those as well.
            stmp = sum(tmp);
            S = ones(munits, 1)*stmp;
            nonzero = find(S > 0);
            
            %update the membership values
            U = zeros(munits,n);
            
            %find where the sum of distance columns is zero, that means a
            %point equal distant from every neuron, then just assign an
            %equal membership of 1/c
            zero = stmp == 0;
            U(:,zero) = 1/munits; 
            U(nonzero) = tmp(nonzero) ./ S(nonzero);
            
            V = update_set('alg',input.alg,'U',U,'h',h,'bmu',bmu,'m',m,'x',x);

            % update the value of the objective function  
            hu = (h.^m); 
            UD = (U.^m) .* (hu * Dcn);
            cost = sum(UD(:));
            
            %best matching unit
            [~,bmu] = max(U);
            
            %visualization
            vistrn(V,x)
       
    end

end
