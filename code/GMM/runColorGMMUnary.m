function color_unary = runColorGMMUnary(im, im_large, im_depth, loc)


mask = zeros(size(im_large, 1), size(im_large, 2));
mask(loc(1):loc(2), loc(3):loc(4)) = 1;

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

%% params
%K = 5;
%compactness = 0.5;
%addpath(genpath('/Users/zstufzxy/Desktop/Course/CS543/project/GMM-HMRF_v1'));
%
%k=2; % k: number of regions
%g=3; % g: number of GMM components
%beta=1; % beta: unitary vs. pairwise
%EM_iter=1; % max num of iterations
%MAP_iter=10; % max num of iterations
%
%
%% load sample image
%%<<<<<<< HEAD:code/runUnaryGMM.m
%
%%im = imread('apple_1_1_1_crop.png');
%%depth = imread('apple_1_1_1_depthcrop.png');
%%im_large = imread('apple_1_1_1.png');
%%loc = load('apple_1_1_1_loc.txt'); 
%%=======
%%im = imread('apple_1_1_1_crop.png');
%%depth = imread('apple_1_1_1_depthcrop.png');
%%>>>>>>> origin/tanmay:code/runColorGMMUnary.m
%
%% run slic
%%[cIndMap, time, imgVis] = slic(im, K, compactness);
%
%% pixel-wise color GMM
%%mex BoundMirrorExpand.cpp;
%%mex BoundMirrorShrink.cpp;
%
%Y=double(im);
%Y(:,:,1)=gaussianBlur(Y(:,:,1),3);
%Y(:,:,2)=gaussianBlur(Y(:,:,2),3);
%Y(:,:,3)=gaussianBlur(Y(:,:,3),3);
%
%Y_large=double(im_large);
%Y_large(:,:,1)=gaussianBlur(Y_large(:,:,1),3);
%Y_large(:,:,2)=gaussianBlur(Y_large(:,:,2),3);
%Y_large(:,:,3)=gaussianBlur(Y_large(:,:,3),3);
%
%tic;
%fprintf('Performing FG/BG segmentation\n');
%[X, GMM]=FG_estimate(Y,Y_large,g, loc);
%%imwrite(uint8(X*80),'initial labels.png');
%
%[color_unary, GMM]=HMRF_EM(X,Y_large,GMM,k,g,EM_iter,MAP_iter,beta);
%%imwrite(uint8(X*80),'final labels.png');
%toc;
%
%% pixel-wise 3D GMM
%end
%
%%>>>>>>> origin/tanmay:code/runColorGMMUnary.m
