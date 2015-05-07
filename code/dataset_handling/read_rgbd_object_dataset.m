function file_list = read_rgbd_object_dataset(data_dir)

object_dirs = dir(data_dir);
for i=1:numel(object_dirs)
    if(strcmp(object_dirs(i).name,'.') || strcmp(object_dirs(i).name,'..'))
        object_dirs(i).isdir = 0;
    end
end
dir_mask = boolean(vertcat(object_dirs.isdir));
object_dirs = object_dirs(dir_mask);
num_objects = numel(object_dirs);

file_list = [];
for i=1:num_objects
    obj_name = object_dirs(i).name;
    instance_num = 1;
    instance_dir = fullfile(data_dir,obj_name,[obj_name '_1'])
    while(isdir(instance_dir))
        video_num = 1;
        video_begin = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_1_crop.png']);
        while(exist(video_begin,'file'))
            frame_num = 1;
            img_name = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_1_crop.png']);
            depth_name = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_1_depthcrop.png']);
            mask_name = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_1_maskcrop.png']);
            while(exist(img_name,'file'))
                names.img = fullfile(obj_name,[obj_name '_' num2str(instance_num)],[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_' num2str(frame_num) '_crop.png']);
                names.depth = fullfile(obj_name,[obj_name '_' num2str(instance_num)],[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_' num2str(frame_num) '_depthcrop.png']);
                names.mask = fullfile(obj_name,[obj_name '_' num2str(instance_num)],[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_' num2str(frame_num) '_maskcrop.png']);
                file_list = [file_list; names];
 
                frame_num = frame_num + 50;
                img_name = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_' num2str(frame_num) '_crop.png']);
                depth_name = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_' num2str(frame_num) '_depthcrop.png']);
                mask_name = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_' num2str(frame_num) '_maskcrop.png']);
            end
            video_num = video_num + 1;
            video_begin = fullfile(instance_dir,[obj_name '_' num2str(instance_num) '_' num2str(video_num) '_1_crop.png']);
        end
        instance_num = instance_num + 1;
        instance_dir = fullfile(data_dir,obj_name,[obj_name '_' num2str(instance_num)])
    end
end