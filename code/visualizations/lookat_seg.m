function imgVis = lookat_seg(img, active_mask, bbox, display_flag)

mask = active_mask > 0;
img = im2double(img);

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

R = r;
G = g;
B = b;

R(~mask) = 1;
R(mask) = 0;
B(~mask) = 0;
G(~mask) = 0;
B(mask) = 1;
num_levels = numel(bbox);
for i=1:num_levels
    level_mask = active_mask==i;
    G(level_mask) = i/num_levels;
end

imgVis(:,:,1) = R;
imgVis(:,:,2) = G;
imgVis(:,:,3) = B;

if(display_flag)
    imshow(imgVis);
end

end
