data_dir = ['/home/tanmay/Documents/CS543/dataset/' ...
            'rgbd_scenes_filled_depth']
cd(data_dir)
cd train
for i=1:100
    load([num2str(i) '.mat'])
    filled_depth = filled_depth*100;
    save([num2str(i) '.mat'],'filled_depth');
end

cd ../test
for i=1:1308
    load([num2str(i) '.mat'])
    filled_depth = filled_depth*100;
    save([num2str(i) '.mat'],'filled_depth');
end