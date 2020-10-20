function coords = node_coords(mapdim)
%%
% Given a map with dimension mapdim compute a c x 2 matrix, where every row
% corresponds to the coordinates of every neuron, where c is the number of
% neurons in the map

    coords = zeros(prod(mapdim),2);
    coords(:,1) = repmat([0:mapdim(1)-1]',mapdim(2),1);
    startpos = 1;
    
    for j=0:mapdim(2)-1
        coords(startpos:startpos+mapdim(1)-1,2) = j * ones(mapdim(1),1);
        startpos = startpos + mapdim(1);
    end
    
    coords = fliplr(coords(:,[1 2]));
    
    inds_for_row = (cumsum(ones(mapdim(2),1))-1)*mapdim(1); 
    for i=2:2:mapdim(1), 
        coords(i+inds_for_row,1) = coords(i+inds_for_row,1); 
    end
end