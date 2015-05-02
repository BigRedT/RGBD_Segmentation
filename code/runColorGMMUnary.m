function color_unary = runColorGMMUnary(im, im_depth, patch_coord)

% params
%K = 5;
%compactness = 0.5;
addpath(genpath('./third_party/GMM/GMM-HMRF_v1/GMM-HMRF_v1'));

k=2; % k: number of regions
g=3; % g: number of GMM components
beta=1; % beta: unitary vs. pairwise
EM_iter=10; % max num of iterations
MAP_iter=10; % max num of iterations


% load sample image
%im = imread('apple_1_1_1_crop.png');
%depth = imread('apple_1_1_1_depthcrop.png');

% run slic
%[cIndMap, time, imgVis] = slic(im, K, compactness);

% pixel-wise color GMM

Y=double(im);
Y(:,:,1)=gaussianBlur(Y(:,:,1),3);
Y(:,:,2)=gaussianBlur(Y(:,:,2),3);
Y(:,:,3)=gaussianBlur(Y(:,:,3),3);

tic;
fprintf('Performing k-means segmentation\n');
[X, GMM]=image_kmeans(Y,k,g);
%imwrite(uint8(X*80),'initial labels.png');

[color_unary, GMM]=HMRF_EM(X,Y,GMM,k,g,EM_iter,MAP_iter,beta);
%imwrite(uint8(X*80),'final labels.png');
toc;

% pixel-wise 3D GMM
end

