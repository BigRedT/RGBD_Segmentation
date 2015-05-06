img = imread('test_imgs/food_box_1_1_1_crop.png');
depth = imread('test_imgs/food_box_1_1_1_depthcrop.png');
mask = imread('test_imgs/food_box_1_1_1_maskcrop.png');

% img = imread('test_imgs/pliers_1_2_1_crop.png');
% depth = imread('test_imgs/pliers_1_2_1_depthcrop.png');
% mask = imread('test_imgs/pliers_1_2_1_maskcrop.png');

[cIndMap_rgb, imgVis_rgb, undersegError_rgb, undersegErrorSLIC_rgb] = ...
    slic_interface(img, depth, mask, 'type', 'rgb');
[cIndMap_rgbd, imgVis_rgbd, undersegError_rgbd, undersegErrorSLIC_rgbd] = ...
    slic_interface(img, depth, mask, 'type', 'rgbd');

disp('Error undersegError undersegErrorSLIC')
disp(['RGB  ' num2str(undersegError_rgb) ' ' num2str(undersegErrorSLIC_rgb)]);
disp(['RGBD ' num2str(undersegError_rgbd) ' ' num2str(undersegErrorSLIC_rgbd)]);

figure(1), imagesc(imgVis_rgb); title('SLIC RGB')
figure(2), imagesc(imgVis_rgbd); title('SLIC RGBD');
figure(3), imagesc(depth);

