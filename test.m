% test

alpha = 0.5;

im = imread('apple_1_1_1_crop.png');
depth = imread('apple_1_1_1_depthcrop.png');

im = im2double(im);
depth = double(depth);
depth = depth/100;

denoisedDepthImg = fill_depth_colorization(im, depth, alpha);
