%top-level script

matlabSearchPath;

rootDir = '/home/ardeshp2/cs543_project/RGBD_Segmentation/';

I = imread([rootDir 'dataset/rgbd-uncropped-dataset/apple/apple_1/apple_1_1_1.png']);
%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/ball/ball_1/ball_1_1_1.png']);
%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/bowl/bowl_1/bowl_1_1_1.png']);
%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/cell_phone/cell_phone_1/cell_phone_1_1_1.png']);

%can read depth image with
%I_depth = imread([rootDir 'dataset/rgbd-uncropped-dataset/bowl/bowl_1/bowl_1_1_1_depth.png']);
I_depth = imread([rootDir 'dataset/rgbd-uncropped-dataset/apple/apple_1/apple_1_1_1_depth.png']);

params = struct(...
'num_regions', 10, ...
'score_threshold_num', 25, ...
'iou_threshold', 0.7 ...
);

[regions, edges] = generate_region_proposals(I, params, false);

regions = [regions, regions(:,3).*regions(:,4)];
regions = sortrows(regions, [8 -5]);

for i = [1:size(regions, 1)]
	currRegion = regions(i, :);
	fgLabels = segmentPatch(I, I_depth, edges, [currRegion(2), currRegion(7), currRegion(1), currRegion(6)]);
end
