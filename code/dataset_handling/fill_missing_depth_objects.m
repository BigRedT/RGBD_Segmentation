function fill_missing_depth_objects(file_list,data_dir,depth_dir)

if(~exist(depth_dir,'dir'))
    mkdir(depth_dir);
end

% file_list = read_rgbd_object_dataset(data_dir);
% save(fullfile(depth_dir,'file_list.mat'),'file_list');
num_files = numel(file_list);

file_list_cell = mat2cell(file_list,ones(1,num_files),1);
parfor i=1:num_files
    fill_depth_inner(data_dir,file_list_cell{i},fullfile(depth_dir,[num2str(i) '.mat']));
end
end

function fill_depth_inner(data_dir,file_data,output_path)
img_name = fullfile(data_dir,file_data.img);
depth_name = fullfile(data_dir,file_data.depth);

img = im2double(imread(img_name));
depth = double(imread(depth_name))/100;
alpha = 0.5;

filled_depth = fill_depth_colorization(img,depth,alpha);
filled_depth = 100*filled_depth;
save(output_path,'filled_depth');
end