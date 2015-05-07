function fill_missing_depth_scenes(data_dir,depth_dir)

if(~exist(depth_dir,'dir'))
    mkdir(depth_dir);
end
mkdir(fullfile(depth_dir,'train'));
mkdir(fullfile(depth_dir,'test'));

load(fullfile(data_dir,'train_set.mat'));
load(fullfile(data_dir,'test_set.mat'));

size_train_set = numel(train_set);
size_test_set = numel(test_set);

train_set_cell = mat2cell(train_set,ones(1,size_train_set),1);
test_set_cell = mat2cell(test_set,ones(1,size_test_set),1);

parfor i=1:size_train_set
    fill_depth_inner(data_dir,train_set_cell{i},fullfile(depth_dir,'train',[num2str(i) '.mat']));
end

parfor i=1:size_test_set
    fill_depth_inner(data_dir,test_set_cell{i},fullfile(depth_dir,'test',[num2str(i) '.mat']));
end

end


function fill_depth_inner(data_dir,file_data,output_path)
img_name = fullfile(data_dir,file_data.img);
depth_name = fullfile(data_dir,file_data.depth);

img = im2double(imread(img_name));
depth = double(imread(depth_name))/100;
alpha = 0.5;

filled_depth = fill_depth_colorization(img,depth,alpha);
filled_depth = filled_depth*100;
save(output_path,'filled_depth');
end

