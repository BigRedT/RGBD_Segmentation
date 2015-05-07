function color_unary = runColorGMMUnary(im, im_large, im_depth, loc, active_mask)


mask = zeros(size(im_large, 1), size(im_large, 2));
mask(loc(1):loc(2), loc(3):loc(4)) = active_mask;

I = cat(3, rgb2lab(im_large), im_depth);

%figure(1);
%imshow(I(loc(1):loc(2), loc(3):loc(4),:));
%k = waitforbuttonpress;

K = 5; %number of gaussians in GMMs

nPix = size(I, 1)*size(I, 2); 

ind_fg = find(mask == 1);
X_fg = [I(ind_fg) I(ind_fg + nPix) I(ind_fg + 2*nPix) I(ind_fg + 3*nPix)];
n_fg = size(X_fg, 1); 
gmm_fg = fitgmdist(X_fg, K, 'CovarianceType', 'diagonal', 'SharedCovariance', true);

ind_bg = find(mask == 0);
X_bg = [I(ind_bg) I(ind_bg + nPix) I(ind_bg + 2*nPix) I(ind_bg + 3*nPix)];
n_bg = size(X_bg, 1);
gmm_bg = fitgmdist(X_bg, K, 'CovarianceType', 'diagonal', 'SharedCovariance', true);

Iflat = [reshape(I(:, :, 1), 1, [])' reshape(I(:, :, 2), 1, [])' reshape(I(:, :, 3), 1, [])' reshape(I(:, :, 4), 1, [])'];
p_x_fg = pdf(gmm_fg, Iflat).*(n_fg/nPix);
p_x_bg = pdf(gmm_bg, Iflat).*(n_bg/nPix);

p_fg_x = p_x_fg./(p_x_fg + p_x_bg);
p_bg_x = p_x_bg./(p_x_fg + p_x_bg);

img_p_fg_x = reshape(p_fg_x, size(I, 1), size(I, 2));
img_p_bg_x = reshape(p_bg_x, size(I, 1), size(I, 2));


%figure(1);
%imagesc(img_p_fg_x(r:r+size(im_crop,1), c:c+size(im_crop,2)));
%title('Likelihood that pixel is foreground');

color_unary = img_p_fg_x;%(loc(1):loc(2), loc(3):loc(4)); 


