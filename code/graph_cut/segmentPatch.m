function [im_seg, im_patch, label_full, cut_energy] = segmentPatch(im, ...
                                                      im_depth, im_edge, patch_coord, active_mask, pairwise_weight)


    	im_depth_ori = im_depth;
		
	im_depth_norm = im_depth - min(im_depth(:));
	im_depth_norm = im_depth_norm./max(im_depth_norm(:));

	im_patch = im(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_depth_patch = im_depth(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_edge_patch = im_edge(patch_coord(1):patch_coord(2),patch_coord(3):patch_coord(4), :);
	active_mask_patch = active_mask(patch_coord(1):patch_coord(2),patch_coord(3):patch_coord(4)) == 0;
	
	h = size(im_patch, 1); 
	w = size(im_patch, 2); 
	
	energy_color = runColorGMMUnary(im_patch, im, im_depth_norm, patch_coord, active_mask_patch,true);
    	energy_coor_patch = runCoorRFUnary(energy_color, im_depth_ori, patch_coord);
        
	energy_color_patch = energy_color(patch_coord(1):patch_coord(2), ...
                                          patch_coord(3):patch_coord(4));
        energy_color_patch = energy_color_patch.*double(active_mask_patch);

	dataCost = double(zeros(2, h*w));
	
	w_color = 1;
	w_coor = 1;
	
	dataCost(1, :) = (w_color).*(-log(energy_color_patch(:))) + (w_coor).*(-log(energy_coor_patch(:)));
	dataCost(2, :) = (w_color).*(-log(1-energy_color_patch(:))) + (w_coor).*(-log(1-energy_coor_patch(:)));
		
	%add pairwise terms
	m = 25;
	dim = 10;
	K = min(w/10, h/10).^2;
	%[sp_labels,  sp_centers, ~, ~] = slic_rgb(im_patch, K, m);
	[sp_labels,  sp_centers, ~, ~] = slic_rgbd(im_patch, im_depth_patch, K, m, 1);

	[uniformCost, sparseSmoothness] = ...
            createSmoothnessCost(im_depth_patch, im_edge_patch, sp_labels, sp_centers, active_mask_patch, pairwise_weight);

	%open a graph cut object
	[gch] = GraphCut('open', dataCost, uniformCost, sparseSmoothness);

	fgLabels = int32((1-energy_color_patch(:)) > energy_color_patch(:));

	%set initial labels
	[gch] = GraphCut('set', gch, fgLabels);

	%perform minimization
	[gch fgLabels] = GraphCut('expand', gch);

        %get energy
        [gch cut_energy] = GraphCut('energy', gch);

	fgLabels = reshape(fgLabels, size(im_patch, 1), size(im_patch, 2));
	
	% mask3D(:, :, 1) = double(fgLabels);
	% mask3D(:, :, 2) = double(fgLabels);
	% mask3D(:, :, 3) = double(fgLabels);

	label_full = zeros(size(im, 1), size(im, 2));
	label_full(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4)) = abs(1-fgLabels);
        im_seg = [];
        
	% blueImg = double(zeros(h, w, 3));
	% blueImg(:, :, 3) = 1;

	% im_seg = blueImg.*mask3D + im_patch.*abs(mask3D-1);
        
	% figure(1);
	% subplot(2,3,1),
	% imagesc(energy_color);
	% title('unary color cost');
%
%	subplot(2,3,2);
%	imagesc(vertCost); 
%	title('vertical cost');
%
%	subplot(2,3,3);
%	imagesc(horzCost); 
%	title('horz cost');
%	
%	%subplot(2,3,4),
%	%imagesc(energy_edge);
%	%title('energy edge');
%
%	subplot(2,3,5);
%	imshow(im_patch);
%	title('image patch');
%
%	subplot(2,3,6);
%	imshow(im_seg);
%	title('segmented image');
%	disp('Waiting..');	
%	k1 = waitforbuttonpress;
end

function [uniformCost, sparseSmoothness] = createSmoothnessCost(im_depth, ...
                                                      im_edge, sp_labels, sp_centers, active_mask, pairwise_weight)

	uniformCost = double(zeros(2, 2));
	uniformCost(1, 2) = 1;
	uniformCost(2, 1) = 1;

	width = size(im_depth, 2);
	height = size(im_depth, 1);

        
	w_depth = pairwise_weight;
	w_sp = pairwise_weight;
	w_edge = pairwise_weight;

	horzCost = double(zeros(size(im_depth, 1), size(im_depth, 2)));
	for j = [1:size(im_depth, 2)-1]
	        horzCost(:, j) = w_depth.*(exp(-1*(im_depth(:, j) - im_depth(:, j+1)).^2)) ... 
			       + w_edge.*(exp(-1*im_edge(:, j))) ... 
			       +  (exp(-1* mean((sp_centers(sp_labels(:,j),:) - sp_centers(sp_labels(:,j+1),:)).^2, 2))).*w_sp;
	end

	vertCost = double(zeros(size(im_depth, 1), size(im_depth, 2)));
	for j = [1:size(im_depth, 1)-1]
	       vertCost(j, :) = w_depth.*(exp(-1*(im_depth(j, :) - im_depth(j+1, :)).^2)) ... 
                               + w_edge.*(exp(-1*im_edge(j, :))) ... 
			       +  (exp(-1* mean((sp_centers(sp_labels(j,:),:) - sp_centers(sp_labels(j+1, :),:)).^2, 2)))'.*w_sp;
	end

	
	sparseSmoothness = sparse(width*height, width*height);

	ind = find(active_mask == 1);
	height = size(active_mask, 1);

	for id = [1:numel(ind)]
		i = mod(id-1, height) + 1;
		j = floor((id-1)/height) + 1;

		np1 = (j-1)*height + i;
		if(i-1 >= 1 & active_mask(i-1, j)) 
			np2 = np1 - 1;
			sparseSmoothness(np1, np2) = vertCost(i-1, j);
			sparseSmoothness(np2, np1) = vertCost(i-1, j);
		end

		if(i+1 <= height & active_mask(i+1, j)) 
			np2 = np1 + 1;
			sparseSmoothness(np1, np2) = vertCost(i, j);
			sparseSmoothness(np2, np1) = vertCost(i, j);
		end
		if(j-1 >= 1 & active_mask(i, j-1)) 
			np2 = np1 - height;
			sparseSmoothness(np1, np2) = horzCost(i, j-1);
			sparseSmoothness(np2, np1) = horzCost(i, j-1);
		end
		if(j+1 <= width & active_mask(i, j+1)) 
			np2 = np1 + height;
			sparseSmoothness(np1, np2) = horzCost(i, j);
			sparseSmoothness(np2, np1) = horzCost(i, j); 
		end	
	end

end

