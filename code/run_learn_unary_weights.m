function B = run_learn_unary_weights(out_dir)
data_dir_full = '/home/tanmay/Documents/CS543/dataset/rgbd-object-full/';
depth_dir_full = '/home/tanmay/Documents/CS543/dataset/rgbd_objects_filled_depth-full/';
file_list_path = fullfile(data_dir,'file_list_object.mat');
load(file_list_path);

num_files = numel(file_list);
file_list_cell = mat2cell(file_list,ones(1,num_files),1);

energy_terms_cell = cell(num_files,1);
true_labels_cell = cell(num_files,1);
parfor i=1:num_files
   [energy_terms_cell{i} true_labels_cell{i}] = getEnergyAndLabels(data_dir_full,depth_dir_full,file_list_cell{i},i);
end
energy_terms = cell2mat(energy_terms_cell);
true_labels = cell2mat(true_labels_cell);

if(~exist(out_dir))
    mkdir(out_dir);
end
save(fullfile(out_dir,'energy_terms.mat'),'energy_terms');
save(fullfile(out_dir,'true_labels.mat'),'true_labels');

%% Train logistic regression
B = glmfit(energy_terms, abs(1-true_labels), 'link', 'logit');

end

function [energy_terms true_labels] = getEnergyAndLabels(data_dir_full,depth_dir_full,file_data,idx)
full_img = im2double(imread(fullfile(data_dir_full,file_data.img)));
full_depth = load(fullfile(depth_dir_full, [num2str(idx) '.mat']));
patch_coord = file_data.patch_coord;
true_mask = file_data.mask;
[h,w,~] = size(full_img);
active_mask = ones(h,w);
[energy_terms true_labels] = storeEnergy(im, im_depth, patch_coord, active_mask, trueMask);
end