function vistrn(V,data)
V = V';
% ploting neurons in data sapce
grd=fullfact([11,6])'-1;
[xcord,ycord]=find(triu(linkdist(grd))==1);
figure(5)
plot(data(:,1),data(:,2),'.','markersize',12)
hold on
plot(V(1,:),V(2,:),'.r','markersize',18,'markerfacecolor','r')
for ii=1:length(xcord)
    line([V(1,xcord(ii)),V(1,ycord(ii))],[V(2,xcord(ii)),V(2,ycord(ii))],'Color','r');
end
axis equal
hold off

drawnow

