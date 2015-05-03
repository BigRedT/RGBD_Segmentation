% test

alpha = 0.5;

im = im2double(imread('./dataset/rgbd-uncropped-dataset/apple/apple_1/apple_1_1_1.png'));
im_crop = im2double(imread('./dataset/rgbd-cropped-dataset/apple/apple_1/apple_1_1_1_crop.png'));

I = im;

mask = zeros(size(I, 1), size(I, 2));
r = 212;
c = 272;

figure(1);
imshow(I(r:r+size(im_crop,1), c:c+size(im_crop,2),:));
k = waitforbuttonpress;

mask(r:r+size(im_crop,1), c:c+size(im_crop,2)) = 1;

K = 5; %number of gaussians in GMMs

nPix = size(I, 1)*size(I, 2); 

ind_fg = find(mask == 1);
X_fg = [I(ind_fg) I(ind_fg + nPix) I(ind_fg + 2*nPix)];
n_fg = size(X_fg, 1); 
gmm_fg = fitgmdist(X_fg, K, 'CovarianceType', 'diagonal');

ind_bg = find(mask == 0);
X_bg = [I(ind_bg) I(ind_bg + nPix) I(ind_bg + 2*nPix)];
n_bg = size(X_bg, 1);
gmm_bg = fitgmdist(X_bg, K, 'CovarianceType', 'diagonal');

Iflat = [reshape(I(:, :, 1), 1, [])' reshape(I(:, :, 2), 1, [])' reshape(I(:, :, 3), 1, [])'];
p_x_fg = pdf(gmm_fg, Iflat).*(n_fg/nPix);
p_x_bg = pdf(gmm_bg, Iflat).*(n_bg/nPix);

p_fg_x = p_x_fg./(p_x_fg + p_x_bg);
p_bg_x = p_x_bg./(p_x_fg + p_x_bg);

img_p_fg_x = reshape(p_fg_x, size(I, 1), size(I, 2));
img_p_bg_x = reshape(p_bg_x, size(I, 1), size(I, 2));

figure(1);
imagesc(img_p_fg_x(r:r+size(im_crop,1), c:c+size(im_crop,2)));
title('Likelihood that pixel is foreground');
imwrite(img_p_fg_x, 'foreground-likelihood.png', 'PNG');


%im = im2double(im);
%depth = double(depth);
%depth = depth/100;

%denoisedDepthImg = fill_depth_colorization(im, depth, alpha);
