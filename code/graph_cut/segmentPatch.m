function [im_seg, im_patch] = segmentPatch(im, im_depth, im_edge, edge_group, patch_coord)

	m = 25;
    
    im_seg = [];
	
    im_depth_ori = im_depth;
	im_depth = im_depth - min(im_depth(:));
	im_depth = im_depth./max(im_depth(:));

	im_patch = im(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_depth_patch = im_depth(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_edge_patch = im_edge(patch_coord(1):patch_coord(2),patch_coord(3):patch_coord(4), :);
	
	h = size(im_patch, 1); 
	w = size(im_patch, 2); 
	
	edge_group_patch = ...
	    edge_group(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), 1);


	%debug
	 %figure(1);
	 %imshow(im_patch); axis equal;


	%figure(1);
	%imshow(im_edge_patch);
	%k1 = waitforbuttonpress;
	
	%figure(1);
	%imagesc(im_depth_patch), colormap gray;
	%k1 = waitforbuttonpress;

	%size(im_patch)
	%size(im_edge_patch)
	%size(im_depth_patch) 
	
	%add unary terms

	%energy_edge =  unary_edge(im_patch, im_depth_patch, 'edges', ...
 	%		    im_edge_patch, 'edge_group', ...
    %			    edge_group_patch, 'visualize', false);

	energy_color = runColorGMMUnary(im_patch, im, im_depth, patch_coord);

    energy_coor = runCoorRFUnary(energy_color, im_depth_ori, patch_coord);
    
    return;

 	dataCost = double(zeros(h, w, 4));
	
	w_edge = -1;
	w_color = -1;
    w_coor = -1;
	dataCost(:, :, 1) = (w_color).*(log(energy_color));
	dataCost(:, :, 2) = (w_color).*(log(1-energy_color));
    dataCost(:, :, 3) = (w_coor).*(log(energy_coor));
	dataCost(:, :, 4) = (w_coor).*(log(1-energy_coor));

	%add pairwise terms
	K = min(w/5, h/5).^2;
	[sp_labels,  ~, ~] = slic(im_patch, K, m);
	[uniformCost, horzCost, vertCost] = createSmoothnessCost(im_depth_patch, im_edge_patch, sp_labels);

	%open a graph cut object
	[gch] = GraphCut('open', dataCost, uniformCost, vertCost, horzCost);

	fgLabels = int32((1-energy_color) > energy_color);

	%set initial labels
	[gch] = GraphCut('set', gch, fgLabels);

	%perform minimization
	[gch fgLabels] = GraphCut('expand', gch);

	mask3D(:, :, 1) = double(fgLabels);
	mask3D(:, :, 2) = double(fgLabels);
	mask3D(:, :, 3) = double(fgLabels);

	blueImg = double(zeros(h, w, 3));
	blueImg(:, :, 3) = 1;

	im_seg = blueImg.*mask3D + im_patch.*abs(mask3D-1);
    
    figure(1);
    subplot(2,3,1),
    imagesc(energy_color);
	title('unary color cost');
    
    subplot(2,3,2);
   	imagesc(vertCost); 
	title('vertical cost');

	subplot(2,3,3);
	imagesc(horzCost); 
	title('horz cost');
    
    subplot(2,3,4),
    imagesc(energy_edge);
    title('energy edge');
    
    subplot(2,3,5);
    imshow(im_patch);
    title('image patch');
    
    subplot(2,3,6);
    imshow(im_seg);
    title('segmented image');
	disp('Waiting..');	
	k1 = waitforbuttonpress;
	%figure(1);
	%imshow(segImg);
	%k1 = waitforbuttonpress;
end

function [uniformCost, horzCost, vertCost] = createSmoothnessCost(im_depth, im_edge, sp_labels)
	uniformCost = double(zeros(2, 2));
	uniformCost(1, 2) = 1;
	uniformCost(2, 1) = 1;

	w_sp = 1;
	dc_off_sp = 1;
	w_edge = 1;
	w_depth = 1;

	horzCost = double(zeros(size(im_depth, 1), size(im_depth, 2)));
	for j = [1:size(im_depth, 2)-1]
	        horzCost(:, j) = w_depth.*(exp(-1*(im_depth(:, j) - im_depth(:, j+1)).^2)) + w_edge.*(exp(-1*im_edge(:, j))) + (double(sp_labels(:,j) == sp_labels(:, j+1))+dc_off_sp).*w_sp;   
	end

	vertCost = double(zeros(size(im_depth, 1), size(im_depth, 2)));
	for j = [1:size(im_depth, 1)-1]
	        vertCost(j, :) = w_depth.*(exp(-1*(im_depth(j, :) - im_depth(j+1, :)).^2)) + w_edge.*(exp(-1*im_edge(j, :))) + double(sp_labels(j, :) == sp_labels(j+1, :)).*w_sp;   
	end

	

end
