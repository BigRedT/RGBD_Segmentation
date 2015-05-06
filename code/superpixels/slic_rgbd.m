function [cIndMap, time, imgVis] = slic_rgbd(img, depth, K, compactness, depth_weight)

%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - img: input color image
%   - depth: input normalized depth
%   - K:   number of clusters
%   - compactness: the weighting for compactness
% Output: 
%   - cIndMap: a map of type uint16 storing the cluster memberships
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

tic;
% Put your SLIC implementation here
warning off;

img = im2double(img);
depth = depth_weight*depth;
%compute gradient magnitude
[gmag3d(:, :, 1), ~] = imgradient(img(:, :, 1));
[gmag3d(:, :, 2), ~] = imgradient(img(:, :, 2));
[gmag3d(:, :, 3), ~] = imgradient(img(:, :, 3));
% [gmag3d(:, :, 4), ~] = imgradient(depth);
gmag = sqrt(sum(gmag3d.^2, 3))/3;

rgbImg = img;

%convert RGB to CIE-Lab color space
img = rgb2lab(img); 

width = size(img, 2);
height = size(img, 1);
N = width*height;
S = sqrt((N-2)/K);

%generate the xy-cordinates for feature vector
[col, row] = meshgrid([1:width], [1:height]);

%initialize labels and distance for pixel
label = (width*height+100).*ones(size(img, 1), size(img, 2), 'uint16');
dist = 10^9.*double(ones(size(img, 1), size(img, 2)));

%initialize cluster centers
centers(:, :, 1:3) = img(2:S:end-1, 2:S:end-1, :);
centers(:, :, 4) = row(2:S:end-1, 2:S:end-1);
centers(:, :, 5) = col(2:S:end-1, 2:S:end-1);
centers(:, :, 6) = depth(2:S:end-1, 2:S:end-1, :);

%move cluster centers to lowest gradient position
h_c = size(centers, 1);
w_c = size(centers, 2);

for i = [1:h_c]
	for j = [1:w_c]
		x = centers(i, j, 4);
		y = centers(i, j, 5);
		centers_patch(:, :, 1:3) = img(x-1:x+1, y-1:y+1, :);
		centers_patch(:, :, 4) = row(x-1:x+1, y-1:y+1);
		centers_patch(:, :, 5) = col(x-1:x+1, y-1:y+1);
                centers_patch(:, :, 6) = depth(x-1:x+1, y-1:y+1, :);
		gmag_patch = gmag(x-1:x+1, y-1:y+1);
		ordfilt_out = ordfilt2(gmag_patch, 1, ones(3, 3), 'zeros');
		ind_min = find(gmag_patch == ordfilt_out(2,2));
		centers(i, j, :) = centers_patch(mod(ind_min(1)-1, 3)+1, floor((ind_min(1)-1)/3)+1, :);
	end
end 



%perform kmeans iterative clustering procedure
%till convergence or itr = [1:10]
for iterations = [1:10]

	for i = [1:h_c]
		for j = [1:w_c]
			x = uint32(round(centers(i, j, 4)));
			y = uint32(round(centers(i, j, 5)));
			
			%create a patch around cluster center of size [2Sx2S]
			xmin = x-S+1;
			xmax = x+S;
			ymin = y-S+1;
			ymax = y+S;

			if(xmin < 1)      xmin = 1; end
			if(xmax > height) xmax = height; end
			if(ymin < 1) 		ymin = 1; end
			if(ymax > width)  ymax = width; end

			feature_patch = [];
			dist_patch = [];
			label_patch = [];
			update_label_patch = [];
			update_dist_patch = [];
			mask_patch = [];
			dc = [];
			ds = [];
			D = [];
			
			feature_patch(:, :, 1:3) = img(xmin:xmax, ymin:ymax, :);
			feature_patch(:, :, 4) = row(xmin:xmax, ymin:ymax);
			feature_patch(:, :, 5) = col(xmin:xmax, ymin:ymax);
			feature_patch(:, :, 6) = depth(xmin:xmax, ymin:ymax);
			dist_patch = dist(xmin:xmax, ymin:ymax);
			label_patch = label(xmin:xmax, ymin:ymax);

			%compute distances
			dc = sqrt((feature_patch(:, :, 1) - centers(i, j, 1)).^2 + ...
                                  (feature_patch(:, :, 2) - centers(i, j, 2)).^2 + ...
                                  (feature_patch(:, :, 3) - centers(i, j, 3)).^2);
                                  
			ds = sqrt((feature_patch(:, :, 4) - centers(i, j, 4)).^2 + ...
                                  (feature_patch(:, :, 5) - centers(i, j, 5)).^2 + ...
                                  (feature_patch(:, :, 6) - centers(i, j, 6)).^2);
			D = sqrt((dc.^2) + (((compactness^2)/(S^2)).*(ds.^2)));
			%update the membership and min distance
			mask_patch = D < dist_patch;
			
			update_dist_patch = double(dist_patch).*double(abs(mask_patch-1)) + double(D).*double(mask_patch);
			update_label_patch = label_patch.*uint16(abs(mask_patch-1)) + uint16(((j-1)*h_c + i).*mask_patch);

			dist(xmin:xmax, ymin:ymax) = update_dist_patch;
			label(xmin:xmax, ymin:ymax) = update_label_patch;
		end
	end

	%update cluster centers based on new membership
	for i = [1:h_c]
		for j = [1:w_c]
			cid = (j-1)*h_c + i;
			memb_id = find(label == cid);

			newlab = reshape(img, [], 3);
			centers(i, j, 1:3) = sum(newlab(memb_id, :), 1)./numel(memb_id);

			newx = reshape(row, [], 1);
			centers(i, j, 4) = sum(newx(memb_id), 1)/numel(memb_id);

			newy = reshape(col, [], 1);
			centers(i, j, 5) = sum(newy(memb_id), 1)/numel(memb_id);

                        newdepth = reshape(depth, [], 1);
                        centers(i, j, 6) = sum(newdepth(memb_id),1)/numel(memb_id);
		end
	end

end
	
cIndMap = label;
[cInd_gx, cInd_gy] = imgradient(cIndMap);
cInd_g = cInd_gx.^2 + cInd_gy.^2;
mask = cInd_g > 0;

imgVis(:, :, 1) = rgbImg(:, :, 1).*double(abs(mask-1)) + double(mask);
imgVis(:, :, 2) = rgbImg(:, :, 2).*double(abs(mask-1)) + double(mask);
imgVis(:, :, 3) = rgbImg(:, :, 3).*double(abs(mask-1)) + double(mask);

time = toc;

end

