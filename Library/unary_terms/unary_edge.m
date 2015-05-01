function unary_edge(im_rgb,im_depth,varargin)
p = inputParser;
addOptional(p,'minEdgeLen',3);
addOptional(p,'visualize',false);
parse(p,varargin{:});
args = p.Results;

[h,w,~] = size(im_rgb);

% Find edges
[edge_mag, edge_orient] = coloredges(im_rgb);
neg_slope_mask = edge_orient < 0 ;
edge_orient(neg_slope_mask) = pi + edge_orient(neg_slope_mask);
edges = nonmax(edge_mag,edge_orient);
bw = edges > 0;

% Find connected components and reject small edges
labels = bwlabel(bw);
num_edges = numel(unique(labels(:))) - 1;
for i=1:num_edges
    lin_edge_idx = find(labels==i);
    if(numel(lin_edge_idx)<args.minEdgeLen)
        bw(lin_edge_idx) = 0;
    end
end
labels = bwlabel(bw);
num_edges = numel(unique(labels(:))) - 1;

% Find distance to nearest edges
DTs = zeros(h,w,num_edges);
for i=1:num_edges
    DTs(:,:,i) = bwdist(labels==i);
end
[dist2edges,edge_assignments] = sort(DTs,3);

% Classify pixels based on which side of the edge they lie on
pos_points_cell = cell(num_edges,1);
neg_points_cell = cell(num_edges,1);
energy = zeros(h,w);
for i=1:num_edges
    lin_idx = find(edge_assignments(:,:,1)==i);
    [I,J] = ind2sub([h,w],lin_idx);
    depth = double(im_depth(lin_idx));
    edge_lin_idx = find(labels==i);
    [edgePtsI,edgePtsJ] = ind2sub([h,w],edge_lin_idx);
    fg_idx = fitPoly2Edge([edgePtsI edgePtsJ],[I J],depth);
    pos_points_cell{i} = [I(fg_idx),J(fg_idx)];
    neg_points_cell{i} = [I(~fg_idx),J(~fg_idx)];
    energy(I(fg_idx),J(fg_idx)) = DTs(I(fg_idx),J(fg_idx),i);
    energy(I(~fg_idx),J(~fg_idx)) = -DTs(I(~fg_idx),J(~fg_idx),i);
end
figure, imagesc(energy); colormap(gray);
pos_points = cell2mat(pos_points_cell);
neg_points = cell2mat(neg_points_cell);

if(args.visualize)
    plot(pos_points(:,2),h-pos_points(:,1)+1,'r.');
    hold on;
    plot(neg_points(:,2),h-neg_points(:,1)+1,'b+');
    lin_edge_idx = find(bw);
    [edge_I,edge_J] = ind2sub([h,w],lin_edge_idx);
    plot(edge_J,h-edge_I+1,'k*');
    hold off;
end
