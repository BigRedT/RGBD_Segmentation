function fgLabels = segmentPatch(im, im_depth, im_edge, patch_coord)
	m = 25;
	im_patch = im(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);

	h = size(im_patch, 1); 
	w = size(im_patch, 2); 
	K = min(w/5, h/5).^2;
	[labels,  ~, ~] = slic(im_patch, K, m);

	%add unary terms

end
