function output=som(input)
%%
% This SOM is a fuzzy algorithm that derived from the Kohonen network. so we have:
%   Fuzzy  - this is the fuzzy SOM, where there is no Best
%                 Matching Unit (BMU) instead every neuron is a winner with 
%                 some degree. This degree is a fuzzy value where 1 indicates 
%                 winner take-all and 0 is not a winner.

% Usage: output = som(input) where input is a structure with the following fields
%
% data           - either the feature vector data organized in a n x d matrix or a
%                  dissimilarity data in matrix n x n
% alg            - which algorithm to use, which of course depends on the type of
%                  data you provided. The alg can take the Fuzzy SOM
% maxIter        - maximum number of iterations SOM will run before it terminates
% radius         - array of two elements indicating the start and end of the SOM
%                  neighborhood radius
% fuzzifier      - array of two elements indicating the start and end values of
%                  the fuzzifier
% weightInitType - indicates the type of weight/vector initialization
%                   1 = random initialization
%                   2 = randomly select c rows from the data to initialize the
%                  set of vectors, where c is the number of neurons
% The output is a structure of the following fields:
%   (assume  n = #patterns, c = #neurons, d = #dimensions)
%
% config    - this field contains the input structure to SOM
% V         - c x d matrix containing vectors/centers for objects
%             SOM or c x n relational vectors for relational SOM
% U         - c x n fuzzy partition matrix
% Dcc       - c x c matrix containing pairsewise dissimilarities among
%             neurons (Euclidean distance in d space)
% Dcn       - c x n matrix of the distances between neurons and patterns
% umatrix   - visual map that can be dsplayed in 2D or 3D to visualize the
%             cluster boundaries
% bmu       - the list of best matching units of patterns

    
    % Initialize Vectors/weights
    V = init(input);
    coords = node_coords(input.dim);
    nodeDist = squareform(pdist(coords,'euclidean'));
    
    %% Iterate
    for iter=1:input.maxIter      
        [V U bmu Dcn cost] = som_step(input, V, iter, nodeDist);
        fprintf('Iteration%d, Objfun= %f\n',iter, cost);    
    end

    Dcc = node_dist(input.alg, V,input.data);
    umatrix = som_umatrix(input.dim,Dcc);
    
    %% Generate output structure
    output = struct('config',input,...
                    'V',V,...
                    'U',U,...
                    'Dcc',Dcc,...
                    'Dcn',Dcn,...
                    'umatrix',umatrix,...
                    'bmu',bmu);
end
