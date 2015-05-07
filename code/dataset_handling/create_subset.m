data_dir = '/home/tanmay/Documents/CS543/dataset/rgbd-scenes';
full_file_list = read_rgbd_scenes_dataset(data_dir);
num_files = numel(full_file_list);
for i=1:num_files
    contains_object_mask(i) = ~isempty(full_file_list(i).bboxes);
end

file_list_filtered = full_file_list(contains_object_mask);
num_filtered_files = numel(file_list_filtered);

size_train_set = 100;

% Get index to training and test sets
train_idx = randperm(num_filtered_files,size_train_set)';
test_idx = setdiff([1:num_filtered_files]',train_idx);

% Partition data into training and test sets
train_set = file_list_filtered(train_idx);
test_set = file_list_filtered(test_idx);

save(fullfile(data_dir,'train_set.mat'),'train_set');
save(fullfile(data_dir,'test_set.mat'),'test_set');
save(fullfile(data_dir,'full_file_list.mat'),'full_file_list');
save(fullfile(data_dir,'file_list_filtered.mat'),'file_list_filtered');


