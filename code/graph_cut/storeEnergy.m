function [X, Y] = storeEnergy(im, im_depth, patch_coord, active_mask, trueMask)

	record_energy = {};

	im_depth = im_depth - min(im_depth(:));
	im_depth = im_depth./max(im_depth(:));

	im_patch = im(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	im_depth_patch = im_depth(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4), :);
	active_mask_patch = active_mask(patch_coord(1):patch_coord(2),patch_coord(3):patch_coord(4));
	
	h = size(im_patch, 1); 
	w = size(im_patch, 2); 
	
	energy_color = runColorGMMUnary(im_patch, im, im_depth, patch_coord, active_mask_patch);
    	energy_coor = runCoorRFUnary(energy_color, im_depth_ori, patch_coord);
    
	energy_color_patch = energy_color(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4));
	energy_coor_patch = energy_coor(patch_coord(1):patch_coord(2), patch_coord(3):patch_coord(4));
 	
	X = [energy_color_patch(:), energy_coor_patch(:)]
	Y = trueMask(:);

end


