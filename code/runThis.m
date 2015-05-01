%top-level script

rootDir = '/home/ardeshp2/cs543_project/RGBD_Segmentation/';

%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/apple/apple_1/apple_1_1_1.png']);
I = imread([rootDir 'dataset/rgbd-uncropped-dataset/ball/ball_1/ball_1_1_1.png']);
%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/bowl/bowl_1/bowl_1_1_1.png']);
%I = imread([rootDir 'dataset/rgbd-uncropped-dataset/cell_phone/cell_phone_1/cell_phone_1_1_1.png']);

%can read depth image with
%I_depth = imread([rootDir 'dataset/rgbd-uncropped-dataset/bowl/bowl_1/bowl_1_1_1_depth.png']);

params = struct(...
'num_regions', 10, ...
'score_threshold_num', 25, ...
'iou_threshold', 0.7 ...
);

regions = generate_region_proposals(I, params, true);
