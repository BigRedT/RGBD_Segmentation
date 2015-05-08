function run_inference(out_dir,depth_flag)
data_dir = '/home/tanmay/Documents/CS543/dataset/rgbd-scenes/';
depth_dir = '/home/tanmay/Documents/CS543/dataset/rgbd_scenes_filled_depth/test';
file_list_path = fullfile(data_dir,'test_set.mat');
load(file_list_path);
file_list = test_set;

num_files = numel(file_list);
file_list_cell = mat2cell(file_list,ones(1,num_files),1);


parfor i=1:num_files
   [active_mask{i} bbox{i}] = heirarchicalSeg(data_dir,depth_dir,file_list_cell{i},i,out_dir,depth_flag);
end

end

function [active_mask bbox]= heirarchicalSeg(data_dir,depth_dir,file_data, ...
                                             idx, out_dir, depth_flag)
% Read images
full_img = im2double(imread(fullfile(data_dir,file_data.img)));
load(fullfile(depth_dir, [num2str(idx) '.mat']));
full_depth = filled_depth;
[h,w,~] = size(full_img);
active_mask = zeros(h,w);

% Get region proposal
params_edgeBoxes = struct(...
'num_regions', 5, ...
'score_threshold_num', 25, ...
'iou_threshold', 0.7 ...
);

[regions, edges_img, ~] = generate_region_proposals(full_img, params_edgeBoxes, false);

% Rank by area
regions = [regions, regions(:,3).*regions(:,4)];
regions = sortrows(regions, [8 -5]);

% Segment heirarchically
num_regions = size(regions,1);
bbox = [];
for i=1:num_regions
    currRegion = regions(i,:);
    r1 = currRegion(2);
    r2 = currRegion(7);
    c1 = currRegion(1);
    c2 = currRegion(6);
    
    patch_coord = [r1 r2 c1 c2];
        
    % Run segmentation
    if(depth_flag)
        [~, ~, labels, cut_energy] = segmentPatch(full_img, full_depth, ...
                                                  edges_img, patch_coord, active_mask);
    else
        [~, ~, labels, cut_energy] = segmentPatch_rgb(full_img,edges_img, ...
                                                      patch_coord, active_mask);
    end
    active_mask = active_mask + i.*labels;

    bbox(i).coord = patch_coord;
    bbox(i).area = currRegion(8);
    bbox(i).energy = cut_energy;
end

save(fullfile(out_dir,['seg_' num2str(idx) '.mat']),'active_mask','bbox');


end