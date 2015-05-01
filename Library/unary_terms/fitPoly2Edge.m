function fg_class = fitPoly2Edge(edgePts,edgeNbrs,nbr_depths)

p = polyfit(edgePts(:,1),edgePts(:,2),3);
num_nbrs = size(edgeNbrs,1);
x = edgeNbrs(:,1);
y = edgeNbrs(:,2);
A = [-x.^3 -x.^2 -x -ones(num_nbrs,1) y];
z = A*[p'; 1];
pos_class = z>0;
if(max(nbr_depths(pos_class))>max(nbr_depths(~pos_class)))
    fg_class = ~pos_class;
else
    fg_class = pos_class;
end

