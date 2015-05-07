%top-level script

matlabSearchPath;

rootDir = fullfile(pwd,'../');

%change path of dataset for vision-cluster
[~, host] = system('hostname');
if(~isempty(strfind(host, 'vision')))
  disp('vision node')
  rootDir = '/shared/daf/dataset_rgbd/';
end

%I = im2double(imread([rootDir 'dataset/rgbd-uncropped-dataset/apple/apple_1/apple_1_1_1.png']));
I = im2double(imread([rootDir 'dataset/rgbd-scenes/table/table_1/table_1_30.png']));

%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/ball/ball_1/ball_1_1_1.png']);
%I = im2double(imread([rootDir 'dataset/rgbd-uncropped-dataset/bowl/bowl_1/bowl_1_1_1.png']));
%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/cell_phone/cell_phone_1/cell_phone_1_1_1.png']);

%can read depth image with
%I_depth = imread([rootDir 'dataset/rgbd-uncropped-dataset/bowl/bowl_1/bowl_1_1_1_depth.png']);
%I_depth = imread([rootDir 'dataset/rgbd-uncropped-dataset/apple/apple_1/apple_1_1_1_depth.png']);
I_depth = im2double(imread([rootDir 'dataset/rgbd-scenes/table/table_1/table_1_30_depth.png']));

%smooth the depth
I_depth = double(I_depth);
I_depth = I_depth/100;
alpha = 0.5;
I_depth = fill_depth_colorization(im2double(I), I_depth, alpha);
I_depth = I_depth.*100;

save('depth.mat', 'I_depth');
%load('depth.mat');
disp(['Done depth smoothing']);

params = struct(...
'num_regions', 6, ...
'score_threshold_num', 25, ...
'iou_threshold', 0.7 ...
);

tic;
[regions, edges, edge_group] = generate_region_proposals(I, params, false);
active_mask = zeros(size(I, 1), size(I, 2));
regions = [regions, regions(:,3).*regions(:,4)];
regions = sortrows(regions, [8 -5]);
for i = [1:size(regions, 1)]
	disp(['Processing Region# ' num2str(i)]);
	currRegion = regions(i, :);
	[im_seg, im_patch, labels] = segmentPatch(I, I_depth, edges, edge_group, [currRegion(2), currRegion(7), currRegion(1), currRegion(6)], active_mask);
	active_mask = active_mask + i.*labels;
	imwrite(im_seg, ['results/' num2str(i) '_seg.png']);
	imwrite(im_patch, ['results/' num2str(i) '_patch.png']);
end

save('results/fg_labels.mat', 'active_mask');

toc;
