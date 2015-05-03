function fgLabels = segmentPatch(im, im_depth, im_edge, edge_group, patch_coord)
	m = 25;
	im_patch = im(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_depth_patch = im_depth(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_edge_patch = im_edge(patch_coord(1):patch_coord(2),patch_coord(3):patch_coord(4), :);
	edge_group_patch = ...
	    edge_group(patch_coord(1):patch_coord(2), ...
			     patch_coord(3):patch_coord(4),1);


	%debug
	 figure(1);
	 imshow(im_patch); axis equal;
         % k1 = waitforbuttonpress;

	%figure(1);
	%imshow(im_edge_patch);
	%k1 = waitforbuttonpress;
	
	%figure(1);
	%imagesc(im_depth_patch);
	%k1 = waitforbuttonpress;

	%size(im_patch)
	%size(im_edge_patch)
	%size(im_depth_patch) 
	
	%add unary terms
	energy = unary_edge(im_patch, im_depth_patch, 'edges', ...
			    im_edge_patch, 'edge_group', ...
			    edge_group_patch, 'visualize', false);

	%[color_unary] = runColorGMMUnary(im_patch, im, im_depth, patch_coord);

	figure(2);
	imagesc(energy); axis equal;
	k1 = waitforbuttonpress;
	
	%add pairwise terms
	h = size(im_patch, 1); 
	w = size(im_patch, 2); 
	K = min(w/5, h/5).^2;
	[sp_labels,  ~, ~] = slic(im_patch, K, m);

	%[uniformCost, horzCost, vertCost] = createSmoothnessCost(im_depth_patch, im_edge_patch, sp_labels);

	%open a graph cut object
	%[gch] = GraphCut('open', unaryCost, uniformCost, vertCost, horzCost);

	%set initial labels
	%[gch] = GraphCut('set', gch, labels);

	%perform minimization
	%[gch labels] = GraphCut('expand', gch);

	fgLabels = [];
end

function [uniformCost, horzCost, vertCost] = createSmoothnessCost(im_depth, im_edge, sp_labels)
	uniformCost = double(zeros(2, 2));
	uniformCost(1, 2) = 1;
	uniformCost(2, 1) = 1;

	w_sp = 1;
	w_edge = 1;
	w_depth = 1;

	horzCost = double(zeros(size(im_depth, 1), size(im_depth, 2)));
	for j = [1:size(im_depth, 2)-1]
	        horzCost(:, j) = w_depth.*(exp(-1*(im_depth(:, j) - im_depth(:, j+1)).^2)) + w_edge.*(exp(-1*im_edge(:, j))) + double(sp_labels(:,j) == sp_labels(:, j+1)).*w_sp;   
	end

	vertCost = double(zeros(size(im_depth, 1), size(im_depth, 2)));
	for j = [1:size(im_depth, 1)-1]
	        vertCost(j, :) = w_depth.*(exp(-1*(im_depth(j, :) - im_depth(j+1, :)).^2)) + w_edge.*(exp(-1*im_edge(j, :))) + double(sp_labels(j, :) == sp_labels(j+1, :)).*w_sp;   
	end

end
