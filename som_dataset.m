function dataset = som_dataset(datasetNames)

i = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Iris Data - Vectorial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sum(ismember(datasetNames,'iris')) == 1
    data = csvread('iris.csv');

    dataset(i).name = 'Iris Data'; 
    dataset(i).objectData = data;
    dataset(i).relationalData = squareform(pdist(data,'euclidean'));
    dataset(i).labels = [repmat({'Setosa'},1,50) repmat({'Versicolor'},1,50) repmat({'Virginica'},1,50)];
    dataset(i).mapsize = [11 6];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parkinson. Data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sum(ismember(datasetNames,'parkinson')) == 1
    data = csvread('parkinson.csv');
    dataset(i).name = 'parkinson Data'; 
    dataset(i).objectData = data;
    dataset(i).relationalData = squareform(pdist(data,'euclidean'));
    dataset(i).labels =[repmat({'1'},1,95) repmat({'2'},1,100)];
    dataset(i).mapsize = [10 40];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sweet_bitter. Data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sum(ismember(datasetNames,'sweet')) == 1
    data = csvread('sweet.csv');
    dataset(i).name = 'sweet Data'; 
    dataset(i).objectData = data;
    dataset(i).relationalData = squareform(pdist(data,'euclidean'));
    dataset(i).labels =[repmat({'1'},1,100) repmat({'2'},1,100)];
    dataset(i).mapsize = [10 10];
end

end
