function file_list = read_rgbd_scenes_dataset(data_dir)

scenes_dirs = dir(data_dir);
for i=1:numel(scenes_dirs)
    if(strcmp(scenes_dirs(i).name,'.') || strcmp(scenes_dirs(i).name,'..'))
        scenes_dirs(i).isdir = 0;
    end
end
dir_mask = boolean(vertcat(scenes_dirs.isdir));
scenes_dirs = scenes_dirs(dir_mask);

%% Sort scene directories by name to avoid randomness
num_scenes = numel(scenes_dirs);

file_list = [];
for i=1:num_scenes
    scene_name = scenes_dirs(i).name;
    instance_num = 1;
    instance_dir = fullfile(data_dir,scene_name,[scene_name '_1']);
    while(isdir(instance_dir))
        load(fullfile(data_dir,scene_name,[scene_name '_' num2str(instance_num) '.mat']));
        frame_num = 1;
        img_name = fullfile(instance_dir,[scene_name '_' num2str(instance_num) '_1.png']);
        while(exist(img_name,'file'))
            element.img = fullfile(scene_name,[scene_name '_' num2str(instance_num)],[scene_name '_' num2str(instance_num) '_' num2str(frame_num) '.png']);
            element.depth = fullfile(scene_name,[scene_name '_' num2str(instance_num)],[scene_name '_' num2str(instance_num) '_' num2str(frame_num) '_depth.png']);
            element.bboxes = bboxes{frame_num};
            file_list = [file_list; element];
            
            frame_num = frame_num + 1;
            img_name = fullfile(instance_dir,[scene_name '_' num2str(instance_num) '_' num2str(frame_num) '.png']);
        end
        instance_num = instance_num + 1;
        instance_dir = fullfile(data_dir,scene_name,[scene_name '_' num2str(instance_num)]);
    end
end
