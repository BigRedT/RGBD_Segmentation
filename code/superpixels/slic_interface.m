function [cIndMap, imgVis, undersegError, undersegErrorSLIC] = ...
    slic_interface(img, depth, mask, varargin)

p = inputParser;
expected_type = {'rgb', 'rgbd'};
addOptional(p,'type', 'rgbd', @(x) any(validatestring(x,expected_type)));
parse(p,varargin{:});
args = p.Results;

depth = double(depth);
[h,w] = size(depth);

desired_superpixel_size = 0.1*(h+w)/2;
K = h*w/desired_superpixel_size.^2;
compactness = 25;
depth_weight = 1;

if(strcmp(args.type,'rgb'))
    cIndMap = slic_rgb(img, K, compactness);
elseif(strcmp(args.type,'rgbd'))
    cIndMap = slic_rgbd(img, depth, K, compactness, depth_weight);
end

[undersegError, ~,  undersegErrorSLIC] = ...
    getUndersegmentationError(cIndMap, mask);
