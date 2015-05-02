function energy = unary_edge(im_rgb,im_depth,varargin)
p = inputParser;
addOptional(p,'minEdgeLen',3);
addOptional(p,'visualize',true);
addOptional(p,'edges',[]);
parse(p,varargin{:});
args = p.Results;

[h,w,~] = size(im_rgb);

% Find edges
if(isempty(args.edges))
	[edge_mag, edge_orient] = coloredges(im_rgb);
	neg_slope_mask = edge_orient < 0 ;
	edge_orient(neg_slope_mask) = pi + edge_orient(neg_slope_mask);
	edges = nonmax(edge_mag,edge_orient);
	bw = edges > 0;
else
	bw = args.edges > 0.1;
end

% Find connected components and reject small edges
labels = bwlabel(bw);
num_edges = numel(unique(labels(:))) - 1;
for i=1:num_edges
    lin_edge_idx = find(labels==i);
    if(numel(lin_edge_idx)<args.minEdgeLen+1)
        bw(lin_edge_idx) = 0;
    end
    bw(1:h,1) = 0;
    bw(1:h,w) = 0;
    bw(1,1:w) = 0;
    bw(h,1:w) = 0;
end

labels = bwlabel(bw);
num_edges = numel(unique(labels(:))) - 1;
edgeProperties.length = zeros(num_edges,1);
for i=1:num_edges
    lin_edge_idx = find(labels==i);
    edgeProperties.length(i) = numel(lin_edge_idx);
end
minLength = min(edgeProperties.length);
maxLength = max(edgeProperties.length);
edgeProperties.length = (edgeProperties.length - minLength) / (maxLength - minLength);

% Find distance to nearest edges
DTs = zeros(h,w,num_edges);
for i=1:num_edges
    DTs(:,:,i) = bwdist(labels==i);
end
DTs = DTs/norm([h,w],2);
[dist2edges,edge_assignments] = sort(DTs,3,'ascend');

% Classify pixels based on which side of the edge they lie on
pos_points_cell = cell(num_edges,1);
neg_points_cell = cell(num_edges,1);
K = min(10, numel(unique(labels(:)))-1);
weights = exp(-0.5*[1:K]);
weights = weights/sum(weights);
energy = zeros(h,w);
for k=1:K
    for i=1:num_edges
        lin_idx = find(edge_assignments(:,:,k)==i);
        [I,J] = ind2sub([h,w],lin_idx);
        depth = double(im_depth(lin_idx));
        edge_lin_idx = find(labels==i);
        [edgePtsI,edgePtsJ] = ind2sub([h,w],edge_lin_idx);
        fg_idx = fitPoly2Edge([edgePtsI edgePtsJ],[I J],depth);
        pos_points_cell{i} = [I(fg_idx),J(fg_idx)];
        neg_points_cell{i} = [I(~fg_idx),J(~fg_idx)];
        lin_update_idx = sub2ind([h,w],I(fg_idx),J(fg_idx));
        DT_tmp = DTs(:,:,i);
        energy(lin_update_idx) = energy(lin_update_idx) + weights(k)*exp(2*edgeProperties.length(i))*DT_tmp(lin_update_idx);
        if(args.visualize)
            figure(1),imagesc(energy);
        end
    end
end
% figure, imagesc(energy); colormap(gray);
pos_points = cell2mat(pos_points_cell);
neg_points = cell2mat(neg_points_cell);

if(args.visualize)
    figure(2),imagesc(bw);
end
