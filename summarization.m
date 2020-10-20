function [region fig] = summarization(map, dataset)
%%

% Once SOM return the umatrix we can summarize the map by displaying labels
% on the various regions on the map. That is assuming you have some
% additional data associated with the patterns (labels, names, etc). The
% summarization is problem specific and most likely you will have to write
% your own code to summarize the map as your data is different that mine.
% For instance, if your data represents patients and with every patient you
% have an associated curve describing the patient behaviour with in the
% last year, then your labels are actually curves. In other simple cases
% your labels might categorical or numerical.
%
% This summarization depends on MATLAB built-in function, watershed(), in
% order to segment the U-matrix image into regions and then for every
% region decide what the label is. It also used the function regionprops()
% that returns the properties of every region found using watershed(). The
% propoerty we are most interested in is the Centroid of the region which
% is where the label for that region is located.

    coords = node_coords(map.config.dim);
    
    %this hardens the memberships and assigned a single neuron to every
    %object. This will tell us which neuron an object belongs to. Or as it
    %is also called the best matching unit (BMU), the same as 
    %   object2neuron = map.bmu;
    %
    %object2neuron is an array of 1 x n
    [~,object2neuron] = max(map.U);
    
    %track which neuron belongs to which region
    neuron2region = zeros(prod(map.config.dim),1);
    
    WS = watershed(map.umatrix);
    regionInd = unique(WS);
    regionInd = regionInd(2:end);
    
    %get region properties, we are mostly intereted in the centroid of the
    %region
    region = regionprops(WS);
    
    %imagesc makes the y-axis run from top to bottom, which will cause a
    %problem once we annotate the map with labels.
    fig = imagesc(1-map.umatrix);
    colormap(gray(256));
    set(gca,'YDir','normal');
    
    parentImgPos = get(gca,'Position');
    parentImgAxis = axis;
    
    %keep track of which objects are used so far
    objectsFound = [];
           
    switch(dataset.name)
       case 'ADL'
           %dimensions of the trajectory dim = [width height]
           dim = [0.1 0.1];
           
           %add label for every region
           for r=1:length(regionInd)
               rid = regionInd(r);
               regionTitle = sprintf('R%d',rid);
               text(region(rid).Centroid(1),region(rid).Centroid(2),regionTitle,'FontWeight','bold');
           end     
           
           %add ADL trajectory for every region
           for r=1:length(regionInd)
                rid = regionInd(r);
               
                %get the indicies for the neurons representing this region 
                neuronInds = find(WS == rid);
                region(rid).NeuronIndex = neuronInds;
                
                %assign the region ID to that neuron
                neuron2region(neuronInds) = rid;
                
                %save the coordinates of the neurons belonging to that
                %region
                region(rid).Neurons = coords(neuronInds,:);
                
                %find the data points belongning to that region, we use the
                %maximum value in the membership matrix to determine which
                %point belongs to which neurons in that region
                region(rid).Objects = find(ismember(object2neuron, neuronInds)==1);
                objectsFound = [objectsFound region(rid).Objects];
                
                %for every neuron get the representive object
                %it is the object with the highest cooefficient
                %
                %for crisp SOM we do not have representives for every
                %neurons since the u{ik} = {0,1} so all objects with
                %membership 1 are representitive of that neuron
                if strcmp(map.config.alg,'RELATIONALFUZZY')
                    reps = neuron2object(neuronInds);
                else
                    reps = region(rid).Objects;
                end
                
                %get the patient with the smallest distance to all other
                %patients in that region
                [~,s] = min(sum(map.config.data(reps,reps)));
                patient = dataset.extra(reps(s));
                region(rid).Label = patient;
                
                %for ADL the label is the shape of the trajectory, so we
                %would to plot the tarjector within every region
                %first, we need to figure out where to plot the trajectory,
                %for that we need to convert the region centroid to the
                %normalized position relative to the SOM map
                newAxisPos = parentImgPos(1) + parentImgPos(3) * ...
                            (region(rid).Centroid-parentImgAxis(1))/(parentImgAxis(2)-parentImgAxis(1)) - dim./2;
                
                %Boundary condition: 
                %do not let the overlay trajectories go outside the image
                %boundaries, 
                %left and bottom boundaries
                newAxisPos = max(newAxisPos,parentImgPos(1:2));
                
                %right boundary
                if newAxisPos(1)+dim(1) > parentImgPos(1)+parentImgPos(3)
                    newAxisPos(1) = newAxisPos(1) - ((newAxisPos(1)+dim(1)) - (parentImgPos(1)+parentImgPos(3)));
                end
                
                %top boundary
                if newAxisPos(2)+dim(2) > parentImgPos(2)+parentImgPos(4)
                    newAxisPos(2) = newAxisPos(2) - ((newAxisPos(2)+dim(2)) - (parentImgPos(2)+parentImgPos(4)));
                end
 
                %this is the position of the trajector
                %shift the position by half the width and height to make it
                %look more centered in the region
                newAxisPos = [newAxisPos dim];
                
                %plot the trajectory
                h = axes('Position', newAxisPos, 'Layer','top');
                plot(patient.date,patient.score,'-k','LineWidth',2);
                axis(h, 'off', 'tight');
                %set(gca,'YLim',[0 28]);
                
           end
           
       case 'GPD194'
           for r=1:length(regionInd)
                rid = regionInd(r);
                
                %get the indicies for the neurons representing this region 
                neuronInds = find(WS == rid);
                
                %save the coordinates of the neurons belonging to that
                %region
                region(rid).Neurons = coords(neuronInds,:);
                
                %assign the region ID to that neuron
                neuron2region(neuronInds) = rid;
                
                %find the data points belongning to that region, we use the
                %maximum value in the membership matrix to determine which
                %point belongs to which neurons in that region
                region(rid).objects = find(ismember(object2neuron, neuronInds)==1);
                objectsFound = [objectsFound region(rid).objects];
       
                %get the representitive objects/patterns for this region
                reps = find(ismember(map.bmu,neuronInds) == 1);
                
                genes = unique(dataset.extra(reps));
                title = [];
                for g=1:length(genes)
                   title = [title genes{g} '\newline']; 
                end
                
                %in case the region does not have a label
                if ~isempty(title)
                    regionTitle = sprintf('R%d:%s',rid,title);
                    text(region(rid).Centroid(1),region(rid).Centroid(2),regionTitle,'FontWeight','bold');
                end
            end
            
        otherwise
           
            %for every regoin found using watershed
            for r=1:length(regionInd)
                
                %region index/Id
                rid = regionInd(r); 
                
                %get the indicies for the neurons representing this region 
                neuronInds = find(WS == rid);
                
                %save the coordinates of the neurons belonging to that region
                region(rid).neurons = coords(neuronInds,:);
                
                %assign the region ID to that neuron
                neuron2region(neuronInds) = rid;
                
                %find the data points belongning to that region, we use the
                %maximum value in the membership matrix to determine which
                %point belongs to which neurons in that region
                %
                %we do that by intersecting the the array of BMU with the
                %array contaning the neurons in that region
                region(rid).objects = find(ismember(object2neuron, neuronInds)==1);
                objectsFound = [objectsFound region(rid).objects];
       
                %get the representitive objects/patterns for this region
                reps = find(ismember(map.bmu,neuronInds) == 1);
                
                %if labels are provided for every object
                if isfield(dataset,'labels')
                    %get the label for every representivitive object
                    [uniqueLabels,~,idx] = unique(dataset.labels(reps));
                    
                    if ~isempty(idx)
                        %do a histogram for the labels found
                        counts = accumarray(idx(:),1);
                        [~,labelIdx] = max(counts);

                        %get the label name
                        region(rid).label = uniqueLabels{labelIdx};

                        regionTitle = sprintf('R%d:%s',rid,region(rid).label);
                    end
                    
                    %add label for this region at the centroid
                    text(region(rid).Centroid(1),region(rid).Centroid(2),regionTitle,'FontWeight','bold');
                end
            end
    end
    
    %*************************IMPORTANTTTTTTTTTTTT*************************
    % What about boundary neurons? they also may have objects/patterns
    % associated with them, otherwise the total number of objects
    % represented in the regions may not match the same number of
    % objects in the dataset if you choose to ignore the borders.
    %**********************************************************************
    
    %get the objects thet are left behind
    rp = find(ismember(1:length(map.bmu),objectsFound) == 0);
           
    %pairwise distances among neurons
    d = map.Dcc;
        
    %neurons that are already assigned to a specific region
    assignedNeurons = find(neuron2region > 0);
           
    %for every remaning pattern assigned to a neuron located on the
    %boundary
    for p=1:length(rp)
        %find that neuron index 
        nid = object2neuron(rp(p));
                
        %find the closest neuron assigned to region
        [~,idx] = min(d(nid,assignedNeurons));
                
        %target region
        rid = neuron2region(assignedNeurons(idx));
                
        %add that object/pattern to the region
        region(rid).objects = [region(rid).objects rp(p)];
    end
end