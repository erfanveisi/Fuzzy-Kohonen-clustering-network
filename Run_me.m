clc
clear 
close all
%load the datase : details (som_dataset.m)
dataset = som_dataset({'sweet'});

input.data              = dataset.objectData;
input.alg               = 'Fuzzy';
input.maxIter           = 100;
input.dim               = dataset.mapsize;
input.radius            = [1 0.5];
input.fuzzifier         = [2 1.01];
input.weightsInitFun    = 1;
        
map = som(input);

%compute the topographic and quantization errors
[qe te] = quality(map);


%compute the fuzzy topography error 
tef = fuzzy_quality_error(map, 1);
disp(['fuzzy topography error=', num2str(tef)] )     
       
%summarize the map
figure(1);
summarization(map, dataset);

figure(2);
X = dataset.objectData;
Y = map.V;
plot3(X(:,1),X(:,2),X(:,3), 'b.','MarkerSize',18)
hold on;
plot3(Y(:,1),Y(:,2),Y(:,3), 'r.','MarkerSize',18)
