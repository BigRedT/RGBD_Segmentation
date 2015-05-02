function color_unary = runColorGMMUnary(im, im_depth, patch_coord)

% params
K = 5;
compactness = 0.5;
addpath(genpath('/Users/zstufzxy/Desktop/Course/CS543/project/GMM-HMRF_v1'));

k=2; % k: number of regions
g=3; % g: number of GMM components
beta=1; % beta: unitary vs. pairwise
EM_iter=1; % max num of iterations
MAP_iter=10; % max num of iterations


% load sample image
<<<<<<< HEAD:code/runUnaryGMM.m

im = imread('apple_1_1_1_crop.png');
depth = imread('apple_1_1_1_depthcrop.png');
im_large = imread('apple_1_1_1.png');
loc = load('apple_1_1_1_loc.txt'); 
=======
%im = imread('apple_1_1_1_crop.png');
%depth = imread('apple_1_1_1_depthcrop.png');
>>>>>>> origin/tanmay:code/runColorGMMUnary.m

% run slic
%[cIndMap, time, imgVis] = slic(im, K, compactness);

% pixel-wise color GMM
%mex BoundMirrorExpand.cpp;
%mex BoundMirrorShrink.cpp;

Y=double(im);
Y(:,:,1)=gaussianBlur(Y(:,:,1),3);
Y(:,:,2)=gaussianBlur(Y(:,:,2),3);
Y(:,:,3)=gaussianBlur(Y(:,:,3),3);

Y_large=double(im_large);
Y_large(:,:,1)=gaussianBlur(Y_large(:,:,1),3);
Y_large(:,:,2)=gaussianBlur(Y_large(:,:,2),3);
Y_large(:,:,3)=gaussianBlur(Y_large(:,:,3),3);

tic;
<<<<<<< HEAD:code/runUnaryGMM.m
fprintf('Performing FG/BG segmentation\n');
%[X GMM]=image_kmeans(Y,k,g);
[X, GMM]=FG_estimate(Y,Y_large,g, loc);
imwrite(uint8(X*80),'initial labels.png');

[X, GMM]=HMRF_EM(X,Y_large,GMM,k,g,EM_iter,MAP_iter,beta);
imwrite(uint8(X*80),'final labels.png');
toc;
=======
fprintf('Performing k-means segmentation\n');
[X, GMM]=image_kmeans(Y,k,g);
%imwrite(uint8(X*80),'initial labels.png');

[color_unary, GMM]=HMRF_EM(X,Y,GMM,k,g,EM_iter,MAP_iter,beta);
%imwrite(uint8(X*80),'final labels.png');
toc;

% pixel-wise 3D GMM
end

>>>>>>> origin/tanmay:code/runColorGMMUnary.m
