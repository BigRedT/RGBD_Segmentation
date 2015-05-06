data_dir = '/home/tanmay/Documents/CS543/dataset/rgbd-dataset';
output_dir = '/home/tanmay/Documents/CS543/output_SLIC';
if(~exist(output_dir,'dir'))
    mkdir(output_dir);
end

if(~exist(fullfile(output_dir, 'file_list.mat')))
    file_list = read_rgbd_object_dataset(data_dir);
    save(fullfile(output_dir, 'file_list.mat'), 'file_list');
else
    load(fullfile(output_dir, 'file_list.mat'));
end

num_files = numel(file_list);

undersegError_rgb = zeros(num_files, 1);
undersegErrorSLIC_rgb = zeros(num_files, 1);
undersegError_rgbd = zeros(num_files, 1);
undersegErrorSLIC_rgbd = zeros(num_files, 1);

for i=1:num_files
    disp(['File: ' num2str(i)]);
    img = imread(file_list(i).img);
    depth = imread(file_list(i).depth);
    mask = imread(file_list(i).mask);

    [cIndMap_rgb, imgVis_rgb, undersegError_rgb(i), undersegErrorSLIC_rgb(i)] = ...
        slic_interface(img, depth, mask, 'type', 'rgb');

    [cIndMap_rgbd, imgVis_rgbd, undersegError_rgbd(i), undersegErrorSLIC_rgbd(i)] = ...
        slic_interface(img, depth, mask, 'type', 'rgbd');

    save(fullfile(output_dir, ['slic_output_' num2str(i) '.mat']), ...
                  'cIndMap_rgb', 'imgVis_rgb', 'cIndMap_rgbd', 'imgVis_rgbd');
end

save(fullfile(output_dir, 'slic_errors.mat'), ...
     'undersegError_rgb', 'undersegErrorSLIC_rgb', ...
     'undersegError_rgbd', 'undersegErrorSLIC_rgbd');